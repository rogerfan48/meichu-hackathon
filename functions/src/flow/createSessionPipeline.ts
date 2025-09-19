import { admin } from '../config';
import { SessionDoc } from '../type';
import { logInfo, logError } from '../utils/log';
import { summarizeText, extractKeyTerms as vertexExtractKeyTerms, generateImages as vertexGenerateImages, explainImage as vertexExplainImage } from '../services/vertex';

interface PipelineParams {
  userId: string;
  sessionId: string;
}

// Simple fetch of file text could be implemented here; currently just uses URL as placeholder text input.
async function summarizeFile(fileUrl: string): Promise<string> {
  return summarizeText(`Content reference: ${fileUrl}`);
}

async function extractKeyTerms(text: string): Promise<string[]> {
  return vertexExtractKeyTerms(text);
}

async function generateImages(globalSummary: string): Promise<string[]> {
  return vertexGenerateImages(globalSummary);
}

async function explainImage(_imageUrl: string, summary: string, index: number): Promise<string> {
  return vertexExplainImage(summary, index);
}

async function uploadBase64Image(userId: string, sessionId: string, b64: string, idx: number): Promise<string> {
  try {
    const buffer = Buffer.from(b64, 'base64');
    const bucket = admin.storage().bucket();
    const path = `${userId}/${sessionId}/generated/image_${idx + 1}.png`;
    const file = bucket.file(path);
    await file.save(buffer, { contentType: 'image/png' });
    const [url] = await file.getSignedUrl({ action: 'read', expires: Date.now() + 1000 * 60 * 60 * 6 });
    return url;
  } catch (e: any) {
    logError('pipeline', 'uploadBase64Image failed', { error: e.message });
    return '';
  }
}

export async function createSessionPipeline({ userId, sessionId }: PipelineParams) {
  const db = admin.firestore();
  const userRef = db.doc(`apps/hackathon/users/${userId}`);
  const userSnap = await userRef.get();
  if (!userSnap.exists) throw new Error('User not found');
  const data = userSnap.data() || {} as any;
  const session: SessionDoc | undefined = data.sessions?.[sessionId];
  if (!session) throw new Error('Session not found');
  try {
    await userRef.update({ [`sessions.${sessionId}.status`]: 'processing' });
    logInfo('pipeline', 'Session processing started', { userId, sessionId });

    const fileSummaries: Record<string, string> = {};
    const fileResources = session.fileResources || {};
    await Promise.all(
      Object.entries(fileResources).map(async ([fid, fr]) => {
        fileSummaries[fid] = await summarizeFile(fr.fileURL);
      })
    );
    logInfo('pipeline', 'File summaries complete', { count: Object.keys(fileSummaries).length });

    const globalText = Object.values(fileSummaries).join('\n');
  const globalSummary = await summarizeText(globalText);
  const keyTerms = await extractKeyTerms(globalSummary);
    logInfo('pipeline', 'Global summary created', { summaryLength: globalSummary.length });

    await userRef.update({
      [`sessions.${sessionId}.summary`]: globalSummary,
      [`sessions.${sessionId}.status`]: 'generatingImages'
    });

    const base64Images = await generateImages(globalSummary);
    const imgExplanations: Record<string, any> = {};
    for (let i = 0; i < base64Images.length; i++) {
      const b64 = base64Images[i];
      const publicUrl = b64 ? await uploadBase64Image(userId, sessionId, b64, i) : '';
      const id = db.collection('_tmp').doc().id;
      imgExplanations[id] = { imgURL: publicUrl, explanation: await explainImage(publicUrl, globalSummary, i) };
    }
    logInfo('pipeline', 'Images generated', { imageCount: base64Images.length });

    const cardIDs: string[] = [];
    for (const term of keyTerms) {
      const cardId = db.collection('_tmp').doc().id;
      cardIDs.push(cardId);
      await userRef.update({ [`cards.${cardId}`]: { sessionID: sessionId, tags: [], text: term } });
    }
    logInfo('pipeline', 'Cards created', { cardCount: keyTerms.length });

    if (Object.keys(imgExplanations).length > 0) {
      for (const [id, value] of Object.entries(imgExplanations)) {
        await userRef.update({ [`sessions.${sessionId}.imgExplanations.${id}`]: value });
      }
    }

    await userRef.update({
      [`sessions.${sessionId}.cardIDs`]: cardIDs,
      [`sessions.${sessionId}.status`]: 'complete'
    });
    logInfo('pipeline', 'Session pipeline complete', { sessionId });
  } catch (err: any) {
    logError('pipeline', 'Session pipeline failed', { sessionId, error: err.message });
    await userRef.update({ [`sessions.${sessionId}.status`]: 'error' });
    throw err;
  }
}
