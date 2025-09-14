import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';

class RestaurantInfoCard extends StatelessWidget {
  const RestaurantInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final restaurant = vm.restaurant;
    if (restaurant == null) {
      return const SizedBox.shrink(); // 如果餐廳資料為空，則不顯示任何內容
    }

    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              SizedBox(width: 24, height: 24, child: vm.overallVeganTag.image),
              Row(
                children:
                    restaurant.genreTags.map((tagString) {
                      final tag = GenreTag.fromString(tagString);
                      return Row(
                        children: [
                          const VerticalDivider(width: 7, thickness: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag.title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.black,
                            )),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ],
          ),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < vm.averageRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  vm.averagePriceLevel,
                  (index) => SizedBox(
                    width: 14,
                    child: Icon(
                      Icons.attach_money,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          FilledButton.icon(
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Navigate'),
            onPressed: () async {
              final googleMapsUrl = Uri.parse(
                vm.restaurant!.googleMapURL ??
                    'https://www.google.com/maps/search/?api=1&query=${vm.restaurant!.latitude},${vm.restaurant!.longitude}',
              );
              if (await canLaunchUrl(googleMapsUrl)) {
                await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
              } else {
                // 如果無法啟動 Google Maps，則顯示錯誤訊息
              }
            },
          ),
        ],
      ),
    );
  }
}
