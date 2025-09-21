import 'package:cloud_functions/cloud_functions.dart';

// Result model to match the Cloud Function response
class GenCardsResult {
  final bool success;
  final String sessionID;
  final int totalCards;
  final int successfulCards;
  final int failedCards;
  final List<String> cardIDs;
  final List<String> concepts;
  final List<CardCreationDetail> details;

  GenCardsResult({
    required this.success,
    required this.sessionID,
    required this.totalCards,
    required this.successfulCards,
    required this.failedCards,
    required this.cardIDs,
    required this.concepts,
    required this.details,
  });

  factory GenCardsResult.fromMap(Map<String, dynamic> data) {
    return GenCardsResult(
      success: data['success'] as bool? ?? false,
      sessionID: data['sessionID'] as String? ?? '',
      totalCards: data['totalCards'] as int? ?? 0,
      successfulCards: data['successfulCards'] as int? ?? 0,
      failedCards: data['failedCards'] as int? ?? 0,
      cardIDs: List<String>.from(data['cardIDs'] as List? ?? []),
      concepts: List<String>.from(data['concepts'] as List? ?? []),
      details: (data['details'] as List? ?? [])
          .map((detail) => CardCreationDetail.fromMap(detail as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CardCreationDetail {
  final String cardID;
  final String word;
  final String? imgURL;
  final bool success;
  final String? error;

  CardCreationDetail({
    required this.cardID,
    required this.word,
    this.imgURL,
    required this.success,
    this.error,
  });

  factory CardCreationDetail.fromMap(Map<String, dynamic> data) {
    return CardCreationDetail(
      cardID: data['cardID'] as String? ?? '',
      word: data['word'] as String? ?? '',
      imgURL: data['imgURL'] as String?,
      success: data['success'] as bool? ?? false,
      error: data['error'] as String?,
    );
  }
}

/// Generates study cards for a session based on the session summary
/// 
/// Input:
/// - sessionID: String - The ID of the session to generate cards for
/// - sessionSummary: String - The summary text to extract concepts from
/// 
/// Output:
/// - GenCardsResult containing:
///   - success: bool - Whether the operation succeeded
///   - sessionID: String - The session ID
///   - totalCards: int - Total number of cards attempted (should be 5)
///   - successfulCards: int - Number of cards created successfully
///   - failedCards: int - Number of cards that failed to create
///   - cardIDs: List<String> - List of created card document IDs
///   - concepts: List<String> - List of extracted concept words
///   - details: List<CardCreationDetail> - Detailed info about each card creation
Future<GenCardsResult> generateCards(String sessionID, String sessionSummary) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('genCards');
    final response = await callable.call({
      'sessionID': sessionID,
      'sessionSummary': sessionSummary,
    });
    
    final data = response.data as Map<String, dynamic>;
    return GenCardsResult.fromMap(data);
  } catch (e) {
    print('Error generating cards: $e');
    rethrow;
  }
}