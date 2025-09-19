import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTalking = false;
  final String _modelUrl =
      'https://models.readyplayer.me/68c95fc9ef9d88a32d44ca92.glb?lod=1';

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
      body: ModelViewer(
        src: _modelUrl,
        alt: 'A 3D model of a character',
        poster: 'assets/imgs/brand_logo.png',
        ar: false,
        autoRotate: false,
        cameraControls: false,
        cameraTarget: '0m 0.55m 0m',
        cameraOrbit: '0deg 90deg 0.8m',
        disableZoom: true,
        animationName: _isTalking ? 'standing_talking' : 'idle',
        shadowIntensity: 0,
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