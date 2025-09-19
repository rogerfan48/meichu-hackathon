import 'package:flutter/material.dart';
import 'package:foodie/widgets/flashcard/model_viewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTalking = false;
  final String _modelUrl =
      'assets/3d_model/68c95fc9ef9d88a32d44ca92.glb';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Player Me'),
      ),
      body: CharacterModelViewer(
        modelUrl: _modelUrl,
        isTalking: _isTalking,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isTalking = !_isTalking;
          });
        },
        child: Icon(_isTalking ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}