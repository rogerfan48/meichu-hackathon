import 'package:cloud_functions/cloud_functions.dart';

// Result model to match the Cloud Function response
class SessionSummaryResult {
  final String sessionID;
  final String summary;
  final List<String> imgExplanation;

  SessionSummaryResult({
    required this.sessionID,
    required this.summary,
    required this.imgExplanation,
  });

  factory SessionSummaryResult.fromMap(Map<String, dynamic> data) {
    return SessionSummaryResult(
      sessionID: data['sessionID'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      imgExplanation: List<String>.from(data['imgExplanation'] as List? ?? []),
    );
  }

  @override
  String toString() {
    return 'SessionSummaryResult{sessionID: $sessionID, summary: $summary, imgExplanation: $imgExplanation}';
  }
}

/// Generates a session summary from multiple file URLs
/// 
/// Input:
/// - fileURLs: List<String> - List of file URLs to process (supports http/https and gs:// URLs)
/// 
/// Output:
/// - SessionSummaryResult containing:
///   - sessionID: String - The created session document ID
///   - summary: String - Dyslexia-friendly combined summary of all files
///   - imgExplanation: List<String> - List of image idea descriptions
/// 
/// The function will:
/// 1. Create a new session document in Firestore
/// 2. Process each file URL and generate individual summaries
/// 3. Combine all summaries into one dyslexia-friendly summary
/// 4. Generate image ideas to help explain the concepts
/// 5. Generate actual images and store them in Cloud Storage
/// 6. Update the session document with all results
Future<SessionSummaryResult> generateSessionSummary(List<String> fileURLs) async {
  try {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('genSessionSummary');
    
    // For functions.https.onCall, the data is passed directly
    final response = await callable.call({
      'fileURLs': fileURLs,
    });
    
    final data = response.data as Map<String, dynamic>;
    return SessionSummaryResult.fromMap(data);
  } catch (e) {
    print('Error generating session summary: $e');
    rethrow;
  }
}