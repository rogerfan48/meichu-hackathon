import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/view_models/my_reviews_vm.dart';
import 'package:foodie/widgets/restaurant/review_list_item.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/services/map_position.dart';
import 'package:foodie/view_models/all_restaurants_vm.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myReviewViewModel = context.watch<MyReviewViewModel?>();
    final currentUserId = context.watch<AccountViewModel>().firebaseUser?.uid;
    final mapPositionService = context.read<MapPositionService>();
    final allRestaurantViewModel = context.watch<AllRestaurantViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('My Reviews'),
      ),
      body:
          (myReviewViewModel == null)
              ? const Center(child: Text('Please log in to see your reviews.'))
              : (myReviewViewModel.myReviews.isEmpty)
              ? const Center(child: Text('You have no reviews yet.'))
              : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: myReviewViewModel.myReviews.length,
                itemBuilder: (context, index) {
                  final reviewDisplay = myReviewViewModel.myReviews[index];
                  final review = reviewDisplay.review;
                  final hasAgreed = review.agreedBy.contains(currentUserId);
                  final hasDisagreed = review.disagreedBy.contains(currentUserId);

                  return ReviewListItem(
                    review: reviewDisplay.review,
                    userDataFuture: myReviewViewModel.getUserData(reviewDisplay.review.reviewerID),
                    dishNameLookup:
                        (dishId) => myReviewViewModel.getDishNameById(review.restaurantID, dishId),
                    onAgree: () {
                      if (currentUserId != null) {
                        myReviewViewModel.toggleReviewVote(
                          reviewId: review.reviewID!,
                          currentUserId: currentUserId,
                          voteType: VoteType.agree,
                          isCurrentlyVoted: hasAgreed,
                        );
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please log in to react to reviews.")),
                        );
                      }
                    },
                    onDisagree: () {
                      if (currentUserId != null) {
                        myReviewViewModel.toggleReviewVote(
                          reviewId: review.reviewID!,
                          currentUserId: currentUserId,
                          voteType: VoteType.disagree,
                          isCurrentlyVoted: hasDisagreed,
                        );
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please log in to react to reviews.")),
                        );
                      }
                    },
                    onTap: () {
                      final theRestaurant =
                          allRestaurantViewModel.restaurants
                              .where((restaurant) => restaurant.restaurantId == review.restaurantID)
                              .firstOrNull!;
                      mapPositionService.updatePosition(
                        LatLng(theRestaurant.latitude, theRestaurant.longitude),
                      );
                      mapPositionService.updateId(theRestaurant.restaurantId);
                      context.go('/map/restaurant/${review.restaurantID}/reviews');
                    },
                    onEdit: null,
                    onDelete: null,
                    onDeleteImage: null,
                  );
                },
              ),
    );
  }
}
