import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../models/session_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../view_models/account_vm.dart';
import '../view_models/cards_page_view_model.dart'; // ** 引入 CardsPageViewModel **
import '../view_models/session_detail_view_model.dart';
import '../widgets/firebase_image.dart';
import '../widgets/flashcard/add_edit_card_dialog.dart'; // ** 引入對話框 **
import '../widgets/shared/study_card_tile.dart';

class SessionDetailPage extends StatelessWidget {
  final String sessionId;
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final accountVM = context.read<AccountViewModel>();
    final userId = accountVM.firebaseUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    // 我們需要 CardsPageViewModel 來觸發編輯/刪除操作
    // 因為這個 ViewModel 是在 ProxyProvider 中創建的，所以我們可以直接讀取它
    final cardsViewModel = context.read<CardsPageViewModel?>();

    return ChangeNotifierProvider(
      create: (context) => SessionDetailViewModel(
        userId: userId,
        sessionId: sessionId,
        sessionRepository: context.read<SessionRepository>(),
        cardRepository: context.read<CardRepository>(),
      ),
      child: Consumer<SessionDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.session?.sessionName ?? "Loading..."),
            ),
            // 傳入 cardsViewModel 以便卡片列表可以使用
            body: _buildBody(context, viewModel, cardsViewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionDetailViewModel viewModel, CardsPageViewModel? cardsViewModel) {
    switch (viewModel.state) {
      case SessionDetailPageState.loading:
        return const Center(child: CircularProgressIndicator());
      case SessionDetailPageState.error:
        return Center(child: Text(viewModel.errorMessage ?? "An error occurred"));
      case SessionDetailPageState.idle:
        final session = viewModel.session;
        if (session == null) {
          return const Center(child: Text("Session not found."));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(session, viewModel),
            const SizedBox(height: 16),
            _buildSectionHeader("Files (${session.fileResources.length})", () => viewModel.addFileToSession()),
            const SizedBox(height: 8),
            ...session.fileResources.values.map((file) => Card(
              child: ListTile(
                leading: _isImageFile(file.fileURL) 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FirebaseImage(
                        gsUri: file.fileURL,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                        ),
                      ),
                    )
                  : const Icon(Icons.description),
                title: Text(_getFileNameFromUrl(file.fileURL)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${file.id}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (file.fileSummary != null && file.fileSummary!.isNotEmpty)
                      Text(file.fileSummary!, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 24),
            _buildSectionHeader("Image Explanations (${session.imgExplanations.length})", null),
            const SizedBox(height: 8),
            ...session.imgExplanations.values.map((imgExp) => Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FirebaseImage(
                    gsUri: imgExp.imgURL,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorWidget: Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
                    ),
                  ),
                  if (imgExp.explanation != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(imgExp.explanation!),
                    ),
                ],
              ),
            )),
            
            const SizedBox(height: 24),
            _buildSectionHeader("Cards (${viewModel.cards.length})", null),
            const SizedBox(height: 8),
            // ** 關鍵修改：使用 StudyCardTile 並傳入回調 **
            ...viewModel.cards.map((card) {
              return StudyCardTile(
                card: card,
                onEdit: () {
                  if (cardsViewModel != null) {
                    showAddOrEditCardDialog(context, cardsViewModel, existingCard: card);
                  }
                },
                onDelete: () {
                  if (cardsViewModel != null) {
                    _showDeleteConfirmationDialog(context, card, cardsViewModel);
                  }
                },
              );
            }),
          ],
        );
    }
  }

  // 新增的刪除確認對話框 (與 CardManagementView 中的邏輯相同)
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

  Widget _buildSummaryCard(Session session, SessionDetailViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => viewModel.regenerateSummary(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Regenerate"),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(session.summary ?? "No summary available."),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAddPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // if (onAddPressed != null)
        //   TextButton.icon(
        //     onPressed: onAddPressed,
        //     icon: const Icon(Icons.add),
        //     label: const Text("Add"),
        //   )
      ],
    );
  }

  String _getFileNameFromUrl(String url) {
    try {
      // 從 URL 中提取文件名
      final uri = Uri.parse(url);
      String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
      // 如果文件名包含 %2F 等編碼字符，進行解碼
      fileName = Uri.decodeComponent(fileName);
      // 如果仍然是空的或看起來像 ID，則使用 "檔案" 作為默認名稱
      if (fileName.isEmpty || fileName.length > 50) {
        return '檔案';
      }
      return fileName;
    } catch (e) {
      return '檔案';
    }
  }

  bool _isImageFile(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.contains(ext));
  }
}