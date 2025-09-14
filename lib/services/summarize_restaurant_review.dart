import 'package:cloud_functions/cloud_functions.dart';

// Input a list of strings representing a review and return a summarized version of the review.
Future<String> summarizeRestaurantReview(String restaurantId, List<String> reviews) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('summarizeRestaurantReview');
    final response = await callable.call({
      "restaurantId": restaurantId,
      "reviews": reviews,
    });
    final data = response.data as String;
    return data;
  } catch (e) {
    print('Error summarizing review: $e');
    return 'Error summarizing review';
  }
}