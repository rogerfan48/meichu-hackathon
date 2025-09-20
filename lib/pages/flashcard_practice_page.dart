import 'package:flutter/material.dart';

import 'package:foodie/widgets/flashcard/thumb_button.dart';
import 'package:foodie/widgets/flashcard/flashcard_deck.dart';

class FlashcardPracticePage extends StatefulWidget {
  const FlashcardPracticePage({super.key});

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final FlashcardDeckController _deckController = FlashcardDeckController();
  final List<String> _cardTexts = const ['蘋果', 'Banana', 'Orange'];
  final GlobalKey<AnimatedThumbButtonState> _thumbUpKey = GlobalKey();
  final GlobalKey<AnimatedThumbButtonState> _thumbDownKey = GlobalKey();

  @override
  void dispose() {
    _deckController.dispose();
    super.dispose();
  }

  void _thumbUp() {
    _deckController.thumbUp();
  }

  void _thumbDown() {
    _deckController.thumbDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard Practice')),
      body: Column(
        children: [
          Expanded(
            child: FlashcardDeck(
              controller: _deckController,
              cardTexts: _cardTexts,
              itemWidth: 500.0,
              onThumbUpGesture: () {
                _thumbUpKey.currentState?.playAnimation();
              },
              onThumbDownGesture: () {
                _thumbDownKey.currentState?.playAnimation();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedThumbButton(
                  key: _thumbDownKey,
                  icon: Icons.thumb_down,
                  color: Colors.red,
                  onPressed: _thumbDown,
                ),
                AnimatedThumbButton(
                  key: _thumbUpKey,
                  icon: Icons.thumb_up,
                  color: Colors.green,
                  onPressed: _thumbUp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


