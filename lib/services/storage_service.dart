import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadFile({required String userId, required String sessionId, required File file}) async {
    final fileName = p.basename(file.path);
    final ref = _storage.ref().child('users/$userId/$sessionId/$fileName');
    
    final task = await ref.putFile(file);
    return 'gs://${_storage.bucket}/${task.ref.fullPath}';
  }

  Future<String> getDownloadUrl(String gsUri) async {
    try {
      final ref = _storage.refFromURL(gsUri);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error converting gs:// URI to download URL: $e");
      return '';
    }
  }
}