/// AI Service: wraps calls to backend Cloud Functions / Vertex AI (Gemini).
/// This layer should remain UI-agnostic; return plain data models or DTO maps.
class AIService {
  AIService();

  // Summarize a single file's text content (already OCR processed if needed)
  Future<String> summarizeText(String content) async {
    // TODO: invoke callable function or REST endpoint
    return '[[summary placeholder]]';
  }

  // Extract candidate card terms given combined corpus
  Future<List<String>> extractKeyTerms(String corpus) async {
    // TODO: implement real extraction
    return const ['term1', 'term2'];
  }

  // Request generation of explanatory images; returns list of storage URLs
  Future<List<String>> generateImages(String globalSummary) async {
    return const [];
  }

  // Produce explanation for an image
  Future<String> explainImage(String imageUrl, String contextSummary) async {
    return '[[image explanation placeholder]]';
  }
}
