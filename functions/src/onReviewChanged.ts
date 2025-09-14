// import * as functions from 'firebase-functions'; // This might be used for other functions or can be removed if all functions are v2
import * as admin from 'firebase-admin';
import { onDocumentWritten } from 'firebase-functions/v2/firestore'; // Import for v2 Firestore triggers
import { summarizeDishReviewFlow } from './flow/summarizeDishReview';
import { summarizeRestaurantReviewFlow } from './flow/summarizeRestaurantReview';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

// This function triggers when a review document is written (created, updated, or deleted).
// It assumes your reviews are stored in a collection like 'apps/foodie/reviews/{reviewId}'.
// Each review document is expected to have:
// - restaurantId: string
// - text: string (the content of the review)
// - dishId?: string (optional, if the review is for a specific dish)
//
// Summaries will be stored in:
// - Dish summary: 'apps/foodie/restaurants/{restaurantId}/menu/{dishId}' (field: reviewSummary)
// - Restaurant summary: 'apps/foodie/restaurants/{restaurantId}' (field: reviewSummary)

// export const onReviewChanged = functions.firestore // Old v1 syntax
//   .document('apps/foodie/reviews/{reviewId}')
//   .onWrite(async (change, context) => {

// New v2 syntax
export const onReviewChanged = onDocumentWritten('apps/foodie/reviews/{reviewId}', async (event) => {
    const reviewId = event.params.reviewId; // Access params from event.params
    console.log(`[${reviewId}] Review change detected. Processing...`);

    

    // Access change data from event.data
    const change = event.data;
    if (!change) {
      console.log(`[${reviewId}] No change data found in event. Exiting.`);
      return null;
    }

    const beforeData = change.before.exists ? change.before.data() : undefined;
    const afterData = change.after.exists ? change.after.data() : undefined;

    // If it's an update (both before and after data exist)
    if (beforeData && afterData) {
        // Create copies for comparison, excluding 'agreedBy' and 'disagreedBy'
        const beforeComparable = { ...beforeData };
        delete beforeComparable.agreedBy;
        delete beforeComparable.disagreedBy;

        const afterComparable = { ...afterData };
        delete afterComparable.agreedBy;
        delete afterComparable.disagreedBy;

        // If only 'agreedBy' or 'disagreedBy' changed (or no other relevant fields changed),
        // the comparable versions will be identical.
        if (JSON.stringify(beforeComparable) === JSON.stringify(afterComparable)) {
            console.log(`[${reviewId}] Review update only involves 'agreedBy', 'disagreedBy', or no relevant content fields. Skipping summary generation.`);
            return null; // Exit early
        }
    }

    const isReviewDeleted = !change.after.exists;
    // Use the already fetched beforeData or afterData
    const reviewData = isReviewDeleted ? beforeData : afterData;

    if (!reviewData) {
      // This condition implies neither beforeData nor afterData was available.
      console.log(`[${reviewId}] No review data found (current or previous state). Exiting.`);
      return null;
    }

    // Log the entire content of the changed document
    console.log(`[${reviewId}] Content of changed document:`, JSON.stringify(reviewData, null, 2));

    const restaurantId = reviewData.restaurantID as string;
    const dishId = reviewData.dishID as string | undefined; // Optional

    if (!restaurantId) {
      console.error(`[${reviewId}] restaurantId not found in review document. Cannot process summary.`);
      return null;
    }

    let changeType = "updated";
    if (!change.before.exists) {
        changeType = "created";
    } else if (isReviewDeleted) {
        changeType = "deleted";
    }
    console.log(`[${reviewId}] Review ${changeType} for restaurant: ${restaurantId}, dish: ${dishId || 'N/A'}. Triggering summary update.`);

    try {
      // Part 1: Regenerate dish-specific summary if the changed review was for a dish
      if (dishId) {
        console.log(`[${reviewId}] Summarizing reviews for specific dish: ${dishId} in restaurant: ${restaurantId}`);

        const dishReviewsSnapshot = await db.collection('apps/foodie/reviews')
          .where('restaurantID', '==', restaurantId)
          .where('dishID', '==', dishId)
          .get();

        const dishSpecificReviewTexts = dishReviewsSnapshot.docs
          .map(doc => doc.data().content as string) 
          .filter(text => !!text && text.trim() !== "");

        const dishDocRef = db.doc(`apps/foodie/restaurants/${restaurantId}/menu/${dishId}`);

        if (dishSpecificReviewTexts.length === 0) {
          console.log(`[${reviewId}] No valid reviews found for dish ${dishId}. Clearing dish summary.`);
          await dishDocRef.set({ summary: admin.firestore.FieldValue.delete() }, { merge: true });
        } else {
          const dishSummary = await summarizeDishReviewFlow(dishSpecificReviewTexts);
          console.log(`[${reviewId}] Generated dish summary for ${dishId}: "${dishSummary}"`);
          await dishDocRef.set(
            { summary: dishSummary || null },
            { merge: true }
          );
          console.log(`[${reviewId}] Successfully updated summary for dish ${dishId}.`);
        }
      }

      // Part 2: Always regenerate the overall restaurant summary
      console.log(`[${reviewId}] Regenerating overall summary for restaurant: ${restaurantId}`);

      // 2a. Fetch general restaurant reviews (dishID is null)
      const generalReviewsSnapshot = await db.collection('apps/foodie/reviews')
          .where('restaurantID', '==', restaurantId)
          .where('dishID', '==', null)
          .get();
      const generalReviewTexts = generalReviewsSnapshot.docs
          .map(doc => doc.data().content as string)
          .filter(text => !!text && text.trim() !== "");

      // 2b. Fetch all dish reviews for this restaurant (dishID is not null)
      const allDishReviewsSnapshot = await db.collection('apps/foodie/reviews')
          .where('restaurantID', '==', restaurantId)
          .where('dishID', '!=', null)
          .get();

      // 2c. Format dish reviews as "dishName: content"
      const formattedDishReviewTexts: string[] = [];
      for (const reviewDoc of allDishReviewsSnapshot.docs) {
          const currentReviewData = reviewDoc.data();
          const specificDishId = currentReviewData.dishID as string;
          const reviewContent = currentReviewData.content as string;

          if (specificDishId && reviewContent && reviewContent.trim() !== "") {
              try {
                  const specificDishDocRef = db.doc(`apps/foodie/restaurants/${restaurantId}/menu/${specificDishId}`);
                  const dishDocSnapshot = await specificDishDocRef.get();
                  
                  if (dishDocSnapshot.exists) {
                      const dishData = dishDocSnapshot.data();
                      const dishName = (dishData && typeof dishData.dishName === 'string') ? dishData.dishName : specificDishId;
                      formattedDishReviewTexts.push(`${dishName}: ${reviewContent}`);
                  } else {
                      formattedDishReviewTexts.push(`${specificDishId}: ${reviewContent}`);
                      console.warn(`[${reviewId}] Dish document not found for dish ${specificDishId} in restaurant ${restaurantId}. Using dishID in formatted review.`);
                  }
              } catch (e) {
                  console.error(`[${reviewId}] Error fetching dish name for ${specificDishId}, using dishID as fallback:`, e);
                  formattedDishReviewTexts.push(`${specificDishId}: ${reviewContent}`);
              }
          }
      }

      // 2d. Combine all review texts for the restaurant
      const allRestaurantReviewTexts = [...generalReviewTexts, ...formattedDishReviewTexts];
      const restaurantDocRef = db.doc(`apps/foodie/restaurants/${restaurantId}`);

      if (allRestaurantReviewTexts.length === 0) {
          console.log(`[${reviewId}] No valid reviews found for restaurant ${restaurantId}. Clearing restaurant summary.`);
          await restaurantDocRef.set({ summary: admin.firestore.FieldValue.delete() }, { merge: true });
      } else {
          const restaurantSummary = await summarizeRestaurantReviewFlow({
              restaurandId: restaurantId, // Matches the key in summarizeRestaurantReviewFlow's inputSchema
              reviews: allRestaurantReviewTexts,
          });
          console.log(`[${reviewId}] Generated overall restaurant summary for ${restaurantId}: "${restaurantSummary}"`);
          
          await restaurantDocRef.set(
              { summary: restaurantSummary || null },
              { merge: true }
          );
          console.log(`[${reviewId}] Successfully updated overall summary for restaurant ${restaurantId}.`);
      }

    } catch (error) {
      console.error(`[${reviewId}] Error processing review change for restaurant ${restaurantId}, dish ${dishId || 'N/A'}:`, error);
      // It's good practice to rethrow or handle errors appropriately for retries or monitoring
      // For now, returning null to stop execution as per original logic.
      return null; 
    }

    return null;
  });