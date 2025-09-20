import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/material.dart';

import 'flash_card.dart';

class FlashcardDeckController {
  _FlashcardDeckState? _state;

  void _attach(_FlashcardDeckState state) => _state = state;
  void dispose() => _state = null;

  void thumbUp() => _state?._handleThumbUp();
  void thumbDown() => _state?._handleThumbDown();
  int getIndex() => _state?._getCurrentIndex() ?? 0;
}

class FlashcardDeck extends StatefulWidget {
  final List<String> cardTexts;
  final FlashcardDeckController? controller;
  final double itemWidth;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onThumbUpGesture;
  final VoidCallback? onThumbDownGesture;
  final VoidCallback? onEnd;

  const FlashcardDeck({
    super.key,
    required this.cardTexts,
    this.controller,
    this.itemWidth = 500.0,
    this.onIndexChanged,
    this.onThumbUpGesture,
    this.onThumbDownGesture,
    this.onEnd,
  });

  @override
  State<FlashcardDeck> createState() => _FlashcardDeckState();
}

class _FlashcardDeckState extends State<FlashcardDeck> {
  final CardSwiperController _swiperController = CardSwiperController();

  // Swipe state
  double _dragDx = 0.0;
  bool _gestureConsumed = false;
  int _currentIndex = 0;
  AxisDirection _axisDirection = AxisDirection.down; // default drop down

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  void _handleThumbUp() {
    widget.onThumbUpGesture?.call();
    _swiperController.swipe(CardSwiperDirection.right);
  }

  void _handleThumbDown() {
    widget.onThumbDownGesture?.call();
    _swiperController.swipe(CardSwiperDirection.left);
  }

  int _getCurrentIndex() {
    return _currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {
        _dragDx = 0.0;
        _gestureConsumed = false;
      },
      onHorizontalDragUpdate: (details) {
        if (_gestureConsumed) return;
        _dragDx += details.delta.dx;
        const double trigger = 40.0;
        if (_dragDx > trigger) {
          _gestureConsumed = true;
          _handleThumbUp();
        } else if (_dragDx < -trigger) {
          _gestureConsumed = true;
          _handleThumbDown();
        }
      },
      onHorizontalDragEnd: (_) {
        _dragDx = 0.0;
        _gestureConsumed = false;
      },
      child: CardSwiper(
        controller: _swiperController,
        cardsCount: widget.cardTexts.length,
        numberOfCardsDisplayed: 3,
        isLoop: false,
        padding: EdgeInsets.zero,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return Center(
            child: SizedBox(
              width: widget.itemWidth == 500.0
                  ? MediaQuery.of(context).size.width * 0.85
                  : widget.itemWidth,
              height: MediaQuery.of(context).size.height * 0.6,
              child: FlashCard(text: widget.cardTexts[index]),
            ),
          );
        },
        onSwipe: (int previousIndex, int? currentIndex, CardSwiperDirection direction) {
          _currentIndex = previousIndex + 1;
          widget.onIndexChanged?.call(_currentIndex);
          return true;
        },
        onEnd: widget.onEnd,
      ),
    );
  }
}
