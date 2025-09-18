import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTalking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Player Me'),
      ),
      body: ModelViewer(
        src: 'https://models.readyplayer.me/68c95fc9ef9d88a32d44ca92.glb',
        alt: 'A 3D model of a character',
        ar: true,
        autoRotate: false,
        cameraControls: false,
        cameraTarget: '0m 0.6m 0m',
        cameraOrbit: '0deg 75deg 0.5m',
        disableZoom: true,
        animationName: _isTalking ? 'standing_talking' : 'idle',
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


