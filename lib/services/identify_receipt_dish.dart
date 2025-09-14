import 'package:cloud_functions/cloud_functions.dart';

Future<List<String>> identifyReceiptDish(String restaurantId, String imageURL) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('identifyReceiptDish');
    final response = await callable.call({
      'restaurantId': restaurantId,
      'receiptImageUrl': imageURL,
    });
    final data = List<String>.from(response.data);
    return data;
  } catch (e) {
    print('Error summarizing review: $e');
    return [];
  }
}