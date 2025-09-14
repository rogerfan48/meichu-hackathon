import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final CameraPosition initialPosition;
  final void Function(LatLng)? onTap;

  const GoogleMapWidget({
    Key? key,
    required this.markers,
    required this.initialPosition,
    this.onTap,
  }) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: widget.initialPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onTap: widget.onTap,
    );
  }
}
