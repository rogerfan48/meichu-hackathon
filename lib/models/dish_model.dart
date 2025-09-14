class DishModel {
  final String dishId;
  final String dishName;
  final String veganTag;
  final String halalTag;
  final String dishGenre;
  final int dishPrice;
  final String summary;
  final String bestReviewSummary;
  final List<String> dishReviewIDs;

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.veganTag,
    required this.halalTag,
    required this.dishGenre,
    required this.dishPrice,
    String? summary,
    String? bestReviewSummary,
    List<String>? dishReviewIDs,
  }) : summary = summary ?? '',
        bestReviewSummary = bestReviewSummary ?? '',
        dishReviewIDs = dishReviewIDs ?? [];
      
  factory DishModel.fromMap(String id, Map<String, dynamic> map) {
    int price = 0;
    final dynamic rawPrice = map['dishPrice'];
    if (rawPrice is int) {
      price = rawPrice;
    } else if (rawPrice is String) {
      price = int.tryParse(rawPrice) ?? 0;
    }
    return DishModel(
      dishId: id,
      dishName: map['dishName'] as String,
      veganTag: map['veganTag'] as String,
      halalTag: map['halalTag'] as String,
      dishGenre: map['dishGenre'] as String,
      dishPrice: price,
      summary: map['summary'] as String? ?? '',
      bestReviewSummary: map['bestReviewSummary'] as String? ?? '',
      dishReviewIDs: List<String>.from(map['dishReviewIDs'] ?? []),
    );
  }
  
}
