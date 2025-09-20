import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

/// 一個自訂 Widget，專門用於顯示來自 Firebase Storage 的圖片。
/// 它接收一個 gs:// URI，並在內部處理 URL 轉換和顯示。
class FirebaseImage extends StatelessWidget {
  final String gsUri;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;

  const FirebaseImage({
    super.key,
    required this.gsUri,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 context.read 是因為我們只需要 StorageService 的實例來呼叫方法，
    // 不需要監聽它的變化。
    final storageService = context.read<StorageService>();

    // 使用 FutureBuilder 來處理非同步獲取下載 URL 的過程
    return FutureBuilder<String>(
      // a future 就是我們要執行的非同步任務
      future: storageService.getDownloadUrl(gsUri),
      builder: (context, snapshot) {
        // 情況 1: 正在等待 future 完成
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // 情況 2: future 完成，但發生了錯誤或沒有返回有效的 URL
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return errorWidget ?? Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        }

        // 情況 3: future 成功完成，我們拿到了下載 URL
        final downloadUrl = snapshot.data!;
        return Image.network(
          downloadUrl,
          width: width,
          height: height,
          fit: fit,
          // 這裡的 loadingBuilder 和 errorBuilder 是針對 Image.network 本身的
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}