import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadFile({required String userId, required String sessionId, required File file}) async {
    final ref = _storage.ref().child('$userId/$sessionId/${file.uri.pathSegments.last}');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
