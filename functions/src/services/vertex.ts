import { VertexAI } from '@google-cloud/vertexai';
import { logInfo, logError } from '../utils/log';

const PROJECT_ID = process.env.VERTEX_PROJECT_ID;
const LOCATION = process.env.VERTEX_LOCATION || 'us-central1';
const TEXT_MODEL = process.env.VERTEX_TEXT_MODEL || 'gemini-1.5-flash';
const IMAGE_MODEL = process.env.VERTEX_IMAGE_MODEL || 'imagen-3.0-generate';

let vertex: VertexAI | null = null;
function getClient(): VertexAI | null {
  if (!PROJECT_ID) {
    logError('vertex', 'Missing PROJECT_ID, using stubs');
    return null;
  }
  if (!vertex) {
    vertex = new VertexAI({ project: PROJECT_ID, location: LOCATION });
  }
  return vertex;
}

export async function summarizeText(content: string): Promise<string> {
  const client = getClient();
  if (!client) return content.slice(0, 400);
  try {
    const model = client.getGenerativeModel({ model: TEXT_MODEL, systemInstruction: {
      role: 'system', parts: [{ text: 'You help create dyslexia-friendly summaries: short sentences, clear bullets, high-contrast descriptive words.' }]
    }});
    const result = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: `Summarize clearly:
${content}` }]}] });
    return result.response.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || 'Summary unavailable';
  } catch (e: any) {
    logError('vertex', 'summarizeText failed', { error: e.message });
    return content.slice(0, 400);
  }
}

export async function extractKeyTerms(content: string): Promise<string[]> {
  const client = getClient();
  if (!client) return ['term1','term2'];
  try {
    const model = client.getGenerativeModel({ model: TEXT_MODEL });
    const prompt = `Extract 8-12 concise key study terms (single or short multi-word). Return as comma separated list only.\nText:\n${content}`;
    const result = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: prompt }]}] });
    const raw = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
    return raw.split(/[,\n]/).map(s => s.trim()).filter(Boolean).slice(0, 15);
  } catch (e: any) {
    logError('vertex', 'extractKeyTerms failed', { error: e.message });
    return ['term1','term2'];
  }
}

export async function generateImages(summary: string): Promise<string[]> {
  const client = getClient();
  if (!client) return [];
  try {
    const model = client.getGenerativeModel({ model: IMAGE_MODEL });
    const prompt = `Create 2 simple, high-contrast educational illustrations (PNG) to explain: ${summary.slice(0, 400)}`;
    const resp = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: prompt }]}] });
    const images: string[] = [];
    for (const part of (resp.response.candidates?.[0]?.content?.parts || [])) {
      if ((part as any).inlineData?.data) {
        images.push((part as any).inlineData.data); // base64
      }
    }
    return images.slice(0, 2);
  } catch (e: any) {
    logError('vertex', 'generateImages failed', { error: e.message });
    return [];
  }
}

export async function explainImage(descContext: string, index: number): Promise<string> {
  const client = getClient();
  if (!client) return `Explanation ${index+1}`;
  try {
    const model = client.getGenerativeModel({ model: TEXT_MODEL });
    const prompt = `Write a short (<=40 words) dyslexia-friendly explanation for image #${index+1}. Context: ${descContext.slice(0, 400)}`;
    const r = await model.generateContent({ contents: [{ role: 'user', parts: [{ text: prompt }]}] });
    return r.response.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || `Explanation ${index+1}`;
  } catch (e: any) {
    logError('vertex', 'explainImage failed', { error: e.message });
    return `Explanation ${index+1}`;
  }
}
