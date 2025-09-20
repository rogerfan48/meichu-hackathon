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

// Step 1: Extract 5 important words from session summary
async function extractImportantWords(sessionSummary: string): Promise<string[]> {
  const prompt = `You are an assistant that helps people with dyslexia learn important concepts. You respond strictly in JSON format.

Task:
Extract exactly 5 most important words or short phrases from the given summary.
These words should be:
- Key concepts that help understanding
- Simple and clear (good for people with dyslexia)
- Each word/phrase should be 1-3 words maximum
- Focus on main ideas, not small details

Output a JSON object with:
- "words": array of exactly 5 important words/phrases

Output JSON only. No markdown. No extra text.

Summary to analyze:
${sessionSummary}`;

  const result = await textModel.generateContent({
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    generationConfig: {
      temperature: 0.3,
      maxOutputTokens: 1024,
    },
  });

  const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '';
  
  try {
    const parsed = JSON.parse(responseText);
    const words = parsed.words || [];
    
    // Ensure we have exactly 5 words
    if (words.length >= 5) {
      return words.slice(0, 5);
    } else {
      // If we get less than 5, pad with generic terms
      const paddedWords = [...words];
      while (paddedWords.length < 5) {
        paddedWords.push(`Concept ${paddedWords.length + 1}`);
      }
      return paddedWords;
    }
  } catch (error) {
    console.error('Failed to parse important words response:', responseText);
    // Return fallback words
    return ['Concept 1', 'Concept 2', 'Concept 3', 'Concept 4', 'Concept 5'];
  }
}

// Step 3: Generate image for a concept word and store in Firebase Storage
async function generateAndStoreImage(conceptWord: string): Promise<string> {
  const imagePrompt = `Create a simple, clear educational illustration for the concept: "${conceptWord}". 
The image should be:
- Easy to understand at a glance
- Use bright, clear colors  
- Have simple shapes and minimal text
- Focus on one main concept
- Be educational and friendly
- Suitable for people with dyslexia (clear and not overwhelming)
Make it look like a helpful diagram or icon that makes the concept "${conceptWord}" easy to understand.`;

  try {
    const result = await imageModel.generateContent({
      contents: [{ role: 'user', parts: [{ text: imagePrompt }] }],
      generationConfig: {
        temperature: 0.4,
      },
    });

    // Extract image data from response
    const imageData = result.response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
    
    if (imageData) {
      // Save to Cloud Storage
      const bucketName = `${process.env.GCLOUD_PROJECT}-card-images`;
      const bucket = storage.bucket(bucketName);
      const fileName = `card-${Date.now()}-${Math.random().toString(36).substr(2, 9)}.png`;
      const file = bucket.file(fileName);
      
      await file.save(Buffer.from(imageData, 'base64'), {
        metadata: { 
          contentType: 'image/png',
          metadata: {
            concept: conceptWord,
            generatedAt: new Date().toISOString(),
          }
        },
      });
      
      return `gs://${bucketName}/${fileName}`;
    } else {
      console.warn(`No image generated for concept: ${conceptWord}`);
      return ''; // Return empty string if no image generated
    }
  } catch (error) {
    console.error(`Error generating image for concept "${conceptWord}":`, error);
    return ''; // Return empty string on error
  }
}

// Helper function to generate card ID
function makeCardId(sessionID: string, idx: number): string {
  return `${sessionID}_card_${String(idx + 1).padStart(3, "0")}`;
}

// Main Cloud Function
export const genCardsFlow = functions.https.onCall(async (data, context) => {
  const sessionID: string = data.data?.sessionID || '';
  const sessionSummary: string = data.data?.sessionSummary || '';
  
  if (!sessionID || !sessionSummary) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'sessionID and sessionSummary are required'
    );
  }

  try {
    // Step 1: Extract 5 important words from the session summary
    console.log(`Extracting important words from session ${sessionID}`);
    const importantWords = await extractImportantWords(sessionSummary);
    console.log(`Extracted words:`, importantWords);

    // Step 2 & 3: Create cards and generate images for each word
    const cardCreationPromises = importantWords.map(async (word, idx) => {
      const cardID = makeCardId(sessionID, idx);
      
      try {
        // Step 3: Generate and store image for this concept
        console.log(`Generating image for concept: "${word}"`);
        const imgURL = await generateAndStoreImage(word);
        
        // Step 2: Create card document in Firestore
        const cardData = {
          id: cardID,
          sessionID: sessionID,
          tags: [word.toLowerCase().replace(/\s+/g, '_')], // Convert to tag format
          imgURL: imgURL,
          text: `Key concept: ${word}`, // Simple text for dyslexia-friendly cards
          goodCount: 0,
          badCount: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Save to Firestore in cards collection
        await db.collection('cards').doc(cardID).set(cardData);
        
        console.log(`Created card ${cardID} for concept: "${word}"`);
        
        return {
          cardID,
          word,
          imgURL,
          success: true,
        };
      } catch (error) {
        console.error(`Error creating card for concept "${word}":`, error);
        
        // Create card without image on error
        const cardData = {
          id: cardID,
          sessionID: sessionID,
          tags: [word.toLowerCase().replace(/\s+/g, '_')],
          imgURL: null,
          text: `Key concept: ${word}`,
          goodCount: 0,
          badCount: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await db.collection('cards').doc(cardID).set(cardData);
        
        return {
          cardID,
          word,
          imgURL: null,
          success: false,
          error: error instanceof Error ? error.message : String(error),
        };
      }
    });

    // Wait for all cards to be created
    const cardResults = await Promise.all(cardCreationPromises);
    
    // Update the session document with the new card IDs
    const cardIDs = cardResults.map(result => result.cardID);
    await db.collection('sessions').doc(sessionID).update({
      cardIDs: admin.firestore.FieldValue.arrayUnion(...cardIDs),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Return summary of what was created
    const successfulCards = cardResults.filter(result => result.success);
    const failedCards = cardResults.filter(result => !result.success);

    return {
      success: true,
      sessionID,
      totalCards: cardResults.length,
      successfulCards: successfulCards.length,
      failedCards: failedCards.length,
      cardIDs,
      concepts: importantWords,
      details: cardResults,
    };

  } catch (error) {
    console.error('Error in genCardsFlow:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to generate cards',
      { originalError: error instanceof Error ? error.message : String(error) }
    );
  }
});