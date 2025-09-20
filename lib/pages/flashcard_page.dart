import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/cards_page_view_model.dart';
import '../models/card_model.dart';
import '../view_models/account_vm.dart';
import '../models/session_model.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();
    if (!accountVM.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('單字卡'), automaticallyImplyLeading: false),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('請先至「設定」頁面登入以使用單字卡功能。',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
        ),
      );
    }

    return Consumer<CardsPageViewModel?>(
      builder: (context, viewModel, child) {
        if (viewModel == null) {
          return const Scaffold(body: Center(child: Text('ViewModel 初始化中...')));
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('單字卡'),
              automaticallyImplyLeading: false,
              bottom: TabBar(
                tabs: const [
                  Tab(text: '管理卡片', icon: Icon(Icons.view_list)),
                  Tab(text: '遊戲模式', icon: Icon(Icons.games)),
                ],
                onTap: (index) {
                  if (viewModel.gameState != GameState.setup && index == 0) {
                    viewModel.endGame();
                  }
                },
              ),
            ),
            body: _buildBody(context, viewModel),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CardsPageViewModel viewModel) {
    switch (viewModel.pageState) {
      case CardsPageState.loading:
        return const Center(child: CircularProgressIndicator());
      case CardsPageState.error:
        return Center(child: Text(viewModel.errorMessage ?? '發生未知錯誤'));
      case CardsPageState.idle:
        return TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Prevent swipe to change tabs
          children: [
            _buildCardManagementView(context, viewModel),
            _buildGameView(context, viewModel),
          ],
        );
    }
  }

  // --- Card Management View ---
  Widget _buildCardManagementView(BuildContext context, CardsPageViewModel viewModel) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ElevatedButton.icon(
            onPressed: viewModel.allSessions.isEmpty 
              ? null // Disable if no sessions exist
              : () => _showAddOrEditCardDialog(context, viewModel),
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
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: _buildCardImage(card),
                        title: Text(card.text),
                        subtitle: Text('讚: ${card.goodCount}, 倒讚: ${card.badCount}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddOrEditCardDialog(context, viewModel, existingCard: card);
                            } else if (value == 'delete') {
                              viewModel.deleteCard(card);
                            } else if (value == 'generate_image') {
                              viewModel.generateImageForCard(card);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('編輯')),
                            if (card.imgURL == null)
                              const PopupMenuItem(value: 'generate_image', child: Text('AI 生成圖片')),
                            const PopupMenuItem(value: 'delete', child: Text('刪除', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  // (Other build methods like _buildGameView, etc., remain unchanged)

  // --- Add/Edit Card Dialog ---
  void _showAddOrEditCardDialog(BuildContext context, CardsPageViewModel viewModel, {StudyCard? existingCard}) {
    final isEditing = existingCard != null;
    final textController = TextEditingController(text: isEditing ? existingCard.text : '');
    final tagsController = TextEditingController(text: isEditing ? existingCard.tags.join(', ') : '');
    // The selected session ID. For editing, it's the card's sessionID. For new, it defaults to the first session.
    String? selectedSessionId = isEditing ? existingCard.sessionID : (viewModel.allSessions.isNotEmpty ? viewModel.allSessions.first.id : null);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage the dialog's state
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? '編輯卡片' : '新增卡片'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Session Dropdown (only for new cards)
                    if (!isEditing)
                      DropdownButtonFormField<String>(
                        value: selectedSessionId,
                        items: viewModel.allSessions.map((Session session) {
                          return DropdownMenuItem<String>(
                            value: session.id,
                            child: Text(session.sessionName),
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
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
                ElevatedButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    if (selectedSessionId == null) return; // Should not happen if validated

                    final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

                    if (isEditing) {
                      final updatedCard = existingCard.copyWith(text: text, tags: tags);
                      viewModel.updateCard(updatedCard);
                    } else {
                      viewModel.createCard(sessionId: selectedSessionId!, text: text, tags: tags);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Duplicated code from previous response for completeness
  Widget _buildCardImage(StudyCard card) {
    if (card.imgURL != null && card.imgURL!.isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(card.imgURL!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40)));
    }
    return Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey));
  }

  Widget _buildGameView(BuildContext context, CardsPageViewModel viewModel) {
    switch (viewModel.gameState) {
      case GameState.setup: return _buildGameSetupView(context, viewModel);
      case GameState.active: return _buildGameActiveView(context, viewModel);
      case GameState.finished: return _buildGameFinishedView(context, viewModel);
    }
  }

  Widget _buildGameSetupView(BuildContext context, CardsPageViewModel viewModel) {
    return Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('選擇要練習的標籤', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text('（若不選擇則練習所有卡片）'),
      const SizedBox(height: 16),
      Wrap(spacing: 8.0, runSpacing: 4.0, children: viewModel.availableTags.map((tag) {
        final isSelected = viewModel.selectedTagsForGame.contains(tag);
        return FilterChip(label: Text(tag), selected: isSelected, onSelected: (s) => viewModel.toggleTagForGame(tag));
      }).toList()),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: viewModel.allCards.isEmpty ? null : () => viewModel.startGame(), style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)), child: const Text('開始遊戲')),
    ]));
  }

  Widget _buildGameActiveView(BuildContext context, CardsPageViewModel viewModel) {
    final card = viewModel.currentGameCard;
    if (card == null) return const Center(child: Text('遊戲錯誤'));
    return GameCard(card: card, viewModel: viewModel);
  }

  Widget _buildGameFinishedView(BuildContext context, CardsPageViewModel viewModel) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('遊戲結束！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Text('您的分數: ${viewModel.gameScore} / ${viewModel.totalGameCards}', style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => viewModel.endGame(), child: const Text('返回')),
    ]));
  }
}

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
    if (widget.card.id != oldWidget.card.id) setState(() => isFlipped = false);
  }
  void _flipCard() => setState(() => isFlipped = !isFlipped);
  void _onAnswer(bool correct) {
    if (!isFlipped) return;
    widget.viewModel.recordAnswer(widget.card, correct);
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16.0), child: Text('分數: ${widget.viewModel.gameScore}', style: const TextStyle(fontSize: 18))),
      Expanded(child: GestureDetector(onTap: _flipCard, child: Card(elevation: 8, margin: const EdgeInsets.all(24), child: Container(
        width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.all(24),
        child: Text(isFlipped ? '答案是...' : widget.card.text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      )))),
      if (isFlipped) Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: () => _onAnswer(false), icon: const Icon(Icons.close), label: const Text('不記得'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton.icon(onPressed: () => _onAnswer(true), icon: const Icon(Icons.check), label: const Text('記得'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
      ])),
      if (!isFlipped) const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(height: 60)),
    ]);
  }
}