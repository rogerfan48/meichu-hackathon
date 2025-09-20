import 'package:flutter/foundation.dart';
import '../repositories/card_repository.dart';
import '../repositories/session_repository.dart';
import '../models/card_model.dart';

/// ViewModel for realtime screen capture functionality
class RealtimeCaptureViewModel extends ChangeNotifier {
  RealtimeCaptureViewModel({
    required this.cardRepository,
    required this.sessionRepository,
    required this.userId,
  });

  final CardRepository cardRepository;
  final SessionRepository sessionRepository;
  final String userId;

  bool _processing = false;
  bool get processing => _processing;

  /// Add a card from captured screen content
  Future<void> addCardFromCapture({
    String? sessionId,
    required String text,
    List<String> tags = const [],
    String? imgURL,
  }) async {
    if (text.trim().isEmpty) return;
    
    _processing = true;
    notifyListeners();

    try {
      final cardId = cardRepository.newCardId();
      final card = StudyCard(
        id: cardId,
        sessionID: sessionId ?? 'default', // fallback to default session if none specified
        text: text.trim(),
        tags: tags,
        imgURL: imgURL,
      );

      await cardRepository.upsertCard(userId, card);
      
      // Link to session if specified
      if (sessionId != null) {
        await sessionRepository.addCardLink(userId, sessionId, cardId);
      }
    } catch (e) {
      if (kDebugMode) print('Failed to add card from capture: $e');
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  /// Quick add card with minimal input
  Future<void> quickAddCard(String text, {String? sessionId}) async {
    await addCardFromCapture(
      sessionId: sessionId,
      text: text,
      tags: ['realtime-capture'],
    );
  }
}