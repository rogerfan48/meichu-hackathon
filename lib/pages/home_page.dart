import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTalking = false;
  String? _modelPath;
  final String _modelUrl =
      'https://models.readyplayer.me/68c95fc9ef9d88a32d44ca92.glb';

  @override
  void initState() {
    super.initState();
    _downloadAndSaveModel();
  }

  Future<void> _downloadAndSaveModel() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _modelUrl.split('/').last;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      setState(() {
        _modelPath = filePath;
      });
    } else {
      final response = await http.get(Uri.parse(_modelUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _modelPath = filePath;
        });
      } else {
        // Handle download error
        print('Failed to download model');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Player Me'),
      ),
      body: _modelPath == null
          ? const Center(child: CircularProgressIndicator())
          : ModelViewer(
              src: 'file:$_modelPath',
              alt: 'A 3D model of a character',
              ar: true,
              autoRotate: false,
              cameraControls: false,
              cameraTarget: '0m 0.6m 0m',
              cameraOrbit: '0deg 75deg 0.5m',
              poster: 'Loading...',
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