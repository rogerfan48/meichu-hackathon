import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../utils/helpers.dart';
import '../firebase_image.dart';
import '../flashcard/mastery_indicator.dart';

/// 一個可重用的 Widget，用於在列表中顯示單張 StudyCard 的資訊。
/// 支援滑動刪除和長按編輯等回調。
class StudyCardTile extends StatelessWidget {
  final StudyCard card;
  final VoidCallback? onLongPress; // 長按回調 (例如：編輯)
  final VoidCallback? onDelete;    // 刪除回調

  const StudyCardTile({
    super.key,
    required this.card,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: _buildCardImage(card),
          title: Text(card.text, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                MasteryIndicator(masteryLevel: card.masteryLevel),
                const SizedBox(width: 8),
                const Text('·'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatRelativeTime(card.lastReviewedAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 如果提供了 onDelete 回調，則用 Dismissible 包裹起來以啟用滑動刪除
    if (onDelete != null) {
      return Dismissible(
        key: ValueKey(card.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => onDelete!(),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildCardImage(StudyCard card) {
    if (card.imgURL != null && card.imgURL!.startsWith('gs://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: FirebaseImage(gsUri: card.imgURL!, width: 50, height: 50, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}