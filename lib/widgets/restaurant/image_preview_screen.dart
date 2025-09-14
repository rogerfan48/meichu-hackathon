import 'package:flutter/material.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

void showImagePreview(BuildContext context, String gsUri) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Image Preview',
    // 半透明黑色背景
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 200),
    // 主要內容
    pageBuilder: (context, animation, secondaryAnimation) {
      return ImagePreviewScreen(gsUri: gsUri);
    },
    // 過渡動畫 (淡入淡出)
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class ImagePreviewScreen extends StatelessWidget {
  final String gsUri;

  const ImagePreviewScreen({super.key, required this.gsUri});

  @override
  Widget build(BuildContext context) {
    final storageService = context.read<StorageService>();

    return Scaffold(
      // 背景設為透明，讓 showGeneralDialog 的 barrierColor 生效
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // 點擊任何地方都可以關閉預覽
        onTap: () => Navigator.of(context).pop(),
        child: FutureBuilder<String?>(
          future: storageService.getDownloadUrl(gsUri),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50));
            }

            // 使用 PhotoView 來顯示圖片，並提供縮放功能
            return PhotoView(
              imageProvider: NetworkImage(snapshot.data!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.0,
              heroAttributes: PhotoViewHeroAttributes(tag: gsUri), // 實現平滑的 Hero 動畫
              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
            );
          },
        ),
      ),
    );
  }
}
