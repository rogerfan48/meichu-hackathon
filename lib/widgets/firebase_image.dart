import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:provider/provider.dart';

class FirebaseImage extends StatelessWidget {
  final String? gsUri;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FirebaseImage({
    super.key,
    required this.gsUri,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (gsUri == null || gsUri!.isEmpty) {
      return _buildPlaceholder(context);
    }

    final storageService = context.read<StorageService>();

    return FutureBuilder<String?>(
      future: storageService.getDownloadUrl(gsUri),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildPlaceholder(context);
        }

        final url = snapshot.data!;
        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
          },
          // 網路圖片加載失敗的佔位符
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(context, error: true);
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool error = false}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        size: min(width ?? 20, height ?? 20),
        // 如果是加載錯誤，顯示錯誤圖示，否則顯示預設圖示
        error ? Icons.error_outline : Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
