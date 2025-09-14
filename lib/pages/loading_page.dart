import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/imgs/brand_logo.png', width: 150),
            Text("Foodie", style: Theme.of(context).textTheme.displayLarge),
            Text("Designed by Team 11", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return LinearProgressIndicator(value: value);
                },
                onEnd: () {
                  context.go('/map');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
