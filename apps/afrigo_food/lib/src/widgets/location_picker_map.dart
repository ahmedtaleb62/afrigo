import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Real interactive "drag the map to move the pin" location picker — same
/// widget as `afrigo_client`'s `LocationPickerMap`, ported here for the
/// restaurant onboarding screen's address field (previously free-text,
/// per the user's explicit request to make it a real map tap instead).
/// Reverse-geocodes the camera's resting position via `geocoding` so the
/// caller gets a real address, not just coordinates. Needs a real Maps API
/// key in `AndroidManifest.xml` to show actual tiles — see
/// `android/app/src/main/res/values/maps_api_key.xml`; without one the
/// widget still works (no crash), tiles are just blank/watermarked.
class LocationPickerMap extends StatefulWidget {
  const LocationPickerMap({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onChanged,
    this.height,
  });

  final double initialLat;
  final double initialLng;
  final double? height;
  final void Function(double lat, double lng, String address) onChanged;

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  GoogleMapController? _map;
  late LatLng _center;
  bool _moving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.initialLat, widget.initialLng);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAddress(_center));
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng pos) async {
    final fallback = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.isEmpty ? null : placemarks.first;
      final parts = [p?.street, p?.subLocality, p?.locality].where((s) => s != null && s.trim().isNotEmpty);
      final address = parts.isEmpty ? fallback : parts.join('، ');
      if (mounted) widget.onChanged(pos.latitude, pos.longitude, address);
    } catch (_) {
      if (mounted) widget.onChanged(pos.latitude, pos.longitude, fallback);
    }
  }

  Future<void> _useMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      final target = LatLng(pos.latitude, pos.longitude);
      _center = target;
      await _map?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target);
    } catch (_) {
      // No fix available (permission just denied, GPS off mid-flight, etc.) —
      // the user can still drag the pin manually, so fail silently.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            onMapCreated: (c) => _map = c,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onCameraMove: (pos) => _center = pos.target,
            onCameraMoveStarted: () => setState(() => _moving = true),
            onCameraIdle: () {
              setState(() => _moving = false);
              _resolveAddress(_center);
            },
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: _moving ? 16 : 0),
                child: AnimatedScale(
                  scale: _moving ? 1.15 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: const Text('📍', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                onTap: _useMyLocation,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: _locating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)))
                        : const Icon(Icons.my_location, size: 20, color: Color(0xFF16A34A)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
