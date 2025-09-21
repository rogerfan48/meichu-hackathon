import 'package:cloud_functions/cloud_functions.dart';

Future<void> processExistingSession(String sessionID, String userID) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('processExistingSession');
    
    await callable.call({
      "sessionID": sessionID,
      "uid": userID,
    });

    return;
  } catch (e) {
    print('Error generating session summary: $e');
    rethrow;
  }
}