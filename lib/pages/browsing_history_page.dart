import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:foodie/view_models/viewed_restaurants_vm.dart';
import 'package:foodie/widgets/account/history_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BrowsingHistoryPage extends StatelessWidget {
  const BrowsingHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ViewedRestaurantsViewModel?>();
    final formatter = DateFormat('yyyy-MM-dd HH:mm a');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Browsing History'),
      ),
      body:
          (viewModel == null || viewModel.viewedRestaurants.isEmpty)
              ? const Center(child: Text('You have no browsing history yet.'))
              : ListView.separated(
                itemCount: viewModel.viewedRestaurants.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final historyItem = viewModel.viewedRestaurants[index];
                  return HistoryListTile(
                    restaurantName: historyItem.restaurantName ?? 'N/A',
                    restaurantId: historyItem.restaurantId ?? '',
                    genre: historyItem.genreTag?.title ?? 'N/A',
                    date: formatter.format(DateTime.parse(historyItem.viewDate.toString())),
                    onDelete: () {
                      viewModel.deleteSpecificHistoryEntry(historyItem);
                    },
                  );
                },
              ),
    );
  }
}
