import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import '../../models/session_model.dart';
import '../../view_models/cards_page_view_model.dart';
import 'mastery_indicator.dart';

/// 顯示一個用於新增或編輯單字卡的對話框
void showAddOrEditCardDialog(BuildContext context, CardsPageViewModel viewModel, {StudyCard? existingCard}) {
  final isEditing = existingCard != null;
  final textController = TextEditingController(text: isEditing ? existingCard.text : '');
  String? selectedSessionId = isEditing ? existingCard.sessionID : (viewModel.allSessions.isNotEmpty ? viewModel.allSessions.first.id : null);
  
  // 用於在對話框中追蹤用戶選擇的熟練度
  int currentMastery = isEditing ? existingCard.masteryLevel : 1;

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  
                  // ** 關鍵修改：熟練度選擇器 **
                  if (isEditing) ...[
                    const SizedBox(height: 24),
                    const Text('熟練度', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    // 這是一個可以點擊的熟練度選擇器
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        final level = index + 1;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              currentMastery = level;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              level <= currentMastery ? Icons.circle : Icons.circle_outlined,
                              size: 24,
                              color: level <= currentMastery ? Colors.amber.shade700 : Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('取消')),
              ElevatedButton(
                onPressed: () {
                  final text = textController.text.trim();
                  if (text.isEmpty || selectedSessionId == null) return;

                  if (isEditing) {
                    final updatedCard = existingCard.copyWith(text: text, masteryLevel: currentMastery);
                    viewModel.updateCard(updatedCard);
                  } else {
                    viewModel.createCard(sessionId: selectedSessionId!, text: text);
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