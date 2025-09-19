import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/sessions_view_model.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionsViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.sessions.length,
              itemBuilder: (c, i) {
                final s = vm.sessions[i];
                return ListTile(
                  title: Text(s.sessionName),
                  subtitle: Text(s.summary ?? 'No summary yet'),
                  trailing: Text(s.status),
                );
              },
            ),
    );
  }
}
