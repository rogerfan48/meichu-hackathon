import 'package:flutter/material.dart';

import 'package:foodie/widgets/flashcard/thumb_button.dart';
import 'package:foodie/widgets/flashcard/flash_card.dart';
import 'package:foodie/widgets/flashcard/model_viewer.dart';

import '../../api_key.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: CharacterModelViewer(
              modelUrl:
                  'assets/3d_model/model_compressed.glb',
              isTalking: true,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: const [
                      FlashCard(text: '蘋果'),
                      FlashCard(text: 'Banana'),
                      FlashCard(text: 'Orange'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedThumbButton(
                        icon: Icons.thumb_down,
                        color: Colors.red,
                        onPressed: _nextCard,
                      ),
                      AnimatedThumbButton(
                        icon: Icons.thumb_up,
                        color: Colors.green,
                        onPressed: _nextCard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


