import 'package:flutter/material.dart';
import 'package:foodie/view_models/viewed_restaurants_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/restaurant/restaurant_info_card.dart';

class BottomSheet extends StatelessWidget {
  const BottomSheet({super.key});

  Future<void> _navigateToRestaurantPage(BuildContext context, RestaurantDetailViewModel vm) async {
    if (context.read<AccountViewModel>().firebaseUser != null) {
      await context.read<ViewedRestaurantsViewModel>().addViewedRestaurant(
        vm.restaurantId,
        DateTime.now(),
      );
    }
    context.go('/map/restaurant/${vm.restaurantId}/info');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // details.primaryVelocity < 0 表示向上滑動
        // 速度閾值 -500 可以防止輕微的誤觸
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          _navigateToRestaurantPage(context, vm);
        }
      },
      onTap: () {
        _navigateToRestaurantPage(context, vm);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.15))],
        ),
        child:
            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestaurantDetailViewModel vm) {
    final restaurant = vm.restaurant;
    if (restaurant == null) {
      return const Center(child: Text('Could not load restaurant details.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  restaurant.restaurantName,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          RestaurantInfoCard(),
        ],
      ),
    );
  }
}
