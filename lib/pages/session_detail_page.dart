import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../view_models/account_vm.dart';
import '../view_models/session_detail_view_model.dart';
import '../widgets/firebase_image.dart';
import '../widgets/shared/study_card_tile.dart'; // ** 引入新的共用 Widget **

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
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionDetailViewModel viewModel) {
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
                leading: const Icon(Icons.description),
                title: Text(file.id),
                subtitle: Text(file.fileURL, overflow: TextOverflow.ellipsis),
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
            // ** 關鍵修改：使用 StudyCardTile 來顯示卡片列表 **
            ...viewModel.cards.map((card) {
              // 在這個頁面，我們不提供刪除或編輯功能，所以不傳遞回調
              return StudyCardTile(card: card);
            }),
          ],
        );
    }
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
        if (onAddPressed != null)
          TextButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          )
      ],
    );
  }
}