import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_model.freezed.dart';
part 'card_model.g.dart';

@freezed
abstract class StudyCard with _$StudyCard {
  const factory StudyCard({
    required String id,
    required String sessionID,
    @Default(<String>[]) List<String> tags,
    String? imgURL,
    required String text,
  }) = _StudyCard;

  factory StudyCard.fromJson(Map<String, dynamic> json) => _$StudyCardFromJson(json);

  factory StudyCard.fromFirestore(Map<String, dynamic> json, String id) =>
      StudyCard.fromJson({...json, 'id': id});
}
