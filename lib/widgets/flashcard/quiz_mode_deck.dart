import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../models/card_model.dart';
import '../shared/quiz_flash_card.dart';

/// 這個 Controller 專門用於控制測驗模式的卡片堆
class QuizDeckController {
  _QuizModeDeckState? _state;

  void _attach(_QuizModeDeckState state) => _state = state;
  void dispose() => _state = null;

  void swipeRight() => _state?._swiperController.swipe(CardSwiperDirection.right);
  void swipeLeft() => _state?._swiperController.swipe(CardSwiperDirection.left);
  int get currentIndex => _state?._currentIndex ?? 0;
}

class QuizModeDeck extends StatefulWidget {
  final List<StudyCard> cards;
  final QuizDeckController? controller;

  const QuizModeDeck({
    super.key,
    required this.cards,
    this.controller,
  });

  @override
  State<QuizModeDeck> createState() => _QuizModeDeckState();
}

class _QuizModeDeckState extends State<QuizModeDeck> {
  final CardSwiperController _swiperController = CardSwiperController();
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

  @override
  Widget build(BuildContext context) {
    // ** 關鍵修正：這是解決崩潰的核心 **
    // 如果傳入的卡片列表是空的，就顯示提示訊息，而不是嘗試建立 CardSwiper。
    if (widget.cards.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '沒有可用的卡片來開始測驗。\n請先新增一些卡片！',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    
    return CardSwiper(
      controller: _swiperController,
      cardsCount: widget.cards.length,
      // ** 關鍵修正：確保 numberOfCardsDisplayed 不會超過實際卡片數量 **
      numberOfCardsDisplayed: widget.cards.length < 3 ? widget.cards.length : 3,
      isLoop: false,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
        return QuizFlashCard(card: widget.cards[index]);
      },
      onSwipe: (int previousIndex, int? currentIndex, CardSwiperDirection direction) {
        setState(() {
          _currentIndex = currentIndex ?? widget.cards.length;
        });
        return true;
      },
      onEnd: () {
        // 當卡片滑完時，自動返回上一頁 (如果整合在 TabBarView 中，這個邏輯可能不需要)
        // 為了安全，我們保留它
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}