import 'package:flutter/material.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/firebase_image.dart';
import 'package:foodie/widgets/restaurant/review_list_item.dart';
import 'package:provider/provider.dart';

class DishDetailPage extends StatelessWidget {
  final String dishId;
  const DishDetailPage({super.key, required this.dishId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final dish = vm.getDishById(dishId);
    final reviews = vm.getReviewsForDish(dishId);

    if (dish == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Dish not found!')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceElevated: true,
            elevation: 100,
            shadowColor: Theme.of(context).colorScheme.shadow,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Column(
              children: [
                Text(
                  dish.dishName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${dish.dishPrice.toString()}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            pinned: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Dish Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                dish.summary.isNotEmpty
                    ? dish.summary
                    : 'No summary available for this dish yet. Try writing a specific review to make AI generate one!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Reviews for this dish',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8.0,
                children:
                    ReviewSortType.values.map((type) {
                      return FilterChip(
                        label: Text(type.name),
                        selected: vm.currentSortType == type,
                        onSelected: (selected) {
                          if (selected) {
                            vm.sortReviews(type);
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
          ),

          reviews.isEmpty
              ? const SliverToBoxAdapter(
                child: Center(heightFactor: 5, child: Text('No reviews for this dish yet.')),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final review = reviews[index];
                  return ReviewListItem(
                    review: review,
                    userDataFuture: vm.getUserData(review.reviewerID),
                    onAgree: () => _onVote(context, vm, review, VoteType.agree),
                    onDisagree: () => _onVote(context, vm, review, VoteType.disagree),
                    dishNameLookup: null,
                  );
                }, childCount: reviews.length),
              ),
        ],
      ),
    );
  }

  void _onVote(
    BuildContext context,
    RestaurantDetailViewModel vm,
    ReviewModel review,
    VoteType type,
  ) {
    final currentUserId = context.read<AccountViewModel>().firebaseUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in to react to reviews.")));
      return;
    }
    final bool isCurrentlyVoted =
        (type == VoteType.agree)
            ? review.agreedBy.contains(currentUserId)
            : review.disagreedBy.contains(currentUserId);

    vm.toggleReviewVote(
      reviewId: review.reviewID!,
      currentUserId: currentUserId,
      voteType: type,
      isCurrentlyVoted: isCurrentlyVoted,
    );
  }
}
