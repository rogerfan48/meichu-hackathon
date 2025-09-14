import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';

class MyReviewDisplay {
  final String restaurantName;
  final ReviewModel review;

  MyReviewDisplay({required this.restaurantName, required this.review});
}

class MyReviewViewModel with ChangeNotifier {
  final String _userId;
  final ReviewRepository _reviewRepository;
  final RestaurantRepository _restaurantRepository;
  final UserRepository _userRepository;
  final Map<String, UserModel> _userCache = {};

  late final StreamSubscription<Map<String, ReviewModel>> _reviewSubscription;
  late final StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;

  Map<String, RestaurantModel> _restaurantMap = {};
  final List<MyReviewDisplay> _myReviews = [];

  List<MyReviewDisplay> get myReviews => _myReviews;

  MyReviewViewModel(
    this._userId,
    this._reviewRepository,
    this._restaurantRepository,
    this._userRepository,
  ) {
    _restaurantSubscription = _restaurantRepository.streamRestaurantMap().listen((restaurantMap) {
      _restaurantMap = restaurantMap;
      _updateReviews(_myReviews.map((e) => e.review).toList());
    });

    _reviewSubscription = _reviewRepository.streamReviewMap().listen((allReviews) {
      final userReviews = allReviews.values.where((r) => r.reviewerID == _userId).toList();
      _updateReviews(userReviews);
    });
  }

  void _updateReviews(List<ReviewModel> userReviews) {
    _myReviews.clear();
    for (var review in userReviews) {
      final restaurantName =
          _restaurantMap[review.restaurantID]?.restaurantName ?? 'Unknown Restaurant';
      _myReviews.add(MyReviewDisplay(restaurantName: restaurantName, review: review));
    }
    _myReviews.sort(
      (a, b) => DateTime.parse(b.review.reviewDate).compareTo(DateTime.parse(a.review.reviewDate)),
    );
    notifyListeners();
  }

  Future<void> toggleReviewVote({
    required String reviewId,
    required String currentUserId,
    required VoteType voteType,
    required bool isCurrentlyVoted,
  }) async {
    try {
      await _reviewRepository.toggleVote(
        reviewId: reviewId,
        userId: currentUserId,
        voteType: voteType,
        isCurrentlyVoted: isCurrentlyVoted,
      );
    } catch (e) {
      print("Failed to toggle vote in MyReviewViewModel: $e");
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    try {
      final userDoc = await _userRepository.getUser(userId);
      if (userDoc.exists) {
        final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        _userCache[userId] = user;
        return user;
      }
      return null;
    } catch (e) {
      print("Error fetching user data in MyReviewViewModel: $e");
      return null;
    }
  }

  String? getDishNameById(String restaurantId, String dishId) {
    final restaurant = _restaurantMap[restaurantId];
    if (restaurant == null) return null;
    return restaurant.menuMap[dishId]?.dishName;
  }

  @override
  void dispose() {
    _reviewSubscription.cancel();
    _restaurantSubscription.cancel();
    super.dispose();
  }
}
