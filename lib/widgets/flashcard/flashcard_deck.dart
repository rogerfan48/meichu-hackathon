import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

import 'flash_card.dart';

class FlashcardDeckController {
  _FlashcardDeckState? _state;

  void _attach(_FlashcardDeckState state) => _state = state;
  void dispose() => _state = null;

  void thumbUp() => _state?._handleThumbUp();
  void thumbDown() => _state?._handleThumbDown();
}

class FlashcardDeck extends StatefulWidget {
  final List<String> cardTexts;
  final FlashcardDeckController? controller;
  final double itemWidth;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onThumbUpGesture;
  final VoidCallback? onThumbDownGesture;

  const FlashcardDeck({
    super.key,
    required this.cardTexts,
    this.controller,
    this.itemWidth = 500.0,
    this.onIndexChanged,
    this.onThumbUpGesture,
    this.onThumbDownGesture,
  });

  @override
  State<FlashcardDeck> createState() => _FlashcardDeckState();
}

class _FlashcardDeckState extends State<FlashcardDeck> {
  final SwiperController _swiperController = SwiperController();

  // Swipe state
  double _dragDx = 0.0;
  bool _gestureConsumed = false;
  int _currentIndex = 0;

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
    if (_currentIndex >= widget.cardTexts.length - 1) {
      return;
    }
    _swiperController.next();
  }

  void _handleThumbDown() {
    widget.onThumbDownGesture?.call();
    if (_currentIndex >= widget.cardTexts.length - 1) {
      return;
    }
    _swiperController.next();
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
      child: Swiper(
        controller: _swiperController,
        itemCount: widget.cardTexts.length,
        itemBuilder: (context, index) {
          return FlashCard(text: widget.cardTexts[index]);
        },
        physics: const NeverScrollableScrollPhysics(),
        allowImplicitScrolling: false,
        layout: SwiperLayout.STACK,
        itemWidth: widget.itemWidth,
        loop: false,
        onIndexChanged: (i) {
          _currentIndex = i;
          widget.onIndexChanged?.call(i);
        },
      ),
    );
  }
}
