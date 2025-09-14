// filepath: c:\WorkspaceFlutter\foodie\functions\src\flow\recommendRestaurant.ts
import { gemini25FlashPreview0417 } from "@genkit-ai/vertexai";
import { ai } from "../config"; // Your Genkit AI configuration
import { z } from "genkit";
import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK.
if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

interface Dish {
    name: string;
    bestReviewSummary: string;
    price: number;
}

interface Restaurant {
    restaurantId: string;
    name: string;
    dishes: Dish[];
    genreTags: string[];
}

interface Review {
    reviewID: string; // Document ID
    restaurantID: string;
    userID?: string; // Optional, if needed
    reviewImgURLs: string[];
    reviewDate: admin.firestore.Timestamp; // For sorting by recency
    agreedByCount?: number; // Optional, if you want to sort by reactions later
    // Add other fields like 'agreedByCount' if you want to sort by reactions later
}

// Define Zod schemas for the output
const RecommendedRestaurantSchema = z.object({
  id: z.string(),
  name: z.string(),
  imageUrl: z.string().nullable(),
});

// Simplified FlowOutputSchema using a plain object
const FlowOutputSchema = z.object({
    type: z.string(),
    text: z.string().describe("For a question, this is the question text. For a recommendation, this is the 'recommend_text' explaining the recommendation."),
    restaurants: z.array(RecommendedRestaurantSchema).optional().describe("An array of recommended restaurants. Only present if the output is a recommendation."),
});

async function findAllReviews(): Promise<Review[]> {
    try {
        // Assuming reviews are stored in a top-level collection: /apps/foodie/reviews
        // Adjust if your structure is different (e.g., subcollections or collectionGroup)
        const reviewsSnapshot = await db.collection('apps').doc('foodie').collection('reviews').get();
        if (reviewsSnapshot.empty) {
            return [];
        }
        const reviews: Review[] = [];
        reviewsSnapshot.forEach(doc => {
            const data = doc.data();
            const agreeCount = (data.agreedBy && Array.isArray(data.agreedBy)) ? data.agreedBy.length : 0;
            const disagreeCount = typeof data.disag === 'number' ? data.disag : 0; // Assumes data.disag is a number

            reviews.push({
                reviewID: doc.id,
                restaurantID: data.restaurantID,
                reviewImgURLs: data.reviewImgURLs || [],
                reviewDate: data.reviewDate || admin.firestore.Timestamp.now(), // Ensure a valid Timestamp
                agreedByCount: (agreeCount - disagreeCount), // Calculate net count
                // Map other fields from your review document to the Review interface
            } as Review);
        });
        return reviews;
    } catch (error) {
        console.error("Error finding all reviews:", error);
        return [];
    }
}

// Helper function to get the best image for a restaurant from its reviews
function getBestImageForRestaurant(restaurantId: string, allReviews: Review[]): string | null {
    const restaurantReviews = allReviews.filter(r => r.restaurantID === restaurantId);
    const reviewsWithImages = restaurantReviews.filter(r => r.reviewImgURLs && r.reviewImgURLs.length > 0);

    if (reviewsWithImages.length === 0) {
        return null;
    }

    // Sort by agreedByCount descending (highest first), then by reviewDate descending (most recent first)
    reviewsWithImages.sort((a, b) => {
        const agreedByCountA = a.agreedByCount || 0;
        const agreedByCountB = b.agreedByCount || 0;

        return agreedByCountB - agreedByCountA; // Sort by agreedByCount descending
    });

    // Return the first image URL from the best-rated (or most recent among ties) review that has images
    return reviewsWithImages[0].reviewImgURLs[0];
}

// Helper function to fetch user's viewed restaurant IDs
async function getUserViewedRestaurantIds(userId: string): Promise<string[]> {
    try {
        const userDocRef = db.collection('apps').doc('foodie').collection('users').doc(userId);
        const userDoc = await userDocRef.get();

        if (userDoc.exists) {
            const userData = userDoc.data();
            const viewedRestaurantIDsMap = userData?.viewedRestaurantIDs;

            if (viewedRestaurantIDsMap && typeof viewedRestaurantIDsMap === 'object' && Object.keys(viewedRestaurantIDsMap).length > 0) {
                // This array will store individual view events, not just the latest per restaurant
                const allViewEvents: { restaurantId: string; viewDate: Date }[] = [];

                for (const restaurantId in viewedRestaurantIDsMap) {
                    if (Object.prototype.hasOwnProperty.call(viewedRestaurantIDsMap, restaurantId)) {
                        const viewDatesArray = viewedRestaurantIDsMap[restaurantId];
                        if (Array.isArray(viewDatesArray) && viewDatesArray.length > 0) {
                            const validDates = viewDatesArray
                                .map(dateStr => new Date(dateStr))
                                .filter(date => !isNaN(date.getTime()));

                            // Instead of finding the latest, add each valid date as a separate event
                            validDates.forEach(date => {
                                allViewEvents.push({ restaurantId, viewDate: date });
                            });
                        }
                    }
                }

                // Sort all view events by viewDate in descending order (most recent first)
                allViewEvents.sort((a, b) => b.viewDate.getTime() - a.viewDate.getTime());

                // Map to restaurant IDs. This list may contain duplicates.
                return allViewEvents.map(item => item.restaurantId);
            } else {
                if (!viewedRestaurantIDsMap || Object.keys(viewedRestaurantIDsMap).length === 0) {
                    // console.log(`User ${userId} has no viewed restaurants in viewedRestaurantIDsMap.`);
                } else {
                    console.error(`User ${userId} has viewedRestaurantIDsMap, but it's not in the expected format or is empty.`);
                }
            }
        } else {
            // console.log(`User document not found for ${userId}.`);
        }
        return [];
    } catch (error) {
        console.error(`Error fetching user history for ${userId}:`, error);
        return []; // Return empty array on error
    }
}

// Helper function to find all restaurants with their dishes
async function findAllRestaurants(): Promise<Restaurant[]> {
    try {
        const restaurantsSnapshot = await db.collection('apps').doc('foodie').collection('restaurants').get();

        if (restaurantsSnapshot.empty) {
            return [];
        }

        const restaurants: Restaurant[] = [];

        for (const restaurantDoc of restaurantsSnapshot.docs) {
            const restaurantId = restaurantDoc.id;
            const restaurantData = restaurantDoc.data();

            // Fetch dishes for the current restaurant
            const dishesSnapshot = await db
                .collection('apps')
                .doc('foodie')
                .collection('restaurants')
                .doc(restaurantId)
                .collection('menu')
                .get();

            const dishes: Dish[] = [];
            if (!dishesSnapshot.empty) {
                dishesSnapshot.forEach(dishDoc => {
                    const dishData = dishDoc.data();
                    // Assuming dish documents match the Dish interface
                    dishes.push({
                        name: dishData.dishName || 'Unknown Dish',
                        bestReviewSummary: dishData.bestReviewSummary || '',
                        price: dishData.dishPrice || 0,
                    } as Dish);
                });
            }

            restaurants.push({
                restaurantId: restaurantId,
                name: restaurantData.restaurantName || 'Unknown Restaurant',
                genreTags: restaurantData.genreTags || [],
                dishes: dishes,
            } as Restaurant);
        }
        return restaurants;
    } catch (error) {
        console.error("Error finding all restaurants:", error);
        return []; // Return empty array on error
    }
}

// New helper function for generating history summary, extracted from recommendationPrompt.messages
async function generateHistoryRestaurantNameForPrompt(
    viewedRestaurantIds: string[],
    allRestaurantsData: Restaurant[],
    userId: string
): Promise<string> {
    let historySummary = "No viewing history available.";

    if (viewedRestaurantIds.length > 0) {
        // Use allRestaurantsData to find names for viewedRestaurantIDs
        const viewedNames = viewedRestaurantIds.map(id => {
            const foundRestaurant = allRestaurantsData.find(r => r.restaurantId === id);
            return foundRestaurant ? foundRestaurant.name : null;
        }).filter(Boolean).join(', ');

        if (viewedNames) {
            historySummary = `User has recently viewed restaurants: ${viewedNames}.`;
        } else {
            // This case might happen if viewed IDs are stale and not in current allRestaurantsData
            historySummary = `User has recently viewed restaurants with IDs: ${viewedRestaurantIds.join(', ')} (names could not be found in current restaurant list).`;
        }
    } else if ((await db.collection('apps').doc('foodie').collection('users').doc(userId).get()).exists) {
        historySummary = "User has no recorded viewing history.";
        console.warn(`User ${userId} has no viewedRestaurantIDs or document exists but no history.`);
    } else {
        historySummary = "User document not found or no viewing history.";
        console.warn(`User ${userId} document not found or has no viewing history.`);
    }
    return historySummary;
}

// New helper function for generating the all restaurants prompt section
function generateAllRestaurantsInfoForPrompt(allRestaurantsData: Restaurant[]): string {
    let section = "No restaurants found in the database.";
    if (allRestaurantsData.length > 0) {
        section = "Here is a list of all available restaurants and their details:\n";
        allRestaurantsData.forEach(restaurant => {
            section += `\nRestaurant Name: ${restaurant.name} (ID: ${restaurant.restaurantId})\n`;
            section += `Genre Tags: ${restaurant.genreTags.join(', ') || 'N/A'}\n`;
            if (restaurant.dishes.length > 0) {
                section += "Dishes:\n";
                restaurant.dishes.forEach(dish => {
                    section += `  - Name: ${dish.name}, Price: ${dish.price}, Review Summary: ${dish.bestReviewSummary || 'N/A'}\n`;
                });
            } else {
                section += "Dishes: No dishes listed.\n";
            }
        });
        // Consider truncating if too long:
        // const MAX_PROMPT_RESTAURANTS_SECTION_LENGTH = 5000; // Adjust as needed
        // if (section.length > MAX_PROMPT_RESTAURANTS_SECTION_LENGTH) {
        //    section = section.substring(0, MAX_PROMPT_RESTAURANTS_SECTION_LENGTH) + "\n... (list truncated due to length)";
        // }
    }
    return section;
}

const recommendationPrompt = ai.definePrompt({
    model: gemini25FlashPreview0417,
    name: "recommendationPrompt",
    input: { schema: z.object({ // Ensure this was corrected from input: {schema: ...}
        viewedRestaurantIds: z.array(z.string()).describe("List of restaurant IDs the user has viewed."),
        allRestaurantsData: z.array(
            z.object({ 
                restaurantId: z.string(),
                name: z.string(),
                genreTags: z.array(z.string()),
                dishes: z.array(
                    z.object({
                        name: z.string(),
                        bestReviewSummary: z.string(),
                        price: z.number(),
                    })),
            })).describe("List of all restaurants with their details."),
        messages: z.array(
            z.object({
                isUser: z.boolean(),
                text: z.string(),
            })).describe("The history of messages in the conversation.").optional(),
        userId: z.string().describe("The ID of the user requesting recommendations.")
    })},
    messages: async (input) => {
        const { viewedRestaurantIds, allRestaurantsData, messages, userId } = input;
        
        const historySummary = await generateHistoryRestaurantNameForPrompt(viewedRestaurantIds, allRestaurantsData, userId);
        const allRestaurantsPromptSection = generateAllRestaurantsInfoForPrompt(allRestaurantsData);

        let userConversationHistoryText = '';
        if (messages && messages.length > 0) {
            interface ConversationMessage {
                isUser: boolean;
                text: string;
            }
            const typedMessages: ConversationMessage[] = messages;
            typedMessages.forEach((msg: ConversationMessage) => {
                userConversationHistoryText += `${msg.isUser ? 'User' : 'Assistant'}: ${msg.text}\n`;
            });
        } else {
            userConversationHistoryText = "No previous conversation turns.\n";
        }

        const systemContext =
`IMPORTANT: Your entire response MUST be in Traditional Chinese.

You are a friendly and helpful restaurant recommendation assistant.
User's recent restaurant browsing history (from latest to oldest):
${historySummary}

All available restaurants in our database:
${allRestaurantsPromptSection}

Your primary goal is to recommend suitable restaurants from the provided list or ask clarifying questions.
Analyze the user's request, their viewing history, and the conversation. **Prioritize explicit user statements and recent conversation turns over past browsing history when deciding what to recommend. The browsing history is a secondary reference point and should not heavily dictate the recommendations if more direct information is available.**

IMPORTANT (Content Strategy): Your goal is to provide relevant recommendations.

1.  RECOMMEND restaurants if ANY of the following conditions are met:
    a.  The user explicitly states a clear preference (e.g., specific cuisine, dish, price range, occasion), OR the conversation history provides clear and specific clues about their current preferences.
    b.  The user explicitly asks you to decide, expresses indecisiveness, or indicates they have no specific preference (e.g., "幫我決定", "你幫我選", "我不知道", "沒想法", "隨便", "你推薦就好", "I don't know", "no idea", "surprise me", "you choose").
    c.  The user's LATEST message is still vague (e.g., "我還是不知道", "隨便", "都可以", "你覺得呢?") AFTER you (the assistant) asked a clarifying question in your IMMEDIATELY PREVIOUS turn (check the conversation history). This indicates the user remains undecided even after being prompted for more details.
        In cases 1.b or 1.c, your strategy should be to select 2-3 diverse and appealing restaurants from the 'All available restaurants' list. You can pick based on general popularity, unique offerings, or a mix of cuisines if the list is varied. The goal is to provide good starting points for an undecided user.

    If recommending (due to 1.a, 1.b, or 1.c), you SHOULD recommend.
    Output the recommended restaurant IDs and a 'recommend_text'. The format MUST be:
    RECOMMEND: {"recommend_text": "A friendly and appealing message for the USER, in Traditional Chinese, directly highlighting what's special or good about the recommended restaurants. Focus *only* on the unique features, atmosphere, popular dishes, or positive reviews of the restaurants themselves. Do NOT mention why you are recommending them (e.g., do not say 'based on your history', 'since you were looking at similar places', 'because you liked X', 'since you asked me to choose', or 'since you're still unsure'). For example (translate these to Traditional Chinese in your actual output): 'These spots are known for their fiery curries and vibrant flavors!' or 'These restaurants offer amazing pasta and a great atmosphere for a cozy Italian dinner.' or 'You'll find exceptionally fresh seafood and a beautiful ocean view at these places.'", "restaurant_ids": ["restaurantId1", "restaurantId2"]}
    (The "recommend_text" is for the end-user and should make them want to try the places. The "restaurant_ids" MUST be from the 'All available restaurants' list.)

2.  ASK a question if the conditions for recommending in section 1 are NOT met.
    This typically occurs if the user's INITIAL input is vague (e.g., "我餓了," "推薦一些好吃的," "I'm hungry," "suggest something good") or provides no clear direction, AND they are not explicitly deferring the choice to you, AND it's not a follow-up to your clarifying question where they remain vague (as covered in 1.c).
    In this scenario, ask a single, clear, plain text question in Traditional Chinese to get the missing piece of information. This question should aim to clarify their general preferences.
    The format MUST be (ensure the entire string is in Traditional Chinese in your actual output):
    ASK: 為了能更好地為您推薦，可以多告訴我一些您的喜好嗎？例如，您有沒有想吃的菜系，或者這次用餐有什麼特別的場合或心情呢？或是您想要我直接推薦你幾間餐廳嗎？
    (or similar, but always in Traditional Chinese)

Do not add any explanatory text before "RECOMMEND:" or "ASK:". Your entire response should start with one of these keywords. Your entire response MUST be in Traditional Chinese.
`;
        return [
            { role: "system", content: [{ text: systemContext }] },
            { role: "user", content: [{ text: userConversationHistoryText + "\nAssistant, what is your response based on the above context and instructions?" }] } 
        ];
    }
});

export const recommendRestaurantFlow = ai.defineFlow(
    {
        name: "recommendRestaurantFlow",
        inputSchema: z.object({
            userId: z.string().min(1, { message: "User ID cannot be empty." })
                .describe("The ID of the user requesting recommendations."),
            messages: z.array(
                z.object({
                    isUser: z.boolean().describe("True if the message is from the user, false if from the AI."),
                    text: z.string().describe("The text content of the message."),
                })
            ).describe("The history of messages in the conversation."),
        }),
        outputSchema: FlowOutputSchema, // Use the simplified schema
    },
    async (input): Promise<z.infer<typeof FlowOutputSchema>> => {
        const { userId, messages } = input;

        const viewedRestaurantIDs = await getUserViewedRestaurantIds(userId);
        const allRestaurantsData = await findAllRestaurants(); 
        const allReviewsData = await findAllReviews();

        // Ensure recommendationPrompt is called with .generate() and its inputSchema is correct
        const llmResponse = await recommendationPrompt({ 
            viewedRestaurantIds: viewedRestaurantIDs,
            allRestaurantsData: allRestaurantsData,
            messages: messages,
            userId: userId,
        });

        const llmOutput = llmResponse.text.trim(); // Ensure .text() is called

        if (llmOutput.startsWith("RECOMMEND:")) {
            try {
                const recommendStr = llmOutput.substring("RECOMMEND:".length).trim();
                const recommendData = JSON.parse(recommendStr);
        
                if (recommendData.restaurant_ids && Array.isArray(recommendData.restaurant_ids) && recommendData.restaurant_ids.length > 0 && recommendData.recommend_text) {
                    const recommendedRestaurantsOutput: z.infer<typeof RecommendedRestaurantSchema>[] = [];
        
                    for (const recId of recommendData.restaurant_ids) {
                        const restaurantInfo = allRestaurantsData.find(r => r.restaurantId === recId);
                        if (restaurantInfo) {
                            const imageUrl = getBestImageForRestaurant(recId, allReviewsData);
                            recommendedRestaurantsOutput.push({
                                id: restaurantInfo.restaurantId,
                                name: restaurantInfo.name,
                                imageUrl: imageUrl,
                            });
                        }
                    }
                    
                    if (recommendedRestaurantsOutput.length > 0) {
                        return {
                            type: "recommendation",
                            text: recommendData.recommend_text, 
                            restaurants: recommendedRestaurantsOutput,
                        };
                    } else {
                         return {
                            type: "question",
                            text: "I found some ideas, but couldn't fetch the details. Could you tell me more about what you like?",
                            // 'restaurants' field is absent, implying a question
                        };
                    }
                } else {
                    console.warn("LLM said RECOMMEND but didn't provide valid restaurant_ids or recommend_text:", recommendStr);
                    return {
                        type: "question",
                        text: "I was about to make a recommendation, but I need a bit more clarity. Could you specify your main preference again?",
                    };
                }
            } catch (error: any) {
                console.error("Error processing RECOMMEND action:", error);
                return {
                    type: "question",
                    text: "I had a little trouble processing the recommendation. What's your most important preference right now?",
                };
            }
        } else if (llmOutput.startsWith("ASK:")) {
            try {
                const questionText = llmOutput.substring("ASK:".length).trim();
                if (!questionText) {
                    throw new Error("LLM returned ASK: with no question text.");
                }
                return {
                    type: "question",
                    text: questionText,
                    // 'restaurants' field is absent, implying a question
                };
            } catch (error: any) {
                console.error("Error processing ASK action:", error);
                 return {
                    type: "question",
                    text: "I'm trying to figure out what to ask next! What's a general type of food you enjoy?",
                };
            }
        } else {
            console.warn("LLM output not recognized:", llmOutput);
            return {
                type: "question",
                text: "Let's try a different angle. Are you looking for a place for a specific occasion?",
            };
        }
    }
);

// Further Advice (adapted):
// 1.  **Firestore Data Structure:**
///     *   `/apps/foodie/users/{userId}`: Document should contain a field `viewedRestaurantIDs` (e.g., `viewedRestaurantIDs: ["id1", "id2"]`).
///     *   `/apps/foodie/restaurants/{restaurantId}`: Store comprehensive details.
/// 2.  **Prompt Engineering:** Crucial.
///     *   Refine `promptText` based on observed LLM behavior.
///     *   If the LLM struggles with the "RECOMMEND:" JSON or "ASK:" plain text format, provide few-shot examples in the prompt.
/// 3.  **History Summary for Prompt:** The current summary is basic (list of IDs). To improve LLM context, you could fetch details (cuisine, name) for a few of these `viewedRestaurantIDs`. This would involve more Firestore reads.
///     Example enhancement for history fetching (conceptual):
///     ```typescript
///     // ... inside history fetching try block
///     if (Array.isArray(viewedRestaurantIDs) && viewedRestaurantIDs.length > 0) {
///         const recentRestaurantDetailsPromises = viewedRestaurantIDs.slice(0, 3).map(id =>
///             db.collection('apps').doc('foodie').collection('restaurants').doc(id).get()
///         );
///         const recentRestaurantSnapshots = await Promise.all(recentRestaurantDetailsPromises);
///         const details = recentRestaurantSnapshots
///             .map(snap => snap.exists ? snap.data() : null)
///             .filter(Boolean)
///             .map(r => `${r.name} (${r.cuisine || 'N/A'})`)
///             .join(', ');
///         historySummary = `User has recently viewed: ${details || 'some restaurants (details unavailable)'}.`;
///     }
///     // ...
///     ```
/// 4.  **Firestore Queries:** The query for recommendations is still basic. Expand it based on the criteria the LLM can provide.
/// 5.  **Error Handling & Fallbacks:** The plain text fallbacks are in place. Consider more sophisticated recovery or guidance for the user.
/// 6.  **Security Rules:** Ensure your Firestore security rules allow your Firebase Function to read `/apps/foodie/users/{userId}` and `/apps/foodie/restaurants/**`.