import 'package:flutter/material.dart';

import 'package:foodie/widgets/flashcard/round_button.dart';
import 'package:go_router/go_router.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedRoundButton(
                  label: 'Listen',
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  onPressed: () {
                    context.go('/flashcard/practice');
                  },
                ),
                AnimatedRoundButton(
                  label: 'Practice',
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  onPressed: () {
                    context.go('/flashcard/practice');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


