import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class CharacterModelViewer extends StatelessWidget {
  final String modelUrl;
  final bool isTalking;

  const CharacterModelViewer({
    super.key,
    required this.modelUrl,
    required this.isTalking,
  });

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: modelUrl,
      alt: 'A 3D model of a character',
      poster: 'assets/imgs/brand_logo.png',
      ar: false,
      autoRotate: false,
      cameraControls: false,
      cameraTarget: '0m 0.55m 0m',
      cameraOrbit: '0deg 90deg 0.8m',
      disableZoom: true,
      animationName: isTalking ? 'standing_talking' : 'idle',
      shadowIntensity: 0,
    );
  }
}
