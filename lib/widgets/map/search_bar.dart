import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onSubmitted;

  const SearchBarWidget({super.key, required this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              prefixIcon: Icon(Icons.search),
              hintText: "Search Restaurant",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}
