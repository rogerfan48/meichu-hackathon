import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/write_review_vm.dart';
import 'package:foodie/widgets/restaurant/rating_summary_card.dart';
import 'package:foodie/widgets/restaurant/review_list_item.dart';
import 'package:foodie/pages/restaurant_write_review_page.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/restaurant_repo.dart';

class RestaurantReviewsPage extends StatelessWidget {
  const RestaurantReviewsPage({super.key});

  void _showWriteReviewPage(BuildContext context) {
    final detailVM = context.read<RestaurantDetailViewModel>();
    final currentUserId = context.read<AccountViewModel>().firebaseUser?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in to write a review.")));
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return ChangeNotifierProvider(
          create:
              (context) => WriteReviewViewModel(
                restaurantId: detailVM.restaurantId,
                currentUserId: currentUserId,
                categorizedMenu: detailVM.categorizedMenu,
                reviewRepository: context.read<ReviewRepository>(),
                storageService: context.read<StorageService>(),
                restaurantRepository: context.read<RestaurantRepository>(),
              ),
          child: const RestaurantWriteReviewPage(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeInOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final currentUserId = context.watch<AccountViewModel>().firebaseUser?.uid;
    final reviews = vm.reviews;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Rate the restaurant'),
                onPressed: () => _showWriteReviewPage(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          // 2. 評分總覽
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RatingSummaryCard(
                averageRating: vm.averageRating.toDouble(),
                totalReviews: reviews.length,
                distribution: vm.ratingDistribution,
              ),
            ),
          ),
          // 3. 排序按鈕
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
                        selected: vm.currentSortType == type, // 假設 vm 有 currentSortType
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
          // 4. 評論列表
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final review = reviews[index];
              final hasAgreed = currentUserId != null && review.agreedBy.contains(currentUserId);
              final hasDisagreed =
                  currentUserId != null && review.disagreedBy.contains(currentUserId);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ReviewListItem(
                  review: reviews[index],
                  userDataFuture: vm.getUserData(reviews[index].reviewerID),
                  dishNameLookup: vm.getDishNameById,
                  onAgree: () {
                    if (currentUserId != null) {
                      vm.toggleReviewVote(
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
                      vm.toggleReviewVote(
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
                  onEdit: (newContent) {
                    vm.updateReviewContent(reviewId: review.reviewID!, newContent: newContent);
                  },
                  onDelete: () {
                    vm.deleteReview(review);
                  },
                  onDeleteImage: (imageUrl) {
                    vm.deleteReviewImage(reviewId: review.reviewID!, imageUrl: imageUrl);
                  },
                ),
              );
            }, childCount: reviews.length),
          ),
        ],
      ),
    );
  }
}
