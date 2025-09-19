/// OCR Service abstraction (could wrap Google ML Kit / Vision / custom backend)
class OCRService {
  OCRService();

  Future<String> extractTextFromImage(String imagePath) async {
    // TODO: implement platform channel or backend call
    return '[[ocr text]]';
  }
}
