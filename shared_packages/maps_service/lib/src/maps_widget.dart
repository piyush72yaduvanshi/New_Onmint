import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapsWidget extends StatefulWidget {
  final Position? initialPosition;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final double zoom;

  const MapsWidget({
    super.key,
    this.initialPosition,
    this.markers,
    this.polylines,
    this.onMapCreated,
    this.onTap,
    this.showMyLocation = true,
    this.showMyLocationButton = true,
    this.zoom = 15.0,
  });

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _updatePolylines();
  }

  @override
  void didUpdateWidget(MapsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markers != oldWidget.markers) {
      _updateMarkers();
    }
    if (widget.polylines != oldWidget.polylines) {
      _updatePolylines();
    }
  }

  void _updateMarkers() {
    if (widget.markers != null) {
      setState(() {
        _markers = widget.markers!.toSet();
      });
    }
  }

  void _updatePolylines() {
    if (widget.polylines != null) {
      setState(() {
        _polylines = widget.polylines!.toSet();
      });
    }
  }

  LatLng get _initialPosition {
    if (widget.initialPosition != null) {
      return LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    }
    // Default to India center
    return const LatLng(20.5937, 78.9629);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: widget.zoom,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: widget.showMyLocation,
      myLocationButtonEnabled: widget.showMyLocationButton,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      compassEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        widget.onMapCreated?.call(controller);
      },
      onTap: widget.onTap,
    );
  }

  // Helper method to animate camera to position
  Future<void> animateToPosition(LatLng position, {double? zoom}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: zoom ?? widget.zoom,
        ),
      ),
    );
  }

  // Helper method to fit bounds
  Future<void> fitBounds(LatLngBounds bounds) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// Helper class to create custom markers
class MarkerHelper {
  static Marker createMarker({
    required String id,
    required LatLng position,
    required String title,
    String? snippet,
    BitmapDescriptor? icon,
    Function()? onTap,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: onTap,
    );
  }

  static Marker createAmbulanceMarker({
    required String id,
    required LatLng position,
    required String ambulanceNumber,
    Function()? onTap,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: 'Ambulance',
        snippet: ambulanceNumber,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      onTap: onTap,
    );
  }

  static Marker createUserMarker({
    required String id,
    required LatLng position,
    required String name,
    Function()? onTap,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: name,
        snippet: 'Your location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      onTap: onTap,
    );
  }
}

// Helper class to create polylines
class PolylineHelper {
  static Polyline createRoute({
    required String id,
    required List<LatLng> points,
    Color color = Colors.blue,
    int width = 5,
  }) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      geodesic: true,
    );
  }
}
