import 'package:flutter/material.dart';
import 'package:foodie/services/channel.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  bool _isAccessibilityOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibilityStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibilityStatus();
    }
  }

  Future<void> _checkAccessibilityStatus() async {
    final bool isEnabled = await isScreenReaderEnabled();
    if (mounted) {
      setState(() {
        _isAccessibilityOn = isEnabled;
      });
    }
  }

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
            value: _isAccessibilityOn,
            onChanged: (bool value) async {
              setState(() {
                _isAccessibilityOn = value;
              });
              if (_isAccessibilityOn) {
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