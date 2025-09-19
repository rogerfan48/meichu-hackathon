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
      autoPlay: true,
      autoRotate: false,
      cameraControls: false,
      cameraTarget: '0m 0.55m -0.5m',
      cameraOrbit: '0deg 90deg 0.3m',
      disableZoom: true,
      animationName: isTalking ? 'F_Talking_Variations_001' : 'idle',
      shadowIntensity: 0,
    );
  }
}
