import 'package:foodie/models/dish_model.dart';

class RestaurantModel {
  final String restaurantId;    // ← new
  final String restaurantName;
  final String summary;
  final List<String> genreTags;
  final Map<String, String> businessHour;
  final String phoneNumber;
  final String address;
  final List<String> restaurantReviewIDs;
  final double latitude;
  final double longitude;
  final Map<String, DishModel> menuMap;
  final String? googleMapURL;
  final String veganTag;
  final double? averageRating; // Optional, can be calculated
  final int? averagePriceLevel; // Optional, can be calculated

  RestaurantModel({
    required this.restaurantId,  // ← new
    required this.restaurantName,
    required this.summary,
    required this.genreTags,
    required this.businessHour,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.menuMap,
    required this.veganTag,
    this.averageRating,
    this.averagePriceLevel,
    this.googleMapURL,
    List<String>? restaurantReviewIDs,
  }) : restaurantReviewIDs = restaurantReviewIDs ?? [];

  // factory RestaurantModel.fromMap(Map<String, dynamic> map) {
  //   return RestaurantModel(
  //     restaurantName: map['restaurantName'] as String,
  //     summary: map['summary'] as String,
  //     genreTags: List<String>.from(map['genreTags'] as List),
  //     businessHour: Map<String, String>.from(map['businessHour'] as Map),
  //     phoneNumber: map['phoneNumber'] as String,
  //     address: map['address'] as String,
  //     latitude: map['latitude'] as double,
  //     longtitude: map['longtitude'] as double,
  //     menuMap: (map['menu'] as Map<String, dynamic>).map(
  //       (key, value) => MapEntry(
  //         key,
  //         DishModel.fromMap(value as Map<String, dynamic>),
  //       ),
  //     ),
  //     restaurantReviewIDs: List<String>.from(map['restaurantReviewIDs'] ?? []),
  //   );
  // }
}


