import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/game_view_model.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Game')),
      body: vm.inProgress
          ? ListView(
              children: vm.deck
                  .map((p) => ListTile(
                        title: Text(p.card.text),
                        subtitle: Text(p.imageSide ?? 'No image'),
                      ))
                  .toList(),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () => vm.startGame(const []),
                child: const Text('Start (placeholder)'),
              ),
            ),
    );
  }
}
