import 'package:flutter/material.dart';
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
                    // ** 關鍵修改：直接使用 StudyCardTile **
                    return StudyCardTile(
                      card: card,
                      onLongPress: () {
                        showAddOrEditCardDialog(context, viewModel, existingCard: card);
                      },
                      onDelete: () {
                        viewModel.deleteCard(card);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已刪除 "${card.text}"'), duration: const Duration(seconds: 2)),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}