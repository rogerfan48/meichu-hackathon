import { VertexAI } from '@google-cloud/vertexai';
import { Storage } from '@google-cloud/storage';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

// Initialize Firebase Admin SDK and Google Cloud clients
if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();
const storage = new Storage();

// Initialize Vertex AI
const vertexAI = new VertexAI({
  project: process.env.GCLOUD_PROJECT || 'lexiaid-2e3b5',
  location: 'us-central1',
});

// Get the generative models
const textModel = vertexAI.getGenerativeModel({
  model: 'gemini-1.5-pro-preview-0514',
});

const imageModel = vertexAI.getGenerativeModel({
  model: 'imagen-3.0-generate-001',
});

// Types
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

// Fetch file content
async function fetchFileText(fileURL: string): Promise<string> {
  if (fileURL.startsWith("gs://")) {
    const { bucket: bucketName, name: filePath } = parseGsUrl(fileURL);
    const [contents] = await storage.bucket(bucketName).file(filePath).download();
    return contents.toString("utf-8");
  }
  const res = await fetch(fileURL);
  if (!res.ok) throw new Error(`Failed to fetch ${fileURL}: ${res.status} ${res.statusText}`);
  const text = await res.text();
  const MAX_CHARS = 80_000;
  return text.length > MAX_CHARS ? text.slice(0, MAX_CHARS) + "\n\n[Truncated]" : text;
}

function parseGsUrl(gsUrl: string): { bucket: string; name: string } {
  const withoutScheme = gsUrl.replace(/^gs:\/\//, "");
  const [bucket, ...rest] = withoutScheme.split("/");
  return { bucket, name: rest.join("/") };
}

// Generate per-file summary using Vertex AI directly
async function generatePerFileSummary(fileURL: string, content: string): Promise<FileSummary> {
  const prompt = `You are an assistant that explains complex content so it is easy to read for people with Dyslexia. You respond strictly in JSON format.

Style rules to follow:
- Use very short sentences.
- Use simple words. Avoid jargon unless you define it.
- Use clear headings and bullet points.
- Explain step-by-step.
- Add small examples.
- Keep each bullet point under 16 words.
- Prefer active voice.

Task:
Read the file content and produce a JSON object with:
- "fileURL": original file URL.
- "title": 3-7 word title.
- "simpleSummary": 4-7 short sentences. Plain language.
- "keyPoints": 5-10 bullets. Each bullet is short.
- "readingAids":
   - glossary: 3-8 terms with simple meanings (skip unknown terms).
   - examples: 2-4 tiny examples in plain language.
   - steps: 3-7 short action steps.

Output JSON only. No markdown. No extra text.

fileURL: ${fileURL}
fileContent:
'''
${content}
'''`;

  const result = await textModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 2048,
    },
  });

  const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
  
  try {
    const parsed = JSON.parse(responseText);
    return {
      fileURL: parsed.fileURL || fileURL,
      title: parsed.title || 'Untitled',
      simpleSummary: parsed.simpleSummary || '',
      keyPoints: parsed.keyPoints || [],
      readingAids: parsed.readingAids || { glossary: [], examples: [], steps: [] },
    };
  } catch (error) {
    throw new Error(`Failed to parse JSON response: ${responseText}`);
  }
}

// Generate final summary using Vertex AI directly
async function generateFinalSummary(fileSummaries: FileSummary[]): Promise<{ summary: string; imageIdeas: string[] }> {
  const summariesAsBullets = fileSummaries
    .map(s => `- ${s.title}\n  • ${s.simpleSummary.replace(/\n/g, " ")}\n  • Key points: ${s.keyPoints.slice(0, 5).join("; ")}`)
    .join("\n");

  const prompt = `You are an assistant that explains complex content so it is easy to read for people with Dyslexia. You respond strictly in JSON format.

Style rules:
- Very short sentences. Simple words.
- Clear headings. Bullet lists.
- Max 16 words per bullet.
- Explain the big picture, then key details.
- Include 1-2 tiny examples.
- End with 5-8 action steps.

Task:
Combine the given per-file summaries into one easy summary.
Also propose 3-6 illustration ideas that make the concepts easier to understand.
Each illustration idea should be a short description that an image generator could use.

Output JSON with fields:
- "summary": a readable multi-section summary with headings and bullet points.
- "imageIdeas": array of short image prompt strings.

Use neutral tone. No sensitive content. Output JSON only.

Per-file summaries (for your context only):
${summariesAsBullets}`;

  const result = await textModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 2048,
    },
  });

  const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
  
  try {
    const parsed = JSON.parse(responseText);
    return {
      summary: parsed.summary || '',
      imageIdeas: parsed.imageIdeas || [],
    };
  } catch (error) {
    throw new Error(`Failed to parse JSON response: ${responseText}`);
  }
}

// Generate image using Vertex AI directly
async function generateImage(prompt: string): Promise<string> {
  const imagePrompt = `Create a simple, clear illustration that helps people with dyslexia understand the concept: ${prompt}. 
The image should be:
- Easy to understand at a glance
- Use bright, clear colors
- Have simple shapes and minimal text
- Focus on one main concept
- Be educational and friendly
Make it look like a helpful diagram or infographic that makes complex ideas simple.`;

  const result = await imageModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: imagePrompt }] }],
    generationConfig: {
      temperature: 0.4,
    },
  });

  // Extract image URL from response
  const imageUrl = result.response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
  if (imageUrl) {
    // Save to Cloud Storage and return gs:// URL
    const bucket = storage.bucket(`${process.env.GCLOUD_PROJECT}-generated-images`);
    const fileName = `image-${Date.now()}-${Math.random().toString(36).substr(2, 9)}.png`;
    const file = bucket.file(fileName);
    
    await file.save(Buffer.from(imageUrl, 'base64'), {
      metadata: { contentType: 'image/png' },
    });
    
    return `gs://${bucket.name}/${fileName}`;
  }
  
  return ''; // Return empty string if no image generated
}

function makeId(prefix: string, idx: number) {
  return `${prefix}_${String(idx + 1).padStart(3, "0")}`;
}

// Main Cloud Function
export const genSessionSummaryFlow = functions.https.onCall(async (data, context) => {
  const fileURLs: string[] = data.data?.fileURLs || [];
  
  // Step 1: create a new session document
  const sessionDoc = {
    sessionName: `Session ${new Date().toISOString()}`,
    fileResources: {} as Record<string, { id: string; fileURL: string; fileSummary?: string | null }>,
    summary: null as string | null,
    imgExplanations: {} as Record<string, { id: string; imgURL: string; explanation?: string | null }>,
    cardIDs: [] as string[],
    status: "processing",
    fileSummariesJson: [] as string[],
  };

  const sessionRef = await db.collection("sessions").add(sessionDoc);
  const sessionID = sessionRef.id;

  const fileSummaries: FileSummary[] = [];
  const fileSummariesJsonStrings: string[] = [];

  // Step 2: summarize each file
  for (let i = 0; i < fileURLs.length; i++) {
    const fileURL = fileURLs[i];
    const fileResId = makeId("fr", i);

    try {
      const content = await fetchFileText(fileURL);
      const summaryObj = await generatePerFileSummary(fileURL, content);

      fileSummaries.push(summaryObj);
      fileSummariesJsonStrings.push(JSON.stringify(summaryObj));

      await sessionRef.set({
        fileResources: {
          [fileResId]: {
            id: fileResId,
            fileURL,
            fileSummary: summaryObj.simpleSummary,
          },
        },
        fileSummariesJson: fileSummariesJsonStrings,
      }, { merge: true });
    } catch (err: any) {
      await sessionRef.set({
        fileResources: {
          [fileResId]: {
            id: fileResId,
            fileURL,
            fileSummary: `Error: ${String(err?.message || err)}`,
          },
        },
      }, { merge: true });
    }
  }

  // Step 3: final summary + generate images
  const final = await generateFinalSummary(fileSummaries);

  // Step 3.5: Generate images
  const imageGenerationPromises = final.imageIdeas.map(async (idea, idx) => {
    const imgURL = await generateImage(idea);
    const id = makeId("img", idx);
    return { id, imgURL, explanation: idea };
  });

  const generatedImages = await Promise.all(imageGenerationPromises);

  const imgExplanationsMap = generatedImages.reduce((acc, imgData) => {
    acc[imgData.id] = {
      id: imgData.id,
      imgURL: imgData.imgURL,
      explanation: imgData.explanation,
    };
    return acc;
  }, {} as Record<string, { id: string; imgURL: string; explanation?: string | null }>);

  await sessionRef.set({
    summary: final.summary,
    imgExplanations: imgExplanationsMap,
    imgExplanation: final.imageIdeas,
    status: "complete",
  }, { merge: true });

  return {
    sessionID,
    summary: final.summary,
    imgExplanation: final.imageIdeas,
  };
});
