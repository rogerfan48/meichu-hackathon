import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../models/session_model.dart';
import '../../view_models/cards_page_view_model.dart';

/// 顯示一個用於新增或編輯單字卡的對話框
void showAddOrEditCardDialog(BuildContext context, CardsPageViewModel viewModel, {StudyCard? existingCard}) {
  final isEditing = existingCard != null;
  final textController = TextEditingController(text: isEditing ? existingCard.text : '');
  final tagsController = TextEditingController(text: isEditing ? existingCard.tags.join(', ') : '');
  String? selectedSessionId = isEditing ? existingCard.sessionID : (viewModel.allSessions.isNotEmpty ? viewModel.allSessions.first.id : null);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? '編輯卡片' : '新增卡片'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEditing)
                    DropdownButtonFormField<String>(
                      value: selectedSessionId,
                      items: viewModel.allSessions.map((Session session) {
                        return DropdownMenuItem<String>(
                          value: session.id,
                          child: Text(session.sessionName, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedSessionId = newValue;
                        });
                      },
                      decoration: const InputDecoration(labelText: '選擇 Session'),
                      validator: (value) => value == null ? '請選擇一個 Session' : null,
                    ),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: '文字'),
                    autofocus: true,
                  ),
                  TextField(
                    controller: tagsController,
                    decoration: const InputDecoration(labelText: '標籤 (以逗號分隔)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('取消')),
              ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isEmpty || selectedSessionId == null) return;

                  final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

                  if (isEditing) {
                    final updatedCard = existingCard.copyWith(text: text, tags: tags);
                    viewModel.updateCard(updatedCard);

                  } else {
                    viewModel.createCard(sessionId: selectedSessionId!, text: text, tags: tags);
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('儲存'),
              ),
            ],
          );
        },
      );
    },
  );
}