import 'package:flutter/material.dart';
import 'package:foodie/services/channel.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isFeatureOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
              } else {
                  await stopProjection();
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