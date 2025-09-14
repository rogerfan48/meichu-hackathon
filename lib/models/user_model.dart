class UserModel {
  String? uid; // Google Auth UID
  final String userName;
  final String? photoURL;
  final Map<String, List<String>> viewedRestaurantIDs; // (ID, [viewDate])
  final List<String> userReviewIDs;

  UserModel({
    required this.userName,
    this.photoURL,
    Map<String, List<String>>? viewedRestaurantIDs,
    List<String>? userReviewIDs,
  })  : viewedRestaurantIDs = viewedRestaurantIDs ?? {},
        userReviewIDs     = userReviewIDs     ?? [];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawMap = map['viewedRestaurantIDs'] as Map<String, dynamic>? ?? {};
    final viewedMap = <String, List<String>>{};
    rawMap.forEach((key, value) {
      if (value is String) {
        // migrate old single‐string date to a one‐element list
        viewedMap[key] = [value];
      } else if (value is List) {
        viewedMap[key] = List<String>.from(value);
      }
    });
    return UserModel(
      userName: map['userName'] as String,
      photoURL: map['photoURL'] as String?,
      viewedRestaurantIDs: viewedMap,
      userReviewIDs: List<String>.from(map['userReviewIDs'] ?? []),
    );
  }
}

