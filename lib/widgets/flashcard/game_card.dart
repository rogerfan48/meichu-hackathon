import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flip_card/flip_card.dart';
import '../../models/card_model.dart';
import '../../view_models/cards_page_view_model.dart';
import '../firebase_image.dart';

class GameCard extends StatefulWidget {
  final StudyCard card;
  final CardsPageViewModel viewModel;
  const GameCard({super.key, required this.card, required this.viewModel});
  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  late final FlutterTts _flutterTts;
  
  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _setupTts();
  }

  Future<void> _setupTts() async {
    final isChinese = RegExp(r'[\u4E00-\u9FFF]').hasMatch(widget.card.text);
    if (isChinese) {
      await _flutterTts.setLanguage("zh-TW");
    } else {
      await _flutterTts.setLanguage("en-US");
    }
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void didUpdateWidget(covariant GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      // 當卡片切換時，確保卡片是正面
      if (_cardKey.currentState?.isFront == false) {
        _cardKey.currentState?.toggleCard();
      }
      _setupTts();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
  void _speak() {
    _flutterTts.speak(widget.card.text);
  }

  void _onAnswer(ReviewOutcome outcome) {
    widget.viewModel.processAnswer(widget.card, outcome);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 進度條
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                '${widget.viewModel.currentGameCardIndex + 1} / ${widget.viewModel.totalGameCards}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              // 可以加上一個結束遊戲的按鈕
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.viewModel.endGame,
              ),
            ],
          ),
        ),
        // 卡片區域
        Expanded(
          child: GestureDetector(
            // 偵測水平滑動來翻面
            onHorizontalDragEnd: (details) {
              _cardKey.currentState?.toggleCard();
            },
            child: FlipCard(
              key: _cardKey,
              flipOnTouch: false, // 我們自己控制翻轉
              direction: FlipDirection.HORIZONTAL,
              front: _buildCardSide(
                onTap: _speak,
                child: Center(
                  child: Text(
                    widget.card.text,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              back: _buildCardSide(
                child: _buildImageSide(),
              ),
            ),
          ),
        ),
        // 常駐的回答按鈕
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _cardKey.currentState?.isFront ?? true
                  ? '點擊卡片發音，滑動查看圖片'
                  : '請根據記憶回答',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildAnswerButton('忘記', Colors.red, ReviewOutcome.again)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAnswerButton('困難', Colors.orange, ReviewOutcome.hard)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAnswerButton('普通', Colors.green, ReviewOutcome.good)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAnswerButton('熟悉', Colors.blue, ReviewOutcome.easy)),
                ],
              ),
            ],
          )
        ),
      ],
    );
  }
  
  // 卡片 UI
  Widget _buildCardSide({required Widget child, VoidCallback? onTap}) {
    return InkWell( // 使用 InkWell 來顯示點擊的水波紋效果
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }

  // 圖片面的 UI
  Widget _buildImageSide() {
    final hasImage = widget.card.imgURL != null && widget.card.imgURL!.startsWith('gs://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // 確保圖片也被裁切成圓角
      child: hasImage
          ? FirebaseImage(gsUri: widget.card.imgURL!, fit: BoxFit.cover)
          : Center(
              child: Text(
                '此卡片沒有圖片',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
    );
  }
  
  // 回答按鈕的 UI
  Widget _buildAnswerButton(String label, Color color, ReviewOutcome outcome) {
    return ElevatedButton(
      onPressed: () => _onAnswer(outcome),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}