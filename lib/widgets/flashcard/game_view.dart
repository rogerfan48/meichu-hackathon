import 'package:flutter/material.dart';
import '../../view_models/cards_page_view_model.dart';
import 'game_card.dart';

class GameView extends StatelessWidget {
  final CardsPageViewModel viewModel;
  const GameView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    switch (viewModel.gameState) {
      case GameState.setup:
        return _buildGameSetupView(context);
      case GameState.active:
        return _buildGameActiveView(context);
      case GameState.finished:
        return _buildGameFinishedView(context);
    }
  }

  Widget _buildGameSetupView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('今日應複習 ${viewModel.dueCardCount} 張卡片', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('選擇要練習的標籤（若不選擇則練習所有到期的卡片）'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: viewModel.availableTags.map((tag) {
              final isSelected = viewModel.selectedTagsForGame.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) => viewModel.toggleTagForGame(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.dueCardCount == 0 ? null : () => viewModel.startGame(),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48), padding: const EdgeInsets.symmetric(horizontal: 32)),
            child: const Text('開始複習'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameActiveView(BuildContext context) {
    final card = viewModel.currentGameCard;
    if (card == null) return const Center(child: Text('遊戲錯誤'));
    return GameCard(card: card, viewModel: viewModel);
  }

  Widget _buildGameFinishedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text('本次複習完成！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.endGame(),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }
}