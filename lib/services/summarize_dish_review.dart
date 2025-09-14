import 'package:cloud_functions/cloud_functions.dart';

// Input a list of strings representing a review and return a summarized version of the review.
Future<String> summarizeDishReview(List<String> reviewTexts) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('summarizeDishReview');
    final response = await callable.call(reviewTexts);
    final data = response.data as String;
    return data;
  } catch (e) {
    print('Error summarizing review: $e');
    return 'Error summarizing review';
  }
}