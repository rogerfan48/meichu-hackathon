import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // 快取 Map，用來儲存已經獲取過的下載連結，避免重複請求
  final Map<String, String> _downloadUrlCache = {};

  Future<String?> getDownloadUrl(String? gsUri) async {
    if (gsUri == null || !gsUri.startsWith('gs://')) {
      return null;
    }

    // 如果快取中已有，直接返回
    if (_downloadUrlCache.containsKey(gsUri)) {
      return _downloadUrlCache[gsUri];
    }

    try {
      // 如果快取中沒有，則從 Firebase Storage 獲取
      final url = await _storage.refFromURL(gsUri).getDownloadURL();
      // 存入快取
      _downloadUrlCache[gsUri] = url;
      return url;
    } catch (e) {
      print('Error getting download URL for $gsUri: $e');
      return null; // 獲取失敗返回 null
    }
  }

  Future<String> uploadReviewImage({required File file, required String userId}) async {
    try {
      // 1. 生成一個唯一的檔案名稱，避免重名覆蓋
      final String fileName = '${const Uuid().v4()}.jpg';

      // 2. 定義上傳路徑：reviews/{使用者ID}/{唯一檔案名稱}
      final String filePath = 'reviews/$userId/$fileName';

      // 3. 獲取 Storage 的引用
      final storageRef = _storage.ref(filePath);

      // 4. 執行上傳
      await storageRef.putFile(file);

      // 5. 返回 gs:// 格式的 URI
      return 'gs://${storageRef.bucket}/${storageRef.fullPath}';
    } on FirebaseException catch (e) {
      print("Firebase Storage upload error: $e");
      // 重新拋出錯誤，讓上層的 ViewModel 知道上傳失敗
      rethrow;
    }
  }

  Future<String> uploadReceiptImage({required File file, required String userId}) async {
    try {
      // 1. 生成一個唯一的檔案名稱，避免重名覆蓋
      final String fileName = '${const Uuid().v4()}.jpg';

      // 2. 定義上傳路徑：reviews/{使用者ID}/{唯一檔案名稱}
      final String filePath = 'receipts/$userId/$fileName';

      // 3. 獲取 Storage 的引用
      final storageRef = _storage.ref(filePath);

      // 4. 執行上傳
      await storageRef.putFile(file);

      // 5. 返回 gs:// 格式的 URI
      return 'gs://${storageRef.bucket}/${storageRef.fullPath}';
    } on FirebaseException catch (e) {
      print("Firebase Storage upload error: $e");
      // 重新拋出錯誤，讓上層的 ViewModel 知道上傳失敗
      rethrow;
    }
  }

  Future<void> deleteImage(String gsUri) async {
    if (!gsUri.startsWith('gs://')) return;
    try {
      await _storage.refFromURL(gsUri).delete();
    } catch (e) {
      print("Error deleting image $gsUri: $e");
    }
  }
}
