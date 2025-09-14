import 'package:flutter/material.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/models/restaurant_model.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/review_repo.dart';

class FirestoreDataPage extends StatelessWidget {
  const FirestoreDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();
    final restRepo = RestaurantRepository();
    final reviewRepo = ReviewRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Data Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Users
            const Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<Map<String, UserModel>>(
                stream: userRepo.streamUserMap(),
                builder: (ctx, snap) {
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  if (!snap.hasData)  return const Center(child: CircularProgressIndicator());
                  final users = snap.data!;
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final e = users.entries.elementAt(i);
                      return ListTile(
                        title: Text(e.value.userName),
                        subtitle: Text('ID: ${e.key}'),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            // Restaurants
            const Text('Restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<Map<String, RestaurantModel>>(
                stream: restRepo.streamRestaurantMap(),
                builder: (ctx, snap) {
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  if (!snap.hasData)  return const Center(child: CircularProgressIndicator());
                  final rests = snap.data!;
                  return ListView.separated(
                    itemCount: rests.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final e = rests.entries.elementAt(i);
                      return ListTile(
                        title: Text(e.value.restaurantName),
                        subtitle: Text('ID: ${e.key}'),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            // Reviews
            const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<Map<String, ReviewModel>?>(
                stream: reviewRepo.streamReviewMap(/* provide required argument here, e.g., userId or restaurantId */),
                builder: (ctx, snap) {
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  if (!snap.hasData || snap.data == null)  return const Center(child: CircularProgressIndicator());
                  final revs = snap.data!;
                  return ListView.separated(
                    itemCount: revs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final e = revs.entries.elementAt(i);
                      final r = e.value;
                      return ListTile(
                        title: Text('Rating: ${r.rating}'),
                        subtitle: Text(r.content),
                        trailing: Text('ID: ${e.key}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}