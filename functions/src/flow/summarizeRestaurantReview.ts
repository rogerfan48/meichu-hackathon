import { gemini25FlashPreview0417 } from "@genkit-ai/vertexai";
import { ai } from "../config";
import { z } from "genkit";
import * as admin from 'firebase-admin';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

// New AI Prompt for verifying the restaurant summary
const restaurantSummaryVerifier = ai.definePrompt({
    model: gemini25FlashPreview0417,
    name: "restaurantSummaryVerifier",
    input: { schema: z.string() }, // Input is the generated summary text
    output: {
        schema: z.object({
            meetsCriteria: z.boolean(),
            feedback: z.string().optional(),
        }),
        format: "json",
    },
    messages: (summaryToVerify) => {
        return [
            {
                role: "system",
                content: [
                    { text: "You are an AI assistant that verifies if a given restaurant summary meets specific criteria. Respond strictly in JSON format." }
                ],
            },
            {
                role: "user",
                content: [
                    {
                        text: `Please verify if the following restaurant summary meets ALL the specified criteria.
Summary to verify:
"${summaryToVerify}"

First, understand the structure to identify Paragraph 1 and Paragraph 2:
- The summary MUST contain Paragraph 1. Paragraph 1 cannot be empty.
- Paragraph 1 might be the ONLY paragraph present in the "Summary to verify". In this case, Paragraph 2 is considered implicitly empty.
- Alternatively, Paragraph 1 can be followed by a single newline character and then Paragraph 2. If Paragraph 2 is present after a newline, it must be a review summary (not an empty string after the newline if a P2 is intended).
- An entirely empty "Summary to verify" or a summary with more than two paragraphs (i.e., more than one newline character) is structurally invalid.

Criteria:

A.  **Paragraph 1 (Dish Types Description)**:
    *   This paragraph MUST always be present and meet all its criteria.
    1.  Length: Approximately 5-50 Traditional Chinese characters.
    2.  Content: Describes the restaurant's general dish types. This paragraph is NOT based on customer reviews.
    3.  Language: Must be in Traditional Chinese.
    4.  Style: Remove subjects, use only descriptive sentences.
    5.  Objectivity: No subjective opinions (e.g., "recommend", "not recommend").

B.  **Paragraph 2 (Review Summary / Implicitly Empty)**:
    *   This paragraph's state is determined by the nature of the input reviews (as decided by the generator).
    1.  **If Paragraph 2 is implicitly empty (because only Paragraph 1 was provided in the "Summary to verify")):**
        This is an acceptable state for Paragraph 2. It is presumed this occurs if the generator determined reviews were unsuitable for summary (e.g., all negative without concrete reasons, too few/vague, or predominantly subjective without actionable details).
        If Paragraph 1 is valid and Paragraph 2 is implicitly empty, the overall summary meets criteria.
    2.  **If Paragraph 2 is a review summary (i.e., text is present after a newline following Paragraph 1):**
        a.  Length: Approximately 5-50 Traditional Chinese characters.
        b.  Content Source: Must be entirely based on the provided customer reviews; no self-generated information.
        c.  Focus: Highlights common themes, positive/negative viewpoints from reviews.
        d.  Clarity: Clear and easy to understand.
        e.  Negative Comments Handling:
            i.  Ignore negative reviews if no reason is provided.
            ii. Negative content should be significant (e.g., represent over 40% of overall review sentiment) AND have reasons to be included.
        f.  Objectivity: No subjective opinions (e.g., "recommend", "not recommend").
        g.  Language: Must be in Traditional Chinese.
        h.  Style: Remove subjects, use only descriptive sentences.
        If these conditions for Paragraph 2 are met (and Paragraph 1 is valid), the overall summary meets criteria.

Respond with a JSON object: \`{ "meetsCriteria": boolean, "feedback": "concise, actionable feedback if not met, otherwise a brief confirmation or null" }\`.
If \`meetsCriteria\` is false, provide specific feedback on which paragraph and criterion failed.
If \`meetsCriteria\` is true, feedback can be null or a short confirmation (e.g., "Meets all criteria. Paragraph 1 valid; Paragraph 2 appropriately empty.", "Meets all criteria. Paragraph 1 and Paragraph 2 are valid.").`
                    }
                ],
            },
        ];
    },
});

const restaurantReviewGenerator = ai.definePrompt({
    model: gemini25FlashPreview0417,
    name: "restaurantReviewGenerator",
    input: { schema: z.object({
        dishNames: z.string(), // For context for Paragraph 1
        reviews: z.string(),
        feedback: z.string().optional(),
    })  },
    messages: (input) => {
        const baseUserPrompt = `Your task is to generate a restaurant summary.
Do NOT output your reasoning or any explanation, and the summary should not contradict itself. 

**Paragraph 1 (Mandatory - Dish Types Description):**
- Generate a description of the restaurant's general dish types. This paragraph is NOT based on customer reviews. You can use the provided "Restaurant Dish Names" for context if helpful.
- Length: Approximately 5-50 Traditional Chinese characters.
- Language: Traditional Chinese.
- Style: Remove subjects, use only descriptive sentences.
- Objectivity: No subjective opinions (e.g., "recommend", "not recommend").
- This paragraph MUST be generated.

**Paragraph 2 (Conditional - Review Summary or Omitted):**
After crafting Paragraph 1, analyze the provided "Customer Reviews" to determine if a meaningful summary for Paragraph 2 can be formed:
- **Condition for OMITTING Paragraph 2 (Output only Paragraph 1):** If ALL input reviews are negative AND lack concrete reasons, OR if the reviews are too few or too vague to form any meaningful summary, OR if the reviews are predominantly purely subjective opinions without actionable reasons or concrete details, THEN DO NOT generate Paragraph 2.
- **Condition for GENERATING Paragraph 2 (Review Summary):** Otherwise (if reviews can be meaningfully summarized based on the above), THEN Paragraph 2 should be a summary of the reviews:
    - Length: Approximately 5-50 Traditional Chinese characters.
    - Content Source: Must be entirely based on the provided customer reviews; no self-generated information.
    - Focus: Highlights common themes, positive/negative viewpoints from reviews.
    - Negative Comments Handling: Ignore negative reviews if no reason is provided. Include if negative content is significant (e.g., represents over 40% of overall review sentiment) AND a reason is provided.
    - Language: Traditional Chinese.
    - Style: Remove subjects, use only descriptive sentences.
    - Order: Describe advantages first, then disadvantages.
    - Objectivity: No subjective opinions (e.g., "recommend", "not recommend").

**Output Format (Very Important):**
- If Paragraph 2 is OMITTED (due to the conditions specified above), your entire output for this task should be ONLY the text of Paragraph 1. Do NOT add a newline character after Paragraph 1 in this case.
- If Paragraph 2 is GENERATED, your entire output for this task should be:
  (Paragraph 1 text)
  (A single newline character)
  (Paragraph 2 text)

Customer Reviews to process for Paragraph 2:
${input.reviews}

Restaurant Dish Names (for context for Paragraph 1, if needed):
${input.dishNames}
`;
        
        const userContent = [];
        if (input.feedback) {
            userContent.push({
                text: `An earlier summary attempt was not satisfactory. Please try again, paying close attention to the following feedback: "${input.feedback}". Ensure the new summary addresses these points while still adhering to ALL original instructions for Paragraph 1 and the conditional generation/omission of Paragraph 2, including the specified output format.`
            });
        }
        userContent.push({ text: baseUserPrompt });

        return [
            {
                role: "system",
                content: [
                    { text: `You are a smart assistant that generates concise restaurant summaries in Traditional Chinese. Follow the user's instructions for paragraph generation and output format precisely.` }
                ],
            },
            {
                role: "user",
                content: userContent,
            },
        ];
    },
});

async function findAllDishes(restaurantId: string): Promise<string[]> {
    try {
        const dishesSnapshot = await db
            .collection('apps')
            .doc('foodie')
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menu')
            .get();

        if (dishesSnapshot.empty) {
            console.log(`No dishes found for restaurant ID: ${restaurantId}`);
            return [];
        }

        const dishNames: string[] = [];
        dishesSnapshot.forEach(dishDoc => {
            const dishData = dishDoc.data();
            if (dishData && dishData.dishName) {
                dishNames.push(dishData.dishName);
            } else {
                console.warn(`Dish document ${dishDoc.id} in restaurant ${restaurantId} is missing a dishName.`);
            }
        });

        return dishNames;
    } catch (error) {
        console.error(`Error finding all dishes for restaurant ${restaurantId}:`, error);
        return []; // Return empty array on error
    }
}

export const summarizeRestaurantReviewFlow = ai.defineFlow({
    name: "summarizeRestaurantReviewFlow",
    inputSchema: z.object({
        restaurandId: z.string().describe("The ID of the restaurant to summarize reviews for"),
        reviews: z.array(z.string()).describe("Array of restaurant reviews to summarize"),
    }),
    outputSchema: z.string(),
},
    async (input) => {
        const { restaurandId, reviews } = input;
        const dishNames = await findAllDishes(restaurandId);
        const dishNamesText = dishNames.join(", ") || "Not available"; // Provide a fallback for dish names
        const reviewTexts = reviews.map((review, idx) => `Review ${idx + 1}: ${review}`).join("\n\n");
        
        let summary = "No summary generated.";
        let currentFeedback: string | undefined = undefined;
        const maxAttempts = 5;

        for (let attempt = 0; attempt < maxAttempts; attempt++) {
            console.log(`Restaurant summarization attempt ${attempt + 1}/${maxAttempts}`);
            if (currentFeedback) {
                console.log(`Using feedback from previous attempt: ${currentFeedback}`);
            }

            const generatorResponse = await restaurantReviewGenerator({
                dishNames: dishNamesText,
                reviews: reviewTexts,
                feedback: currentFeedback
            });
            
            const generatedText = typeof generatorResponse === "string" ? generatorResponse : generatorResponse.text;

            if (!generatedText || generatedText.trim() === "") {
                summary = "Generator produced empty or invalid text.";
                currentFeedback = "The generator produced empty text. Please try to generate a valid summary based on the original criteria for both paragraphs.";
                console.warn(summary);
                if (attempt === maxAttempts - 1) {
                    return `Failed to generate restaurant summary after ${maxAttempts} attempts. Last error: ${summary}`;
                }
                continue;
            }
            summary = generatedText;
            console.log(`Generated restaurant summary (attempt ${attempt + 1}): "${summary}"`);

            try {
                const verificationResult = await restaurantSummaryVerifier(summary);

                if (verificationResult.output && verificationResult.output.meetsCriteria) {
                    console.log("Restaurant summary meets criteria. Final summary:", summary);
                    return summary;
                } else {
                    currentFeedback = verificationResult.output?.feedback ?? "The restaurant summary did not meet unspecified criteria. Please try to improve it based on the original requirements for both paragraphs.";
                    console.log(`Restaurant summary did not meet criteria (attempt ${attempt + 1}). Feedback: "${currentFeedback}"`);
                    if (attempt === maxAttempts - 1) {
                        return `Failed to generate a satisfactory restaurant summary after ${maxAttempts} attempts. Last attempt: "${summary}". Final feedback: "${currentFeedback}"`;
                    }
                }
            } catch (error) {
                console.error("Error during restaurant summary verification:", error);
                currentFeedback = "There was an error verifying the restaurant summary. Please try generating again, focusing on all original criteria for both paragraphs.";
                if (attempt === maxAttempts - 1) {
                    return `Failed to verify restaurant summary after ${maxAttempts} attempts. Last attempt: "${summary}". Error: ${error instanceof Error ? error.message : String(error)}`;
                }
            }
        }
        return `Failed to produce a satisfactory restaurant summary after ${maxAttempts} attempts. Last generated summary: "${summary}"`;
    }
)