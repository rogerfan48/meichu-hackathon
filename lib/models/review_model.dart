class ReviewModel {
  final String? reviewID;
  final String reviewerID;
  final String restaurantID;
  final String? dishID;
  final List<String> agreedBy;
  final List<String> disagreedBy;
  final int rating;
  final int? priceLevel;
  final String content;
  final String reviewDate;
  final List<String> reviewImgURLs;

  ReviewModel({
    this.reviewID,
    required this.reviewerID,
    required this.restaurantID,
    List<String>? agreedBy,
    List<String>? disagreedBy,
    required this.rating,
    required this.content,
    required this.reviewDate,
    this.dishID,
    this.priceLevel,
    List<String>? reviewImgURLs,
  }) : agreedBy = agreedBy ?? [],
       disagreedBy = disagreedBy ?? [],
       reviewImgURLs = reviewImgURLs ?? [];

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      reviewID: id,
      reviewerID: map['reviewerID'] as String,
      restaurantID: map['restaurantID'] as String,
      dishID: map['dishID'] as String?,
      agreedBy: List<String>.from(map['agreedBy'] ?? []),
      disagreedBy: List<String>.from(map['disagreedBy'] ?? []),
      rating: map['rating'] as int,
      priceLevel: map['priceLevel'] as int?,
      content: map['content'] as String,
      reviewDate: map['reviewDate'] as String,
      reviewImgURLs: List<String>.from(map['reviewImgURLs'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewerID': reviewerID,
      'restaurantID': restaurantID,
      'dishID': dishID,
      'agreedBy': agreedBy,
      'disagreedBy': disagreedBy,
      'rating': rating,
      'priceLevel': priceLevel,
      'content': content,
      'reviewDate': reviewDate,
      'reviewImgURLs': reviewImgURLs,
    };
  }
}
