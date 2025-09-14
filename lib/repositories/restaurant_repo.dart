import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/dish_model.dart';

class RestaurantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _restaurantCollection;
  final timeout = const Duration(seconds: 10);

  RestaurantRepository()
    : _restaurantCollection = FirebaseFirestore.instance.collection('apps/foodie/restaurants');

  Stream<Map<String, RestaurantModel>> streamRestaurantMap() {
    return _db.collection('apps/foodie/restaurants').snapshots().asyncMap((snapshot) async {
      final entries = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final menu = await doc.reference.collection('menu').get();
          final menuMap = {
            for (var dishDoc in menu.docs)
              dishDoc.id: DishModel.fromMap(dishDoc.id, dishDoc.data()),
          };

          final restaurant = RestaurantModel(
            restaurantId: doc.id, // ← pass the ID
            restaurantName: data['restaurantName'] as String,
            summary: data['summary'] as String,
            genreTags: List<String>.from(data['genreTags'] as List),
            businessHour: Map<String, String>.from(data['businessHour'] as Map),
            phoneNumber: data['phoneNumber'] as String,
            address: data['address'] as String,
            latitude: data['latitude'] as double,
            longitude: data['longitude'] as double,
            googleMapURL: data['googleMapURL'] as String,
            veganTag: data['veganTag'] as String,
            menuMap: menuMap,
            averageRating: (data['averageRating'] as num?)?.toDouble(),
            averagePriceLevel: data['averagePriceLevel'] as int?,
            restaurantReviewIDs: List<String>.from(data['restaurantReviewIDs'] ?? []),
          );
          return MapEntry(doc.id, restaurant);
        }),
      );
      return Map.fromEntries(entries);
    });
  }

  Future<void> addReviewIdToRestaurant({required String restaurantId, required String reviewId}) {
    return _restaurantCollection.doc(restaurantId).update({
      'restaurantReviewIDs': FieldValue.arrayUnion([reviewId]),
    });
  }

  Future<void> addReviewIdToDish({
    required String restaurantId,
    required String dishId,
    required String reviewId,
  }) {
    return _restaurantCollection.doc(restaurantId).collection('menu').doc(dishId).update({
      'dishReviewIDs': FieldValue.arrayUnion([reviewId]),
    });
  }

  Future<void> removeReviewIdFromRestaurant({
    required String restaurantId,
    required String reviewId,
  }) {
    return _restaurantCollection.doc(restaurantId).update({
      'restaurantReviewIDs': FieldValue.arrayRemove([reviewId]),
    });
  }

  Future<void> removeReviewIdFromDish({
    required String restaurantId,
    required String dishId,
    required String reviewId,
  }) {
    return _restaurantCollection.doc(restaurantId).collection('menu').doc(dishId).update({
      'dishReviewIDs': FieldValue.arrayRemove([reviewId]),
    });
  }

  Future<void> updateAverageRating({
    required String restaurantId,
    required double newAverageRating,
  }) {
    return _restaurantCollection.doc(restaurantId).update({
      'averageRating': newAverageRating,
    });
  }

  Future<void> updateAveragePriceLevel({
    required String restaurantId,
    required int newAveragePriceLevel,
  }) {
    return _restaurantCollection.doc(restaurantId).update({
      'averagePriceLevel': newAveragePriceLevel,
    });
  }
}
