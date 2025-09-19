import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  TTSService({double defaultRate = 1.0}) {
    _tts.setSpeechRate(defaultRate);
    _tts.setVolume(1.0);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, {double? rate}) async {
    if (rate != null) {
      await _tts.setSpeechRate(rate);
    }
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
