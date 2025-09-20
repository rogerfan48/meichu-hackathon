import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../view_models/cards_page_view_model.dart';
import '../shared/study_card_tile.dart';
import 'add_edit_card_dialog.dart';

class CardManagementView extends StatelessWidget {
  final CardsPageViewModel viewModel;
  const CardManagementView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ElevatedButton.icon(
            onPressed: viewModel.allSessions.isEmpty
                ? null
                : () => showAddOrEditCardDialog(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text('新增卡片'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          ),
        ),
        if (viewModel.allSessions.isEmpty && viewModel.allCards.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("請先建立一個 Session 才能新增卡片。", style: TextStyle(color: Colors.grey)),
          ),
        Expanded(
          child: viewModel.allCards.isEmpty
              ? const Center(child: Text('尚無卡片，快去新增一張吧！'))
              : ListView.builder(
                  itemCount: viewModel.allCards.length,
                  itemBuilder: (context, index) {
                    final card = viewModel.allCards[index];
                    // ** 關鍵修改：使用新的回調參數 **
                    return StudyCardTile(
                      card: card,
                      onEdit: () {
                        showAddOrEditCardDialog(context, viewModel, existingCard: card);
                      },
                      onDelete: () {
                        _showDeleteConfirmationDialog(context, card, viewModel);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  // 新增的輔助方法，用於顯示刪除確認對話框
  void _showDeleteConfirmationDialog(BuildContext context, StudyCard card, CardsPageViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('刪除後將無法復原，您確定要刪除這張卡片嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteCard(card);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已刪除 "${card.text}"'), duration: const Duration(seconds: 2)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }
}