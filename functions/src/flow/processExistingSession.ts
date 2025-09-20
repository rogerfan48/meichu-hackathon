import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { VertexAI } from '@google-cloud/vertexai';
import { Storage } from '@google-cloud/storage';
// import { Readable } from 'node:stream';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();
const storage = new Storage();

const PROJECT_ID = process.env.GCLOUD_PROJECT || 'lexiaid-2e3b5';
const LOCATION = 'us-central1';

const vertexAI = new VertexAI({
  project: PROJECT_ID,
  location: LOCATION,
});

const textModel = vertexAI.getGenerativeModel({
  model: 'gemini-1.5-pro-preview-0514',
});
const imageModel = vertexAI.getGenerativeModel({
  model: 'imagen-3.0-generate-001',
});

type FileSummary = {
  fileURL: string;
  title: string;
  simpleSummary: string;
  keyPoints: string[];
  readingAids: {
    glossary: Array<{ term: string; meaning: string }>;
    examples: string[];
    steps: string[];
  };
};

function parseGsUrl(gsUrl: string): { bucket: string; name: string } {
  const without = gsUrl.replace(/^gs:\/\//, '');
  const [bucket, ...rest] = without.split('/');
  return { bucket, name: rest.join('/') };
}

async function downloadGsFile(gsUrl: string): Promise<{ bytes: Buffer; contentType: string | undefined }> {
  const { bucket, name } = parseGsUrl(gsUrl);
  const file = storage.bucket(bucket).file(name);
  const [meta] = await file.getMetadata();
  const [bytes] = await file.download();
  return { bytes, contentType: meta.contentType };
}

async function extractTextFromFile(gsUrl: string): Promise<string> {
  try {
    const { bytes, contentType } = await downloadGsFile(gsUrl);
    if (!contentType) {
      return bytes.toString('utf-8').slice(0, 80000);
    }
    if (contentType.startsWith('text/')) {
      return bytes.toString('utf-8').slice(0, 80000);
    }
    if (contentType === 'application/pdf') {
      // Simple heuristic: send raw truncated bytes base64 to model asking to extract text
      const b64 = bytes.toString('base64').slice(0, 500000); // cap
      const prompt = `You are an assistant that extracts readable text from a (possibly partial) PDF content (base64). 
Return ONLY the extracted plain text (no JSON, no commentary).
If unreadable, return an empty string.

Base64 (partial):
${b64}`;
      const result = await textModel.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.1, maxOutputTokens: 1024 },
      });
      return result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
    }
    if (contentType.startsWith('image/')) {
      // For images: simple prompt to describe & extract text (OCR-ish)
      const b64 = bytes.toString('base64').slice(0, 800000);
      const result = await textModel.generateContent({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: `You are an assistant that describes an image and extracts any text it contains (OCR style). 
Return plain extracted text plus a short description.`
              },
              {
                inlineData: {
                  mimeType: contentType,
                  data: b64,
                },
              },
            ],
          },
        ],
        generationConfig: { temperature: 0.2, maxOutputTokens: 768 },
      });
      return result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
    }
    // Fallback
    return bytes.toString('utf-8').slice(0, 80000);
  } catch (e) {
    console.error('[extractTextFromFile] failed', gsUrl, e);
    return '';
  }
}

async function generatePerFileSummary(fileURL: string, content: string): Promise<FileSummary> {
  const safeContent = content.slice(0, 60000);
  const prompt = `You are an assistant that explains complex content so it is easy for people with Dyslexia. Respond ONLY valid JSON.

Rules:
- Very short sentences.
- Simple words.
- Bullet points (<16 words).
- Step-by-step.
- Provide small examples.

Return JSON:
{
 "fileURL": "...",
 "title": "3-7 words",
 "simpleSummary": "4-7 short sentences",
 "keyPoints": ["..."],
 "readingAids": {
   "glossary": [{"term":"...", "meaning":"..."}],
   "examples": ["..."],
   "steps": ["..."]
 }
}

Content:
${safeContent}`;

  const result = await textModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: { temperature: 0.2, maxOutputTokens: 2048 },
  });

  const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
  try {
    const parsed = JSON.parse(responseText);
    return {
      fileURL,
      title: parsed.title || 'Untitled',
      simpleSummary: parsed.simpleSummary || '',
      keyPoints: parsed.keyPoints || [],
      readingAids: parsed.readingAids || { glossary: [], examples: [], steps: [] },
    };
  } catch (e) {
    throw new Error(`Per-file JSON parse failed: ${responseText}`);
  }
}

async function generateFinalSummary(fileSummaries: FileSummary[]): Promise<{ summary: string; imageIdeas: string[] }> {
  const summariesBullets = fileSummaries
    .map(s => `TITLE: ${s.title}\nSUMMARY: ${s.simpleSummary.replace(/\n/g, ' ')}\nKEY: ${s.keyPoints.slice(0,5).join('; ')}`)
    .join('\n---\n');

  const prompt = `Combine these file summaries into one dyslexia-friendly session summary. 
Rules:
- Headings + bullet lists.
- Very short sentences.
- Simple words.
- Start with big picture, then grouped key points.
- End with 5-8 action steps.
Also output 3-5 illustration ideas (short phrases).

Return JSON:
{
 "summary": "multi-section text",
 "imageIdeas": ["idea1", "idea2", ...]
}

File Summaries:
${summariesBullets}`;

  const result = await textModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: { temperature: 0.25, maxOutputTokens: 2048 },
  });

  const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
  try {
    const parsed = JSON.parse(responseText);
    return {
      summary: parsed.summary || '',
      imageIdeas: parsed.imageIdeas || [],
    };
  } catch (e) {
    throw new Error(`Final summary JSON parse failed: ${responseText}`);
  }
}

async function generateImage(idea: string): Promise<{ imgURL: string; explanation: string }> {
  const imagePrompt = `Clear educational illustration (dyslexia friendly).
Idea: ${idea}
Simple shapes, bright contrast, minimal/no text, single concept.`;
  const result = await imageModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: imagePrompt }] }],
    generationConfig: { temperature: 0.4 },
  });

  const inline = result.response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
  if (!inline) return { imgURL: '', explanation: idea };

  const bucket = storage.bucket(`${PROJECT_ID}-generated-images`);
  const fileName = `img_${Date.now()}_${Math.random().toString(36).slice(2)}.png`;
  const file = bucket.file(fileName);
  await file.save(Buffer.from(inline, 'base64'), {
    metadata: { contentType: 'image/png' },
  });
  return { imgURL: `gs://${bucket.name}/${fileName}`, explanation: idea };
}

function makeId(prefix: string, idx: number) {
  return `${prefix}_${String(idx + 1).padStart(3, '0')}`;
}

/*
 Callable function:
 data: { uid: string, sessionID: string }
*/
export const processExistingSessionFlow = functions.https.onCall(async (data, context) => {
  const uid: string = data.data?.uid;
  const sessionID: string = data.data?.sessionID;

  if (!uid || !sessionID) {
    throw new functions.https.HttpsError('invalid-argument', 'uid and sessionID are required.');
  }

  console.log(`[processExistingSessionFlow] Start uid=${uid} sessionID=${sessionID}`);

  const sessionRef = db
    .collection('apps')
    .doc('lexiaid')
    .collection('users')
    .doc(uid)
    .collection('sessions')
    .doc(sessionID);

  const snap = await sessionRef.get();
  if (!snap.exists) {
    throw new functions.https.HttpsError('not-found', 'Session not found.');
  }

  const sessionData = snap.data() || {};
  const fileResourcesObj = (sessionData.fileResources || {}) as Record<string, { id: string; fileURL: string; fileSummary?: string | null }>;
  const resourceEntries = Object.entries(fileResourcesObj);

  if (resourceEntries.length === 0) {
    console.log('[processExistingSessionFlow] No fileResources; nothing to summarize.');
    return { sessionID, updated: false, reason: 'no_file_resources' };
  }

  // Mark processing
  await sessionRef.set({ status: 'processing' }, { merge: true });

  const perFileSummaries: FileSummary[] = [];

  for (let i = 0; i < resourceEntries.length; i++) {
    const [key, fr] = resourceEntries[i];
    const effectiveId = fr.id || key;
    const fileURL = fr.fileURL;
    console.log(`[processExistingSessionFlow] Processing fileResource ${effectiveId} (${fileURL})`);

    try {
      const extracted = await extractTextFromFile(fileURL);
      const summary = await generatePerFileSummary(fileURL, extracted || '(No readable text)');
      perFileSummaries.push(summary);

      // Nested update
      await sessionRef.set(
        {
          fileResources: {
            [effectiveId]: {
              id: effectiveId,
              fileURL,
              fileSummary: summary.simpleSummary,
            },
          },
        },
        { merge: true }
      );
    } catch (e) {
      console.error(`[processExistingSessionFlow] Failed on ${effectiveId}`, e);
      await sessionRef.set(
        {
          fileResources: {
            [effectiveId]: {
              id: effectiveId,
              fileURL,
              fileSummary: `Error: ${(e as Error).message}`,
            },
          },
        },
        { merge: true }
      );
    }
  }

  // Session-level summary
  let finalSummary = '';
  let imageIdeas: string[] = [];
  try {
    const final = await generateFinalSummary(perFileSummaries);
    finalSummary = final.summary;
    imageIdeas = final.imageIdeas;
    await sessionRef.set({ summary: finalSummary }, { merge: true });
  } catch (e) {
    console.error('[processExistingSessionFlow] Final summary failed', e);
  }

  // Generate images
  const images: Array<{ id: string; imgURL: string; explanation: string }> = [];
  for (let i = 0; i < imageIdeas.length; i++) {
    try {
      const img = await generateImage(imageIdeas[i]);
      images.push({ id: makeId('img', i), ...img });
    } catch (e) {
      console.error('[processExistingSessionFlow] Image generation failed', imageIdeas[i], e);
    }
  }

  if (images.length > 0) {
    const imgExplanations = images.reduce((acc, cur) => {
      acc[cur.id] = { id: cur.id, imgURL: cur.imgURL, explanation: cur.explanation };
      return acc;
    }, {} as Record<string, { id: string; imgURL: string; explanation: string }>);
    await sessionRef.set({ imgExplanations }, { merge: true });
  }

  // Complete
  await sessionRef.set({ status: 'complete' }, { merge: true });

//   return {
//     sessionID,
//     filesProcessed: perFileSummaries.length,
//     finalSummaryLength: finalSummary.length,
//     imagesGenerated: images.length,
//   };
  return;
});
