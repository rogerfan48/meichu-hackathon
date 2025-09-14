import 'package:flutter/material.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodie/widgets/firebase_image.dart';
import 'package:foodie/models/dish_model.dart';

class RestaurantMenuPage extends StatefulWidget {
  const RestaurantMenuPage({super.key});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _categoryKeys = {};
  final GlobalKey _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    if (!mounted) return;

    final vm = context.read<RestaurantDetailViewModel>();
    final categoryName = vm.categorizedMenu.keys.elementAt(index);

    final keyContext = _categoryKeys[categoryName]?.currentContext;
    final listContext = _listKey.currentContext;

    if (keyContext != null && listContext != null) {
      final RenderBox listBox = listContext.findRenderObject() as RenderBox;
      final RenderBox keyBox = keyContext.findRenderObject() as RenderBox;

      final Offset position = listBox.globalToLocal(keyBox.localToGlobal(Offset.zero));

      _scrollController.animateTo(
        position.dy,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantDetailViewModel>();
    final categories = vm.categorizedMenu;

    if (categories.isEmpty) {
      return const Center(child: Text('No menu items available'));
    }

    final categoryList = categories.keys.toList();

    for (final cat in categoryList) {
      _categoryKeys.putIfAbsent(cat, () => GlobalKey());
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              delegate: _CategoryHeaderDelegate(
                categoryNames: categoryList,
                selectedIndex: -1,
                onCategorySelected: _scrollToCategory,
              ),
              pinned: true,
            ),
          ];
        },
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            key: _listKey,
            children: [
              ...categoryList.map((categoryName) {
                final dishes = categories[categoryName]!;
                return Container(
                  key: _categoryKeys[categoryName],
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                        child: Text(
                          categoryName,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...dishes.asMap().entries.map((entry) {
                        final dishIndex = entry.key;
                        final dish = entry.value;
                        final String? imageUri = vm.getBestImageForDish(dish);

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                context.go(
                                  '/map/restaurant/${vm.restaurantId}/menu/${dish.dishId}',
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: FirebaseImage(gsUri: imageUri, width: 60, height: 60),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dish.dishName,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          if (dish.summary.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                dish.summary,
                                                style: Theme.of(context).textTheme.bodySmall,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '\$${dish.dishPrice}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (dishIndex < dishes.length - 1)
                              const Divider(height: 1, indent: 4, endIndent: 4),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 300)
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categoryNames;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  _CategoryHeaderDelegate({
    required this.categoryNames,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          spacing: 8.0,
          children: List.generate(categoryNames.length, (index) {
            return FilterChip(
              label: Text(categoryNames[index]),
              selected: selectedIndex == index,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(index);
                }
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
