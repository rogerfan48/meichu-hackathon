import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../repositories/session_repository.dart';
import '../repositories/card_repository.dart';
import '../models/session_model.dart';
import '../models/card_model.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';
import '../services/storage_service.dart';
import '../services/cloud_functions_service.dart';

class UploadViewModel extends ChangeNotifier {
  UploadViewModel({
    required this.sessionRepository,
    required this.cardRepository,
    required this.aiService,
    required this.ocrService,
    required this.userId,
    required this.storageService,
    required this.functionsService,
  });

  final SessionRepository sessionRepository;
  final CardRepository cardRepository;
  final AIService aiService;
  final OCRService ocrService;
  final String userId;
  final StorageService storageService;
  final CloudFunctionsService functionsService;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Session? _currentSession;
  Session? get currentSession => _currentSession;
  StreamSubscription<Session>? _sessionSub;

  Future<void> startUploadSession({required String sessionId, required String sessionName}) async {
    if (_isProcessing) return;
    _isProcessing = true;
    notifyListeners();

    _currentSession = Session(
      id: sessionId,
      sessionName: sessionName,
      fileResources: {},
      summary: null,
      imgExplanations: {},
      cardIDs: const [],
      status: 'uploading',
    );
    await sessionRepository.upsertSession(userId, _currentSession!);

    // Start listening to server-side changes for this session
    _sessionSub?.cancel();
    _sessionSub = sessionRepository.watchSession(userId, sessionId).listen((remote) {
      _currentSession = remote;
      notifyListeners();
    });

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> pickAndUploadFiles() async {
    if (_currentSession == null) return;
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return; // user canceled
    _isProcessing = true;
    notifyListeners();

    final sessionId = _currentSession!.id;
    final uploaded = <String, FileResource>{};
    for (final f in result.files) {
      if (f.path == null) continue;
      final file = File(f.path!);
      final fileId = f.identifier ?? f.name;
      try {
  final url = await storageService.uploadFile(userId: userId, sessionId: sessionId, file: file);
        // Placeholder: OCR / summary extraction per file could go here
        uploaded[fileId] = FileResource(id: fileId, fileURL: url, fileSummary: null);
        await sessionRepository.addFileResource(userId, sessionId, uploaded[fileId]!);
      } catch (e) {
        if (kDebugMode) {
          print('Upload failed for ${f.name}: $e');
        }
      }
    }

    // After files uploaded trigger pipeline
    await sessionRepository.updateStatus(userId, sessionId, 'processing');
    // Avoid manual overwrite if stream will bring updated snapshot soon; only optimistic merge of file list.
    _currentSession = _currentSession?.copyWith(fileResources: {
      ..._currentSession!.fileResources,
      ...uploaded,
    });
    notifyListeners();

    // Fire and forget pipeline (no await to keep UI responsive)
    unawaited(functionsService.runSessionPipeline(userId: userId, sessionId: sessionId));

    _isProcessing = false;
    notifyListeners();
  }

  // Placeholder: real implementation will gather file texts, call AIService, update Firestore.
  Future<void> generateSummaryAndCards(String combinedText) async {
    if (_currentSession == null) return;
    _isProcessing = true;
    notifyListeners();

    final summary = await aiService.summarizeText(combinedText);
    final terms = await aiService.extractKeyTerms(combinedText);

    final updated = _currentSession!.copyWith(summary: summary);
    _currentSession = updated;
    await sessionRepository.upsertSession(userId, updated);

    for (final t in terms) {
      final cardId = t; // placeholder id
      final card = StudyCard(id: cardId, sessionID: updated.id, text: t, tags: const []);
      await cardRepository.upsertCard(userId, card);
      await sessionRepository.addCardLink(userId, updated.id, card.id);
    }

    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }
}
