import 'package:flutter/material.dart';
import 'package:foodie/pages/screenReader/channel.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> with WidgetsBindingObserver {
  bool _isAccessibilityOn = false;
  bool _isTalkBackOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibilityStatus();
    _checkTalkBackStatus();
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
      _checkTalkBackStatus();
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

  Future<void> _checkTalkBackStatus() async {
    final bool isEnabled = await isTalkBackEnabled();
    if (mounted && isEnabled != _isTalkBackOn) {
      setState(() {
        _isTalkBackOn = isEnabled;
      });
    }
  }

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
          SwitchListTile(
            title: const Text('Enable Feature'),
            subtitle: const Text('Toggle the TalkBack feature on or off'),
            value: _isTalkBackOn,
            onChanged: (bool value) async {
              setState(() {
                _isTalkBackOn = value;
              });
              if (_isTalkBackOn) {
                  await startProjection();
              } else {
                  await stopProjection();
              }
            },
            secondary: const Icon(Icons.dialpad),
          ),
        ],
      ),
      ),
    );
  }
}