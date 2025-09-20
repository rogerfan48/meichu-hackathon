import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/session_model.dart';
import '../repositories/session_repository.dart';
import '../services/cloud_functions_service.dart';
import '../services/storage_service.dart';

// 定義上傳頁面的各種狀態
enum UploadPageState {
  idle,         // 閒置狀態，等待用戶選擇檔案
  filesSelected,// 已選擇檔案，等待上傳
  uploading,    // 正在上傳
  success,      // 上傳成功
  error,        // 發生錯誤
}

class UploadPageViewModel extends ChangeNotifier {
  final SessionRepository sessionRepository;
  final StorageService storageService;
  final CloudFunctionsService functionsService;
  final String userId;

  // 內部狀態
  UploadPageState _state = UploadPageState.idle;
  List<File> _selectedFiles = [];
  double _uploadProgress = 0.0;
  String _statusMessage = '';
  String? _errorMessage;

  // 提供給 UI 的 getter
  UploadPageState get state => _state;
  List<File> get selectedFiles => _selectedFiles;
  double get uploadProgress => _uploadProgress;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;

  UploadPageViewModel({
    required this.sessionRepository,
    // cardRepository 在這個 ViewModel 中不是必要的，已移除
    required this.storageService,
    required this.functionsService,
    required this.userId,
  });

  void _setState(UploadPageState newState) {
    _state = newState;
    notifyListeners();
  }

  // 1. 選擇檔案
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

  // 2. 拍照
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

  // 3. 移除單一檔案
  void removeFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      _selectedFiles.removeAt(index);
      if (_selectedFiles.isEmpty) {
        _setState(UploadPageState.idle);
      } else {
        notifyListeners(); // 只更新列表，不改變頁面主狀態
      }
    }
  }

  // 4. 清除所有檔案
  void clearAllFiles() {
    _selectedFiles.clear();
    _setState(UploadPageState.idle);
  }

  // 5. 核心功能：上傳檔案並創建 Session
  Future<void> uploadAndCreateSession() async {
    if (_selectedFiles.isEmpty) return;

    _setState(UploadPageState.uploading);
    _uploadProgress = 0.0;
    _errorMessage = null;

    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final sessionName = 'Session ${DateTime.now().toString().substring(0, 16)}';
    
    try {
      // 步驟 A: 在 Firestore 中預先創建 Session 檔案
      _statusMessage = '正在創建 Session...';
      notifyListeners();
      final initialSession = Session(
        id: sessionId,
        sessionName: sessionName,
        status: 'uploading',
      );
      await sessionRepository.upsertSession(userId, initialSession);

      // 步驟 B: 逐一上傳檔案
      final totalFiles = _selectedFiles.length;
      for (int i = 0; i < totalFiles; i++) {
        final file = _selectedFiles[i];
        final fileName = p.basename(file.path);
        _statusMessage = '正在上傳檔案 ${i + 1}/$totalFiles: $fileName';
        _uploadProgress = (i / totalFiles);
        notifyListeners();

        // 上傳到 Firebase Storage
        final downloadUrl = await storageService.uploadFile(
          userId: userId,
          sessionId: sessionId,
          file: file,
        );

        // 將檔案資訊寫回 Session 檔案
        final fileResource = FileResource(
          id: fileName, // 使用檔名作為 ID
          fileURL: downloadUrl,
        );
        await sessionRepository.addFileResource(userId, sessionId, fileResource);
      }
      
      _uploadProgress = 1.0;
      _statusMessage = '所有檔案上傳完畢，正在啟動 AI 處理...';
      notifyListeners();

      // 步驟 C: 觸發 Cloud Function
      await functionsService.runSessionPipeline(userId: userId, sessionId: sessionId);

      // 步驟 D: 更新 Session 狀態為等待處理
      await sessionRepository.updateStatus(userId, sessionId, 'processing');

      // 步驟 E: 流程結束，重設 UI
      _statusMessage = '成功！新 Session "$sessionName" 已建立並進入處理佇列。';
      _setState(UploadPageState.success);
      Future.delayed(const Duration(seconds: 3), reset);

    } catch (e) {
      _errorMessage = '上傳失敗: $e';
      _setState(UploadPageState.error);
      // 若失敗，更新 Session 狀態
      await sessionRepository.updateStatus(userId, sessionId, 'failed');
    }
  }

  // 6. 重設頁面狀態
  void reset() {
    _selectedFiles.clear();
    _uploadProgress = 0.0;
    _statusMessage = '';
    _errorMessage = null;
    _setState(UploadPageState.idle);
  }
}