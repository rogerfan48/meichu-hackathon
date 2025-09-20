import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../view_models/cards_page_view_model.dart';

class GameCard extends StatefulWidget {
  final StudyCard card;
  final CardsPageViewModel viewModel;
  const GameCard({super.key, required this.card, required this.viewModel});
  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool isFlipped = false;

  @override
  void didUpdateWidget(covariant GameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      setState(() => isFlipped = false);
    }
  }

  void _flipCard() => setState(() => isFlipped = !isFlipped);

  void _onAnswer(ReviewOutcome outcome) {
    if (!isFlipped) return;
    widget.viewModel.processAnswer(widget.card, outcome);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${widget.viewModel.currentGameCardIndex + 1} / ${widget.viewModel.totalGameCards}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _flipCard,
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  isFlipped ? '答案是...' : widget.card.text,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        if (isFlipped)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('這張卡的難度如何？'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildAnswerButton('忘記了', Colors.red, ReviewOutcome.again)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerButton('困難', Colors.orange, ReviewOutcome.hard)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerButton('記得', Colors.green, ReviewOutcome.good)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildAnswerButton('簡單', Colors.blue, ReviewOutcome.easy)),
                  ],
                ),
              ],
            ),
          ),
        if (!isFlipped)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(height: 72, child: Center(child: Text('點擊卡片查看答案'))),
          ),
      ],
    );
  }

  Widget _buildAnswerButton(String label, Color color, ReviewOutcome outcome) {
    return ElevatedButton(
      onPressed: () => _onAnswer(outcome),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}