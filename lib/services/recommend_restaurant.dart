import 'package:cloud_functions/cloud_functions.dart';

// Input a list of messages and user ID, returns AI response or recommendation.
Future<Map<String, dynamic>> recommendRestaurant(String userId, List<Map<String, dynamic>> messages) async {
  // Ensure each map in 'messages' has 'isUser' (bool) and 'text' (String) keys.
  // Example:
  // messages = [
  //   {'isUser': true, 'text': 'I want to eat noodles'},
  //   {'isUser': false, 'text': 'What type of noodles do you prefer?'},
  //   {'isUser': true, 'text': 'beef noodles'}
  // ];

  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('recommendRestaurant');
    final response = await callable.call({
      'userId': userId,
      'messages': messages,
    });
    // final data = response.data as Map<String, dynamic>?; // Original problematic line
    
    final dynamic rawData = response.data;
    Map<String, dynamic>? typedData;

    if (rawData == null) {
      typedData = null;
    } else if (rawData is Map) {
      try {
        // Attempt to convert the map to the desired type Map<String, dynamic>
        typedData = Map<String, dynamic>.from(rawData);
      } catch (e) {
        print('Error converting response data to Map<String, dynamic>: $e. Raw data was: $rawData');
        // Return an error map, consistent with your outer catch block's behavior
        return {'error': 'Data parsing error: $e'};
      }
    } else {
      // If rawData is not null and not a Map, this is an unexpected data structure.
      print('Error: recommendRestaurant flow returned non-Map data: ${rawData.runtimeType}');
      return {'error': 'Unexpected data type returned from function: ${rawData.runtimeType}'};
    }
    
    return typedData ?? {}; // Return empty map if typedData ended up null (e.g., if rawData was null)
  } catch (e) {
    print('Error calling recommendRestaurant flow: $e');
    // Consider how to handle errors more gracefully in the UI
    if (e is FirebaseFunctionsException) {
      print('FirebaseFunctionsException details: ${e.details}');
      print('FirebaseFunctionsException message: ${e.message}');
    }
    return {'error': e.toString()}; // Return an error object
  }
}