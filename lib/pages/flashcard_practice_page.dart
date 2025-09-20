import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;  // Temporarily disabled
import 'package:permission_handler/permission_handler.dart';

import 'package:foodie/widgets/flashcard/flashcard_deck.dart';
import 'package:foodie/widgets/flashcard/icon_button.dart';

class FlashcardPracticePage extends StatefulWidget {
  const FlashcardPracticePage({super.key});

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final FlashcardDeckController _deckController = FlashcardDeckController();
  final List<String> _cardTexts = const ['蘋果', 'Banana', 'Orange', 'Strawberry'];
  int _currentIndex = 0;
  bool _isRecording = false;
  // late stt.SpeechToText _speech;  // Temporarily disabled
  String _recognizedWords = '';

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText();  // Temporarily disabled
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    _deckController.dispose();
    // _speech.stop();  // Temporarily disabled
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    // Speech functionality temporarily disabled
    setState(() {
      _isRecording = true;
      _recognizedWords = 'Speech recognition temporarily disabled';
    });
    
    // Simulate speech recognition for testing
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _recognizedWords = _cardTexts[_currentIndex];  // Auto-correct for testing
      _isRecording = false;
    });
    _checkAnswer();
  }

  void _stopListening() {
    // _speech.stop();  // Temporarily disabled
    setState(() => _isRecording = false);
  }

  void _checkAnswer() {
    final currentCardText = _cardTexts[_currentIndex];
    final isCorrect = _recognizedWords.trim().toLowerCase() == currentCardText.trim().toLowerCase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Try again! You said: $_recognizedWords'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );

    if (isCorrect) {
      _deckController.thumbUp();
    } else {
      _deckController.thumbDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard Practice')),
      body: Column(
        children: [
          Expanded(
            child: FlashcardDeck(
              controller: _deckController,
              cardTexts: _cardTexts,
              onIndexChanged: _onIndexChanged,
              onEnd: () => context.pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _isRecording ? "Listening..." : "Press the mic to speak",
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (_recognizedWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'You said: $_recognizedWords',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedIconButton(
                  icon: Icons.chevron_left,
                  color: colorScheme.secondaryContainer,
                  onPressed: () => _deckController.thumbDown(),
                ),
                AnimatedIconButton(
                  icon: _isRecording ? Icons.mic_off : Icons.mic,
                  color: _isRecording ? Colors.red : colorScheme.primary,
                  onPressed: _toggleRecording,
                ),
                AnimatedIconButton(
                  icon: Icons.chevron_right,
                  color: colorScheme.secondaryContainer,
                  onPressed: () => _deckController.thumbUp(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
