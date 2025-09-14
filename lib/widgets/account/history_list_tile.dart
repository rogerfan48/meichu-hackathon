import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/services/map_position.dart';
import 'package:foodie/view_models/all_restaurants_vm.dart';
import 'package:provider/provider.dart';

class HistoryListTile extends StatelessWidget {
  final String restaurantName;
  final String restaurantId;
  final String genre;
  final String date;
  final VoidCallback onDelete;

  const HistoryListTile({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
    required this.genre,
    required this.date,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Safely handle the genre tag - try to convert from string or fallback to a default
    GenreTag genreTag;
    try {
      // Try to convert directly if it's an enum key
      genreTag = GenreTag.fromString(genre);
    } catch (e) {
      // If that fails, try searching for a matching title
      genreTag = genreTags.values.firstWhere(
        (tag) => tag.title == genre,
        orElse: () => const GenreTag("Unknown", Color(0xFFCCCCCC)),
      );
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: () {
          if (restaurantId.isEmpty) return;
          final mapPositionService = context.read<MapPositionService>();
          final allRestaurantVM = context.read<AllRestaurantViewModel>();
          final theRestaurant = allRestaurantVM.restaurants.firstWhere(
            (r) => r.restaurantId == restaurantId,
          );
          mapPositionService.updatePosition(
            LatLng(theRestaurant.latitude, theRestaurant.longitude),
          );
          mapPositionService.updateId(restaurantId);
          context.go('/map');
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                restaurantName,
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
                    const TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        subtitle: Text(date, style: theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: genreTag.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genreTag.title,
                style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onDelete),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
      ),
    );
  }
}
