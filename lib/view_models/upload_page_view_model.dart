import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // 引入 Firestore
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/session_model.dart';
import '../repositories/session_repository.dart';
import '../services/cloud_functions_service.dart';
import '../services/storage_service.dart';

enum UploadPageState { idle, filesSelected, uploading, success, error }

class UploadPageViewModel extends ChangeNotifier {
  final SessionRepository sessionRepository;
  final StorageService storageService;
  final CloudFunctionsService functionsService;
  final String userId;

  UploadPageState _state = UploadPageState.idle;
  List<File> _selectedFiles = [];
  double _uploadProgress = 0.0;
  String _statusMessage = '';
  String? _errorMessage;

  UploadPageState get state => _state;
  List<File> get selectedFiles => _selectedFiles;
  double get uploadProgress => _uploadProgress;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  UploadPageViewModel({
    required this.sessionRepository,
    required this.storageService,
    required this.functionsService,
    required this.userId,
  });

  void _setState(UploadPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)));
        _setState(UploadPageState.filesSelected);
      }
    } catch (e) {
      _errorMessage = '無法選擇檔案: $e';
      _setState(UploadPageState.error);
    }
  }

  Future<void> takePhoto() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        _selectedFiles.add(File(image.path));
        _setState(UploadPageState.filesSelected);
      }
    } catch (e) {
      _errorMessage = '無法拍照: $e';
      _setState(UploadPageState.error);
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      _selectedFiles.removeAt(index);
      if (_selectedFiles.isEmpty) {
        _setState(UploadPageState.idle);
      } else {
        notifyListeners();
      }
    }
  }

  void clearAllFiles() {
    _selectedFiles.clear();
    _setState(UploadPageState.idle);
  }

  Future<void> uploadAndCreateSession() async {
    if (_selectedFiles.isEmpty) return;
    _setState(UploadPageState.uploading);
    _uploadProgress = 0.0;
    _errorMessage = null;

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionName = 'Session ${DateTime.now().toString().substring(0, 16)}';
    
    try {
      _statusMessage = '正在創建 Session...';
      notifyListeners();
      final initialSession = Session(
        id: sessionId,
        sessionName: sessionName,
        status: 'uploading',
        createdAt: Timestamp.now(), // ** 關鍵修改 **
      );
      await sessionRepository.upsertSession(userId, initialSession);

      final totalFiles = _selectedFiles.length;
      for (int i = 0; i < totalFiles; i++) {
        final file = _selectedFiles[i];
        final fileName = p.basename(file.path);
        _statusMessage = '正在上傳檔案 ${i + 1}/$totalFiles: $fileName';
        _uploadProgress = (i / totalFiles);
        notifyListeners();
        final downloadUrl = await storageService.uploadFile(userId: userId, sessionId: sessionId, file: file);
        final fileResource = FileResource(id: fileName, fileURL: downloadUrl);
        await sessionRepository.addFileResource(userId, sessionId, fileResource);
      }
      
      _uploadProgress = 1.0;
      _statusMessage = '所有檔案上傳完畢，正在啟動 AI 處理...';
      notifyListeners();

      await functionsService.runSessionPipeline(userId: userId, sessionId: sessionId);
      await sessionRepository.updateStatus(userId, sessionId, 'processing');

      _statusMessage = '成功！新 Session "$sessionName" 已建立並進入處理佇列。';
      _setState(UploadPageState.success);
      Future.delayed(const Duration(seconds: 3), reset);
    } catch (e) {
      _errorMessage = '上傳失敗: $e';
      _setState(UploadPageState.error);
      await sessionRepository.updateStatus(userId, sessionId, 'failed');
    }
  }

  void reset() {
    _selectedFiles.clear();
    _uploadProgress = 0.0;
    _statusMessage = '';
    _errorMessage = null;
    _setState(UploadPageState.idle);
  }
}