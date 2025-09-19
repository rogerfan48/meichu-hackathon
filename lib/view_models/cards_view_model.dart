import 'package:flutter/foundation.dart';
import '../repositories/card_repository.dart';
import '../models/card_model.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({required this.cardRepository, required this.userId});

  final CardRepository cardRepository;
  final String userId;

  List<StudyCard> _cards = [];
  List<StudyCard> get cards => _cards;

  bool _loading = false;
  bool get loading => _loading;

  Stream<List<StudyCard>>? _stream;

  void initialize(Stream<List<StudyCard>> stream) {
    _loading = true;
    notifyListeners();
    _stream = stream;
    _stream!.listen((data) {
      _cards = data;
      _loading = false;
      notifyListeners();
    });
  }
}
