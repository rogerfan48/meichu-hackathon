import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/user_repo.dart';

class ViewedRestaurant {
  String? restaurantId;  // Add this field
  DateTime? viewDate;
  String? restaurantName;
  GenreTag? genreTag;
}

class ViewedRestaurantsViewModel with ChangeNotifier {
  final String _userId;
  final UserRepository _userRepository;
  final RestaurantRepository _restaurantRepository;
  
  late StreamSubscription<Map<String, UserModel>> _userSubscription;
  late StreamSubscription<Map<String, RestaurantModel>> _restaurantSubscription;

  Map<String, List<String>> idDateMap = {};
  final List<ViewedRestaurant> _viewedRestaurants = [];
  List<ViewedRestaurant> get viewedRestaurants => _viewedRestaurants;

  Map<String, RestaurantModel> _cachedRestaurants = {};

  ViewedRestaurantsViewModel(
    this._userId,
    this._userRepository,
    this._restaurantRepository,
  ) {
    _userSubscription = _userRepository.streamUserMap().listen((allUsers) {
      final user = allUsers[_userId];
      if (user != null) {
        idDateMap = user.viewedRestaurantIDs;
        // 重新觸發餐廳的讀取，因為用戶數據可能已更新
        _loadRestaurants();
      }
    });
    _restaurantSubscription = _restaurantRepository
      .streamRestaurantMap()
      .listen((allRestaurants) {
        _loadRestaurants(allRestaurants);
      });

  }

  void _loadRestaurants([Map<String, RestaurantModel>? allRestaurants]) {
    if (allRestaurants != null) {
      _cachedRestaurants = allRestaurants;
    }
    _viewedRestaurants.clear();
    idDateMap.forEach((restId, dateList) {
      final r = _cachedRestaurants[restId];
      if (r != null) {
        for (final dateString in dateList) {
          final parsedDate = DateTime.tryParse(dateString);
          if (parsedDate != null) {
            _viewedRestaurants.add(ViewedRestaurant()
              ..restaurantId   = restId
              ..viewDate       = parsedDate
              ..restaurantName = r.restaurantName
              ..genreTag       = GenreTag.fromString(r.genreTags.first)
            );
          }
        }
      }
    });
    _viewedRestaurants.sort((a, b) => b.viewDate!.compareTo(a.viewDate!));
    notifyListeners();
  }

  Future<void> deleteViewedRestaurant(String restaurantId) async {
    if (idDateMap.containsKey(restaurantId)) {
      idDateMap.remove(restaurantId);
      await _userRepository.updateUserViewedRestaurants(_userId, idDateMap);
    }
  }

  Future<void> addViewedRestaurant(String restaurantId, DateTime viewDate) async {
    // Wait for user data to be loaded if it hasn't been already
    if (idDateMap.isEmpty && _cachedRestaurants.isEmpty) {
      // Fetch user data first to initialize idDateMap
      final userData = await _userRepository.getUser(_userId);
      if (userData.exists) {
        final user = UserModel.fromMap(userData.data() as Map<String, dynamic>);
        idDateMap = user.viewedRestaurantIDs;
      }
    }
    
    final dateString = viewDate.toIso8601String();
    idDateMap.update(
      restaurantId,
      (list) => [...list, dateString],
      ifAbsent: () => [dateString],
    );
    await _userRepository.updateUserViewedRestaurants(_userId, idDateMap);
  }

  Future<void> deleteSpecificHistoryEntry(ViewedRestaurant entry) async {
    if (entry.restaurantId == null || entry.viewDate == null) return;
    
    final dateString = entry.viewDate!.toIso8601String();
    final restaurantId = entry.restaurantId!;
    
    if (idDateMap.containsKey(restaurantId)) {
      // Remove this specific date from the list
      idDateMap[restaurantId] = idDateMap[restaurantId]!
          .where((date) => date != dateString)
          .toList();
      
      // If no dates left, remove the restaurant entry entirely
      if (idDateMap[restaurantId]!.isEmpty) {
        idDateMap.remove(restaurantId);
      }
      
      // Update Firebase
      await _userRepository.updateUserViewedRestaurants(_userId, idDateMap);
      
      // Update local list
      _viewedRestaurants.removeWhere(
        (item) => item.restaurantId == restaurantId && 
                  item.viewDate?.toIso8601String() == dateString
      );
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    _restaurantSubscription.cancel();
    super.dispose();
  }
}