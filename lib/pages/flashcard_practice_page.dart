import 'package:flutter/material.dart';
import 'package:foodie/widgets/flashcard/flashcard_deck.dart';
import 'package:foodie/widgets/flashcard/round_button.dart';

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

  @override
  void dispose() {
    _deckController.dispose();
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedRoundButton(
                  icon: Icons.chevron_left,
                  color: colorScheme.secondaryContainer,
                  onPressed: _currentIndex > 0 ? () => _deckController.thumbDown() : null,
                ),
                AnimatedRoundButton(
                  icon: _isRecording ? Icons.mic_off : Icons.mic,
                  color: _isRecording ? Colors.red : colorScheme.primary,
                  textColor: _isRecording ? Colors.white : colorScheme.onPrimary,
                  onPressed: _toggleRecording,
                ),
                AnimatedRoundButton(
                  icon: Icons.chevron_right,
                  color: colorScheme.secondaryContainer,
                  onPressed: _currentIndex < _cardTexts.length -1 ? () => _deckController.thumbUp() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
