import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

import 'package:foodie/widgets/flashcard/thumb_button.dart';
import 'package:foodie/widgets/flashcard/flash_card.dart';

import '../../api_key.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final SwiperController _swiperController = SwiperController();
  final List<String> _cardTexts = const ['蘋果', 'Banana', 'Orange'];
  final GlobalKey<AnimatedThumbButtonState> _thumbUpKey = GlobalKey();
  final GlobalKey<AnimatedThumbButtonState> _thumbDownKey = GlobalKey();

  // Swipe state
  double _dragDx = 0.0;
  bool _gestureConsumed = false;
  int _currentIndex = 0;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _thumbUp() {
    if (_currentIndex >= _cardTexts.length - 1) {
      _thumbUpKey.currentState?.playAnimation();
      return;
    }
    _thumbUpKey.currentState?.playAnimation();
    _swiperController.next();
  }

  void _thumbDown() {
    if (_currentIndex >= _cardTexts.length - 1) {
      _thumbDownKey.currentState?.playAnimation();
      return;
    }
    _thumbDownKey.currentState?.playAnimation();
    _swiperController.next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _dragDx = 0.0;
                _gestureConsumed = false;
              },
              onHorizontalDragUpdate: (details) {
                if (_gestureConsumed) return;
                _dragDx += details.delta.dx;
                const double trigger = 40.0; // sensitivity threshold in px
                if (_dragDx > trigger) {
                  _gestureConsumed = true;
                  _thumbUp();
                } else if (_dragDx < -trigger) {
                  _gestureConsumed = true;
                  _thumbDown();
                }
              },
              onHorizontalDragEnd: (_) {
                _dragDx = 0.0;
                _gestureConsumed = false;
              },
              child: Swiper(
                controller: _swiperController,
                itemCount: _cardTexts.length,
                itemBuilder: (context, index) {
                  return FlashCard(text: _cardTexts[index]);
                },
                physics: const NeverScrollableScrollPhysics(),
                allowImplicitScrolling: false,
                layout: SwiperLayout.STACK,
                itemWidth: 500.0,
                loop: false,
                onIndexChanged: (i) {
                  _currentIndex = i;
                },
              ),
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


