import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/sessions_page_view_model.dart';
import '../models/session_model.dart';
import '../view_models/account_vm.dart';
import 'package:intl/intl.dart'; // 引入日期格式化工具

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();
    if (!accountVM.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('上傳紀錄'), automaticallyImplyLeading: false),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              '請先至「設定」頁面登入以查看您的上傳紀錄。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Consumer<SessionsPageViewModel?>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('上傳紀錄'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
                tooltip: '刷新',
              ),
            ],
          ),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SessionsPageViewModel? viewModel) {
    if (viewModel == null) {
      return const Center(child: Text('ViewModel 初始化中...'));
    }

    switch (viewModel.state) {
      case SessionsPageState.loading:
        return const Center(child: CircularProgressIndicator());
      case SessionsPageState.error:
        return Center(
          child: Text(viewModel.errorMessage ?? '發生未知錯誤',
              style: const TextStyle(color: Colors.red)),
        );
      case SessionsPageState.idle:
        if (viewModel.sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('尚無上傳紀錄', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('請到「上傳」頁面建立您的第一個 Session！',
                  style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: viewModel.sessions.length,
          itemBuilder: (context, index) {
            final session = viewModel.sessions[index];
            return _buildSessionCard(context, session, viewModel);
          },
        );
    }
  }

  Widget _buildSessionCard(BuildContext context, Session session, SessionsPageViewModel viewModel) {
    // ** 關鍵修改 **
    // 使用 createdAt 欄位，並提供一個 fallback 以相容舊資料
    final createdAt = session.createdAt?.toDate() ?? DateTime.now();
    final createdAtString = DateFormat('yyyy/MM/dd HH:mm').format(createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          session.sessionName.isEmpty ? 'Session ${session.id}' : session.sessionName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('建立於: $createdAtString'),
            const SizedBox(height: 4),
            Text('包含 ${session.fileResources.length} 個檔案, ${session.cardIDs.length} 張卡片'),
            if (session.summary != null && session.summary!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '總結: ${session.summary!}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Chip(
              label: Text(session.status),
              backgroundColor: _getStatusColor(session.status),
              labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            )
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'rename') {
              _showRenameDialog(context, session, viewModel);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, session, viewModel);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'rename', child: Text('重新命名')),
            const PopupMenuItem(value: 'delete', child: Text('刪除', style: TextStyle(color: Colors.red))),
          ],
        ),
        onTap: () {
          context.go('/history/${session.id}');
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'uploading': return Colors.blue;
      case 'processing': return Colors.orange;
      case 'completed': return Colors.green;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Session session, SessionsPageViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('您確定要刪除 "${session.sessionName}" 嗎？此操作無法復原。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          TextButton(
            onPressed: () {
              viewModel.deleteSession(session.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Session session, SessionsPageViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重新命名功能尚未實作')),
    );
  }
}