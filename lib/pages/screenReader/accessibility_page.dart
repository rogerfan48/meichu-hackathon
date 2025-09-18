import 'package:flutter/material.dart';
import 'package:foodie/pages/screenReader/channel.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  bool _isFeatureOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accessibility Page'),
      ),
      body: Center(
        child: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Feature'),
            subtitle: const Text('Toggle the accessibility feature on or off'),
            value: _isFeatureOn,
            onChanged: (bool value) async {
              setState(() {
                _isFeatureOn = value;
              });
              if (_isFeatureOn) {
                  await startProjection();
              }
            },
            secondary: const Icon(Icons.accessibility_new),
          ),
        ],
      ),
      ),
    );
  }
}