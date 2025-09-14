import { gemini25FlashPreview0417 } from "@genkit-ai/vertexai";
import { ai } from "../config";
import { z } from "genkit";

// New AI Prompt for verifying the summary
const dishSummaryVerifier = ai.definePrompt({
    model: gemini25FlashPreview0417, // You might consider a more powerful model for verification if needed
    name: "dishSummaryVerifier",
    input: { schema: z.string() }, // Input is the generated summary text
    output: {
        schema: z.object({
            meetsCriteria: z.boolean(),
            feedback: z.string().optional(), // Feedback for improvement if criteria are not met
        }),
        format: "json", // Ensure the output is JSON for easier parsing
    },
    messages: (summaryToVerify) => {
        return [
            {
                role: "system",
                content: [
                    { text: "You are an AI assistant that verifies if a given text meets specific criteria. Respond strictly in JSON format as specified." }
                ],
            },
            {
                role: "user",
                content: [
                    {
                        text: `Please verify if the following summary meets ALL the specified criteria.
Summary to verify:
"${summaryToVerify}"

A.  **Overall Output Check**:
    1.  If the "Summary to verify" is an empty string:
        This is considered to meet all criteria. It is presumed this occurs when the generator determined all input reviews were negative and lacked concrete reasons.
        Respond with \`{"meetsCriteria": true, "feedback": "Output is an empty string, presumed appropriate as all reviews may have been negative without concrete reasons."}\`.
        If the summary is an empty string, DO NOT evaluate against criteria B.

B.  **Non-Empty Output Check (if "Summary to verify" is not an empty string)**:
    1.  **Length**: Approximately 5-50 Traditional Chinese characters.
    2.  **Content Source**: Must be entirely based on customer reviews; no self-generated information.
    3.  **Focus**: Highlights most important points, common themes, positive/negative viewpoints, and any particularly prominent comments from the original reviews.
    4.  **Clarity**: Clear and easy to understand.
    5.  **Negative Comments Handling**:
        a.  Ignore negative reviews if no reason is provided.
        b.  Negative content should be significant (e.g., represent over 40% of overall review sentiment) to be included. (Assess qualitatively if precise quantification from summary alone is hard).
    6.  **Language**: Must be in Traditional Chinese.
    7.  **Style**: Remove subjects, use only descriptive sentences.

Respond with a JSON object of the following structure: \`{ "meetsCriteria": boolean, "feedback": "concise, actionable feedback for improvement if not met, otherwise a brief confirmation like 'Meets all criteria.' or null" }\`.
If \`meetsCriteria\` is false (and it's not an accepted empty string from section A), provide specific feedback on which criteria in section B were not met and how to improve.
If \`meetsCriteria\` is true, feedback can be null or a short confirmation.`
                    }
                ],
            },
        ];
    },
});

// Modified reviewGenerator to accept feedback
const dishReviewGenerator = ai.definePrompt({
    model: gemini25FlashPreview0417,
    name: "dishReviewGenerator",
    input: { schema: z.object({ reviews: z.string(), feedback: z.string().optional() }) },
    messages: (inputParams) => {
        const basePrompt = `IMPORTANT ASSESSMENT:
First, analyze ALL provided reviews.
Do NOT output your reasoning or any explanation, and the summary should not contradict itself. 
IF all reviews are negative AND all negative reviews lack concrete reasons, THEN your entire output for this task MUST be a completely empty string (i.e., generate no characters, no text, not even quotes).

IF THE ABOVE CONDITION IS NOT MET, proceed as follows:
請以一段約20-50字話總結這些評論，突顯最重要的重點，評論內容需完全根據顧客評論、不能自行生成，重點放在常見的主題、正面與負面觀點，以及任何特別突出的評論，並確保摘要清晰易懂。注意：若負面評論沒有說明原因必須忽略該評論，且該負面內容需占整體評論的40%以上才會納入考慮。輸出使用繁體中文，去除主詞，只保留描述句，先描述優點再描述缺點。以下為評論內容：\n\n${inputParams.reviews}`;
        
        const userContent = [];

        if (inputParams.feedback) {
            userContent.push({
                text: `An earlier summary attempt was not satisfactory. Please try again, paying close attention to the following feedback to improve the summary: "${inputParams.feedback}". Ensure the new summary addresses these points while still adhering to ALL original instructions, including the IMPORTANT ASSESSMENT for a completely empty output (no characters) if applicable.`
            });
        }
        userContent.push({ text: basePrompt });

        return [
            {
                role: "system",
                content: [
                    { text: "You are a smart assistant that can analyze lots of dish reviews based on the provided dish information." }
                ],
            },
            {
                role: "user",
                content: userContent,
            },
        ];
    },
});

export const summarizeDishReviewFlow = ai.defineFlow({
    name: "summarizeDishReviewFlow",
    inputSchema: z.array(z.string()),
    outputSchema: z.string(),
},
    async (inputReviews) => {
        const reviewTexts = inputReviews.map((review, idx) => `Review ${idx + 1}: ${review}`).join("\n\n");
        let summary = "No summary generated.";
        let currentFeedback: string | undefined = undefined;
        const maxAttempts = 5; // Maximum number of attempts to generate and verify

        for (let attempt = 0; attempt < maxAttempts; attempt++) {
            console.log(`Summarization attempt ${attempt + 1}/${maxAttempts}`);
            if (currentFeedback) {
                console.log(`Using feedback from previous attempt: ${currentFeedback}`);
            }

            // Generate summary
            const generatorResponse = await dishReviewGenerator({ reviews: reviewTexts, feedback: currentFeedback });
            // Ensure you are accessing the text property if generatorResponse is an object
            const generatedText = typeof generatorResponse === 'object' && generatorResponse.text ? generatorResponse.text : String(generatorResponse);


            // If the generator is meant to produce an empty string directly, this check is fine.
            // If it might produce an empty string *within* its structured output, adjust accordingly.
            if (generatedText.trim() === "" && attempt > 0) { // Allow initial empty string if that's the intended output
                 // If the generator is *supposed* to output an empty string under certain conditions,
                // we need to verify if this empty string is the *intended* valid output.
                // This requires the verifier to handle empty strings as potentially valid.
            } else if (!generatedText && attempt > 0) { // Handles null/undefined if generator can return that
                 summary = "Generator produced null or undefined text.";
                 currentFeedback = "The generator produced null or undefined text. Please try to generate a valid summary based on the original criteria or an empty string if appropriate.";
                 console.warn(summary);
                 if (attempt === maxAttempts - 1) {
                     return `Failed to generate summary after ${maxAttempts} attempts. Last error: ${summary}`;
                 }
                 continue;
            }


            summary = generatedText; // Assign even if it's an empty string
            console.log(`Generated summary (attempt ${attempt + 1}): "${summary}"`);

            // Verify the summary
            try {
                const verificationResult = await dishSummaryVerifier(summary); // Pass the potentially empty summary

                if (verificationResult.output && verificationResult.output.meetsCriteria) {
                    console.log("Summary meets criteria. Final summary:", summary);
                    return summary; // Success (this includes an intentionally empty summary if verifier allows it)
                } else {
                    // If the summary was empty but the verifier said it didn't meet criteria,
                    // it means the empty string was NOT considered valid by the verifier for this case.
                    if (summary.trim() === "" && !(verificationResult.output?.feedback?.includes("empty string, presumed appropriate"))) {
                        currentFeedback = "The generator produced an empty string, but the verifier indicated this was not appropriate for the given reviews. Please generate a non-empty summary adhering to all criteria.";
                    } else {
                         currentFeedback = verificationResult.output?.feedback ?? "The summary did not meet unspecified criteria. Please try to improve it based on the original requirements.";
                    }
                    console.log(`Summary did not meet criteria (attempt ${attempt + 1}). Feedback: "${currentFeedback}"`);
                    if (attempt === maxAttempts - 1) {
                        return `Failed to generate a satisfactory summary after ${maxAttempts} attempts. Last attempt: "${summary}". Final feedback: "${currentFeedback}"`;
                    }
                }
            } catch (error) {
                console.error("Error during summary verification:", error);
                currentFeedback = "There was an error verifying the summary. Please try generating again, focusing on all original criteria.";
                 if (attempt === maxAttempts - 1) {
                    return `Failed to verify summary after ${maxAttempts} attempts. Last attempt: "${summary}". Error: ${error instanceof Error ? error.message : String(error)}`;
                }
            }
        }
        // Fallback if loop finishes without returning (should be covered by return statements in the loop)
        return `Failed to produce a satisfactory summary after ${maxAttempts} attempts. Last generated summary: "${summary}"`;
    }
);