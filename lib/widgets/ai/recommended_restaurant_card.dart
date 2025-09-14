import 'package:flutter/material.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:foodie/widgets/firebase_image.dart';

class RecommendedRestaurantCard extends StatelessWidget {
  final RecommendedRestaurant restaurant;
  final VoidCallback onTap;

  const RecommendedRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FirebaseImage(
                gsUri: restaurant.imageUrl,
                height: 120,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
