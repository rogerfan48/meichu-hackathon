import 'package:flutter/foundation.dart';
import '../repositories/session_repository.dart';
import '../repositories/card_repository.dart';
import '../services/cloud_functions_service.dart';
import '../services/storage_service.dart';
import '../models/card_model.dart';

/// ViewModel scoped only to the UploadPage (creating a new session and initial file uploads).
class UploadPageViewModel extends ChangeNotifier {
  UploadPageViewModel({
    required this.sessionRepository,
    required this.cardRepository,
    required this.storageService,
    required this.functionsService,
    required this.userId,
  });

  final SessionRepository sessionRepository;
  final CardRepository cardRepository;
  final StorageService storageService;
  final CloudFunctionsService functionsService;
  final String userId;

  final bool _creating = false;
  bool get isCreating => _creating; // reserved for future toggle

  Future<String> createNewSessionId() async {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Add a card to a specific session
  Future<void> addCard({
    required String sessionId,
    required String text,
    List<String> tags = const [],
    String? imgURL,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      final cardId = cardRepository.newCardId();
      final card = StudyCard(
        id: cardId,
        sessionID: sessionId,
        text: text.trim(),
        tags: tags,
        imgURL: imgURL,
      );

      await cardRepository.upsertCard(userId, card);
      await sessionRepository.addCardLink(userId, sessionId, cardId);
    } catch (e) {
      if (kDebugMode) print('Failed to add card: $e');
    }
  }

  // Future: move lightweight pre-validation / name suggestion here.
}
