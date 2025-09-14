import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/firebase_image.dart';
import 'package:foodie/widgets/restaurant/restaurant_info_card.dart';
import 'package:provider/provider.dart';
import 'package:foodie/widgets/restaurant/image_preview_screen.dart';

class RestaurantInfoPage extends StatelessWidget {
  const RestaurantInfoPage({super.key});

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          // 使用 Expanded 讓文字可以自動換行
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final restaurant = vm.restaurant;
    final imageURLs = vm.displayImageUrls;

    if (restaurant == null) {
      return const Center(child: Text('Restaurant data not found.'));
    }

    const dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final sortedBusinessHours =
        restaurant.businessHour.entries.toList()
          ..sort((a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantInfoCard(),
          const SizedBox(height: 16),
          SizedBox(
            height: imageURLs.isNotEmpty ? 120 : 0,
            child:
                imageURLs.isNotEmpty
                    ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: imageURLs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final gsUri = imageURLs[index];
                        return GestureDetector(
                          onTap: () => showImagePreview(context, gsUri),
                          child: Hero(
                            tag: gsUri,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: FirebaseImage(gsUri: gsUri, width: 120, height: 80),
                            ),
                          ),
                        );
                      },
                    )
                    : const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(restaurant.summary, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),
          Text('Information', style: Theme.of(context).textTheme.titleLarge),
          Theme(
            // 覆寫預設的 Divider 樣式，讓它消失
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              visualDensity: VisualDensity.compact,
              tilePadding: EdgeInsets.zero,
              title: _buildInfoRow(
                context,
                icon: Icons.access_time_outlined,
                text: 'Business Hours',
              ),
              children: [
                // 展開後的內容
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children:
                        sortedBusinessHours.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                // 將星期幾推到左邊
                                Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
                                const Spacer(), // Spacer 會佔據所有可用空間
                                // 將時間推到右邊
                                Text(
                                  entry.value,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildInfoRow(context, icon: Icons.phone_outlined, text: restaurant.phoneNumber),
          const Divider(height: 1),
          _buildInfoRow(context, icon: Icons.location_on_outlined, text: restaurant.address),
        ],
      ),
    );
  }
}
