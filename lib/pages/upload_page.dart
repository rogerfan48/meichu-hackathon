import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../view_models/upload_page_view_model.dart';
import '../view_models/account_vm.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  // 輔助方法：根據副檔名判斷是否為圖片
  bool _isImageFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final accountVM = context.watch<AccountViewModel>();

    if (!accountVM.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('上傳檔案'), automaticallyImplyLeading: false),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              '請先至「設定」頁面登入以使用上傳功能。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Consumer<UploadPageViewModel?>(
      builder: (context, viewModel, child) {
        if (viewModel == null) {
          return const Scaffold(body: Center(child: Text('ViewModel 初始化失敗')));
        }

        final bool isActionInProgress =
            viewModel.state == UploadPageState.uploading ||
            viewModel.state == UploadPageState.success;

        return Scaffold(
          appBar: AppBar(title: const Text('上傳檔案'), automaticallyImplyLeading: false),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isActionInProgress ? null : () => viewModel.takePhoto(),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('拍照'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isActionInProgress ? null : () => viewModel.pickFromGallery(),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('相簿'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildMainContent(context, viewModel)),
                const SizedBox(height: 16),
                _buildBottomButton(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, UploadPageViewModel viewModel) {
    switch (viewModel.state) {
      case UploadPageState.idle:
        return _buildUploadArea(context, viewModel);
      case UploadPageState.filesSelected:
        return _buildFileManagementArea(context, viewModel);
      case UploadPageState.uploading:
      case UploadPageState.success:
      case UploadPageState.error:
        return _buildProgressArea(context, viewModel);
    }
  }

  Widget _buildUploadArea(BuildContext context, UploadPageViewModel viewModel) {
    // ... 此方法保持不變 ...
    return Card(
      child: InkWell(
        onTap: () => viewModel.pickFiles(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '選擇檔案以上傳',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '支援格式: PDF, DOC, TXT, PNG, JPG',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => viewModel.pickFiles(),
                icon: const Icon(Icons.upload_file),
                label: const Text('選擇檔案'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileManagementArea(BuildContext context, UploadPageViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已選檔案 (${viewModel.selectedFiles.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () => viewModel.clearAllFiles(), child: const Text('全部清除')),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Card(
            child: ListView.builder(
              itemCount: viewModel.selectedFiles.length,
              itemBuilder: (context, index) {
                final file = viewModel.selectedFiles[index];
                final fileSize = file.lengthSync();
                return ListTile(
                  // ** 關鍵修改 **
                  leading:
                      _isImageFile(file.path)
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.file(file, width: 40, height: 40, fit: BoxFit.cover),
                          )
                          : Icon(_getFileIcon(p.extension(file.path))),
                  title: Text(p.basename(file.path), overflow: TextOverflow.ellipsis),
                  subtitle: Text('${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
                  trailing: IconButton(
                    onPressed: () => viewModel.removeFile(index),
                    icon: const Icon(Icons.close),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => viewModel.pickFiles(),
          icon: const Icon(Icons.add),
          label: const Text('新增更多檔案'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
        ),
      ],
    );
  }

  Widget _buildProgressArea(BuildContext context, UploadPageViewModel viewModel) {
    // ... 此方法保持不變 ...
    IconData icon;
    Color iconColor;
    Widget progressWidget;

    switch (viewModel.state) {
      case UploadPageState.uploading:
        icon = Icons.cloud_upload;
        iconColor = Theme.of(context).primaryColor;
        progressWidget = Column(
          children: [
            LinearProgressIndicator(value: viewModel.uploadProgress),
            const SizedBox(height: 8),
            Text('${(viewModel.uploadProgress * 100).toInt()}%'),
          ],
        );
        break;
      case UploadPageState.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        progressWidget = const Text('處理完成！');
        break;
      case UploadPageState.error:
        icon = Icons.error;
        iconColor = Colors.red;
        progressWidget = Text(
          viewModel.errorMessage ?? '發生未知錯誤',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 24),
            Text(
              viewModel.statusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            progressWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, UploadPageViewModel viewModel) {
    switch (viewModel.state) {
      case UploadPageState.idle:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('上傳並生成總結', style: TextStyle(fontSize: 16)),
        );
      case UploadPageState.filesSelected:
        return ElevatedButton.icon(
          onPressed: () => viewModel.uploadAndCreateSession(),
          icon: Icon(Icons.cloud_upload, color: Theme.of(context).colorScheme.onPrimary),
          label: Text(
            '上傳並生成總結',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      case UploadPageState.uploading:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('正在上傳...', style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      case UploadPageState.error:
        return ElevatedButton.icon(
          onPressed: () => viewModel.reset(),
          icon: const Icon(Icons.refresh),
          label: const Text('重試', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.orange,
          ),
        );
      case UploadPageState.success:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: const Text('上傳成功', style: TextStyle(fontSize: 16)),
        );
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.txt':
        return Icons.text_snippet;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
