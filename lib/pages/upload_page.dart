import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/upload_view_model.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vm.currentSession != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Current status: ${vm.currentSession!.status}'),
              ),
            if (vm.currentSession != null && vm.currentSession!.fileResources.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView(
                  children: vm.currentSession!.fileResources.values
                      .map((f) => ListTile(dense: true, title: Text(f.fileURL.split('/').last)))
                      .toList(),
                ),
              ),
            vm.isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => vm.startUploadSession(
                      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
                      sessionName: 'Session ${DateTime.now().toIso8601String()}',
                    ),
                    child: const Text('Start Session'),
                  ),
            const SizedBox(height: 12),
            if (vm.currentSession != null)
              ElevatedButton.icon(
                onPressed: vm.isProcessing ? null : vm.pickAndUploadFiles,
                icon: const Icon(Icons.file_upload),
                label: const Text('Add Files & Run Pipeline'),
              ),
          ],
        ),
      ),
    );
  }
}
