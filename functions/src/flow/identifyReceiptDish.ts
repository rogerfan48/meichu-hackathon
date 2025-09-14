import * as admin from 'firebase-admin';
import * as z from 'zod';
import { ai } from "../config";
// import { defineFlow, definePrompt } from '@genkit-ai/flow';
import { gemini25FlashPreview0417 } from "@genkit-ai/vertexai";
import { ImageAnnotatorClient } from '@google-cloud/vision';

// Initialize Firebase Admin SDK if not already initialized
if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

// Initialize Google Cloud Vision client
const visionClient = new ImageAnnotatorClient();

// Helper function to extract text from an image using Google Cloud Vision API
async function extractTextFromImage(imageUrl: string): Promise<string> {
  try {
    console.log(`[identifyReceiptDishFlow] Extracting text from image URL: ${imageUrl}`);
    const [result] = await visionClient.documentTextDetection(imageUrl);
    const fullTextAnnotation = result.fullTextAnnotation;
    if (fullTextAnnotation && fullTextAnnotation.text) {
      console.log(`[identifyReceiptDishFlow] OCR extracted text length: ${fullTextAnnotation.text.length}`);
      return fullTextAnnotation.text;
    }
    console.log('[identifyReceiptDishFlow] OCR: No text found or annotation was empty.');
    return '';
  } catch (error) {
    console.error('[identifyReceiptDishFlow] Error during OCR:', error);
    throw new Error(`OCR failed: ${error instanceof Error ? error.message : String(error)}`);
  }
}

// Interface for dish data
interface Dish {
  id: string;
  name: string;
}

// Helper function to get all dishes for a given restaurantID from Firestore
async function getAllDishesForRestaurant(restaurantId: string): Promise<Dish[]> {
  console.log(`[identifyReceiptDishFlow] Fetching dishes for restaurant ID: ${restaurantId}`);
  const menuRef = db.collection(`apps/foodie/restaurants/${restaurantId}/menu`);
  const snapshot = await menuRef.get();

  if (snapshot.empty) {
    console.log(`[identifyReceiptDishFlow] No dishes found in menu for restaurant ${restaurantId}.`);
    return [];
  }

  const dishes: Dish[] = [];
  snapshot.forEach(doc => {
    const data = doc.data();
    // Assuming dish documents have a 'dishName' field (adjust if different)
    if (data && typeof data.dishName === 'string' && data.dishName.trim() !== '') {
      dishes.push({ id: doc.id, name: data.dishName.trim() });
    } else {
      console.warn(`[identifyReceiptDishFlow] Dish document ${doc.id} for restaurant ${restaurantId} is missing dishName or it's not a string.`);
    }
  });
  console.log(`[identifyReceiptDishFlow] Fetched ${dishes.length} dishes for restaurant ${restaurantId}.`);
  return dishes;
}

// AI Prompt to identify dishes from OCR text
const dishFinderPrompt = ai.definePrompt({
  name: 'dishFinderFromReceipt',
  model: gemini25FlashPreview0417, // Ensure this model is configured in your Genkit setup
  input: {
    schema: z.object({
      ocrText: z.string(),
      restaurantDishNames: z.array(z.string()),
    }),
  },
  output: {
    schema: z.object({
      foundDishNames: z.array(z.string()).describe('An array of dish names from the provided list that were found in the OCR text.'),
    }),
  },
  messages: (input) => {
    return [
      {
        role: 'system',
        content: [
          {
            text: `You are an intelligent assistant. Your task is to analyze text extracted from a food receipt and identify which dishes from a provided restaurant menu list are mentioned in that receipt text.
          Only return dish names that are present in the provided "Restaurant Dish Names" list.
          Be precise and avoid guessing. If a dish name from the list appears in the receipt, include it.
          The output must be a JSON object with a single key "foundDishNames" which contains an array of strings.`
          }
        ]
      },
      {
        role: 'user',
        content: [
          {
            text: `
            I have the following text extracted from a customer's food receipt:
            --- Receipt OCR Text ---
            ${input.ocrText}
            --- End Receipt OCR Text ---

            Here is the list of available dish names from this restaurant's menu:
            --- Restaurant Dish Names ---
            ${input.restaurantDishNames.join('\n')}
            --- End Restaurant Dish Names ---

            Please identify which of the "Restaurant Dish Names" are present in the "Receipt OCR Text".
            Return your answer as a JSON object with a single key "foundDishNames", where the value is a JSON array of the identified dish name strings.
            For example: {"foundDishNames": ["Margherita Pizza", "Caesar Salad"]}
            If no dishes from the list are found in the receipt text, return {"foundDishNames": []}.
            Ensure that the names you return are exactly as they appear in the "Restaurant Dish Names" list.
          `
          }
        ]
      }
    ];
  }
});

// The main flow
export const identifyReceiptDishFlow = ai.defineFlow(
  {
    name: 'identifyReceiptDishFlow',
    inputSchema: z.object({
      restaurantId: z.string().describe("The ID of the restaurant."),
      receiptImageUrl: z.string().url().describe('A publicly accessible URL of the receipt image.'),
    }),
    outputSchema: z.array(z.string()).describe('An array of dishIDs found in the receipt. Returns an empty array if no matches or errors.'),
  },
  async (input) => {
    console.log(`[identifyReceiptDishFlow] Starting flow for restaurant: ${input.restaurantId}, image: ${input.receiptImageUrl}`);

    let ocrText: string;
    try {
      ocrText = await extractTextFromImage(input.receiptImageUrl);
    } catch (e) {
      console.error('[identifyReceiptDishFlow] OCR step failed:', e);
      return []; // Return empty on OCR failure
    }

    if (!ocrText.trim()) {
      console.log('[identifyReceiptDishFlow] OCR did not yield any text. Exiting.');
      return [];
    }

    const allRestaurantDishes = await getAllDishesForRestaurant(input.restaurantId);
    if (allRestaurantDishes.length === 0) {
      console.log(`[identifyReceiptDishFlow] No dishes available for restaurant ${input.restaurantId} to match against. Exiting.`);
      return [];
    }

    const dishNamesFromMenu = allRestaurantDishes.map(dish => dish.name);

    let aiMatchResult;
    try {
      console.log('[identifyReceiptDishFlow] Calling AI to find matching dishes...');
      aiMatchResult = await dishFinderPrompt({
        ocrText: ocrText,
        restaurantDishNames: dishNamesFromMenu,
      });
    } catch (e) {
        console.error('[identifyReceiptDishFlow] AI dish matching failed:', e);
        return [];
    }
    

    const foundDishNamesByAI = aiMatchResult.output?.foundDishNames;

    if (!foundDishNamesByAI || !Array.isArray(foundDishNamesByAI)) {
      console.warn('[identifyReceiptDishFlow] AI did not return the expected array of dish names. Output:', aiMatchResult.output);
      return [];
    }

    if (foundDishNamesByAI.length === 0) {
      console.log('[identifyReceiptDishFlow] AI found no matching dishes from the list in the OCR text.');
      return [];
    }
    console.log(`[identifyReceiptDishFlow] AI identified dish names: ${foundDishNamesByAI.join(', ')}`);

    // Map the found dish names back to their IDs
    // Creating a map for efficient lookup, assuming dish names are unique (case-insensitive for robustness)
    const dishNameToIdMap = new Map<string, string>();
    allRestaurantDishes.forEach(dish => {
      dishNameToIdMap.set(dish.name.toLowerCase(), dish.id);
    });

    const matchedDishIDs = new Set<string>();
    foundDishNamesByAI.forEach((name: string) => {
      // The AI is instructed to return exact names from the list.
      // Lookup can be direct, but a case-insensitive lookup is more robust if AI casing varies.
      const dishId = dishNameToIdMap.get(name.toLowerCase());
      if (dishId) {
        matchedDishIDs.add(dishId);
      } else {
        console.warn(`[identifyReceiptDishFlow] AI returned dish name "${name}" which was not found in the restaurant's dish list (after toLowerCase check). This might indicate an AI hallucination or a mismatch in the provided dish list vs. AI's understanding.`);
      }
    });
    
    const finalDishIds = Array.from(matchedDishIDs);
    console.log(`[identifyReceiptDishFlow] Final matched dish IDs: ${finalDishIds.join(', ')}`);
    return finalDishIds;
  }
);