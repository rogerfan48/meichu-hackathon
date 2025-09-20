import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../utils/helpers.dart';
import '../firebase_image.dart';
import '../flashcard/mastery_indicator.dart';

/// 一個可重用的 Widget，用於在列表中顯示單張 StudyCard 的資訊。
/// 支援點擊，並將編輯和刪除功能整合到一個彈出式選單中。
class StudyCardTile extends StatelessWidget {
  final StudyCard card;
  final VoidCallback? onTap;       // 點擊回調
  final VoidCallback? onEdit;      // 編輯回調
  final VoidCallback? onDelete;    // 刪除回調

  const StudyCardTile({
    super.key,
    required this.card,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
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
          // ** 關鍵修改：將 trailing 改為 PopupMenuButton **
          trailing: _buildPopupMenu(context),
        ),
      ),
    );
  }

  // 新增的輔助方法，用於建立右側的彈出式選單
  Widget? _buildPopupMenu(BuildContext context) {
    // 只有在提供了編輯或刪除回調時才顯示選單按鈕
    if (onEdit == null && onDelete == null) {
      return null;
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('編輯'),
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('刪除', style: TextStyle(color: Colors.red)),
            ),
          ),
      ],
    );
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