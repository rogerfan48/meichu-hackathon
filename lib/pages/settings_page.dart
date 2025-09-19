import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final profile = vm.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (profile != null) ...[
              Text('User: ${profile.userName}'),
              Row(
                children: [
                  const Text('Speech Rate'),
                  Expanded(
                    child: Slider(
                      value: profile.defaultSpeechRate,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (v) => vm.updateSpeechRate(v),
                    ),
                  ),
                ],
              ),
            ] else const Text('No profile loaded'),
          ],
        ),
      ),
    );
  }
}
