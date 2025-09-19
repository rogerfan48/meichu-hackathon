import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/cards_view_model.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CardsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: ListView.builder(
        itemCount: vm.cards.length,
        itemBuilder: (c, i) {
          final card = vm.cards[i];
          return ListTile(
            title: Text(card.text),
            subtitle: Text(card.tags.join(', ')),
          );
        },
      ),
    );
  }
}
