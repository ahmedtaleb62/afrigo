import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/context_ext.dart';

/// Real interactive "drag the map to move the pin" location picker — the
/// fixed-center-pin pattern the design's own copy already promised
/// ("اسحب الدبوس على الخريطة لتعديل الموقع بدقة"). Reverse-geocodes the
/// camera's resting position via `geocoding` so the caller gets a real
/// address, not just coordinates. Needs a real Maps API key in
/// `AndroidManifest.xml` to show actual tiles — see
/// `android/app/src/main/res/values/maps_api_key.xml`; without one the
/// widget still works (no crash), tiles are just blank/watermarked.
class LocationPickerMap extends StatefulWidget {
  const LocationPickerMap({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onChanged,
    this.height,
    this.overlay,
  });

  final double initialLat;
  final double initialLng;
  final double? height;

  /// `isUserAction` is true only for a drag/idle the user actually caused
  /// (or the "use my location" button) — false for the automatic resolve on
  /// mount and for the programmatic re-center in `didUpdateWidget`. Callers
  /// use this to decide whether a fresher GPS fix landing later is still
  /// allowed to override the pickup, or whether the user already chose a
  /// deliberate point that must not be silently overwritten.
  final void Function(double lat, double lng, String address, {required bool isUserAction}) onChanged;
  final Widget? overlay;

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  GoogleMapController? _map;
  late LatLng _center;
  bool _moving = false;
  bool _locating = false;

  /// Set the moment the user drags the map or taps "locate me" — once true,
  /// an updated `initialLat`/`initialLng` from the parent (e.g. a delayed
  /// GPS fix landing after this screen already mounted) must never override
  /// a point the user picked on purpose.
  bool _userMoved = false;

  /// `animateCamera` (called both from `didUpdateWidget`'s auto-recenter and
  /// from `_useMyLocation`) itself triggers `onCameraMoveStarted` just like
  /// a real drag would — this suppresses that one callback so the
  /// auto-recenter path doesn't mistake its own camera move for a user drag
  /// and incorrectly set `_userMoved`.
  bool _programmaticMove = false;

  /// Every location failure in this app (permission never granted, denied
  /// forever, GPS off) used to fail completely silently — the pin just sat
  /// on the Nouakchott-center placeholder forever with zero indication why,
  /// which reads as "the app doesn't know my location" even hundreds of km
  /// away from that point. `null` = still checking, `true`/`false` once
  /// known, refreshed after every permission-request attempt.
  bool? _permissionDenied;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.initialLat, widget.initialLng);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAddress(_center, isUserAction: false));
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _permissionDenied = !status.isGranted;
      _permanentlyDenied = status.isPermanentlyDenied;
    });
  }

  @override
  void didUpdateWidget(LocationPickerMap old) {
    super.didUpdateWidget(old);
    if (_userMoved) return;
    if (widget.initialLat == old.initialLat && widget.initialLng == old.initialLng) return;
    // A fresher position landing here almost always means some other code
    // path (e.g. the controller's own fetchCurrentLocation) just got a real
    // GPS fix — which only happens if permission is actually granted. That
    // path never calls this widget's own _checkPermission, so without this
    // the "location unavailable" banner stays stuck forever even once
    // location is clearly working.
    _checkPermission();
    _center = LatLng(widget.initialLat, widget.initialLng);
    _programmaticMove = true;
    _map?.animateCamera(CameraUpdate.newLatLng(_center));
    _resolveAddress(_center, isUserAction: false);
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng pos, {required bool isUserAction}) async {
    final fallback = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.isEmpty ? null : placemarks.first;
      final parts = [p?.street, p?.subLocality, p?.locality].where((s) => s != null && s.trim().isNotEmpty);
      final address = parts.isEmpty ? fallback : parts.join('، ');
      if (mounted) widget.onChanged(pos.latitude, pos.longitude, address, isUserAction: isUserAction);
    } catch (_) {
      if (mounted) widget.onChanged(pos.latitude, pos.longitude, fallback, isUserAction: isUserAction);
    }
  }

  Future<void> _useMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (_permanentlyDenied) {
        // A second in-app request is a silent no-op once denied forever —
        // only the OS Settings screen can flip it back, same reasoning as
        // every other "فتح الإعدادات" fallback in this app family.
        await openAppSettings();
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
      final target = LatLng(pos.latitude, pos.longitude);
      _center = target;
      _userMoved = true;
      await _map?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target, isUserAction: true);
    } catch (_) {
      // No fix available (permission just denied, GPS off mid-flight, etc.) —
      // the user can still drag the pin manually, so fail silently.
    } finally {
      await _checkPermission();
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
            onCameraMoveStarted: () => setState(() {
              _moving = true;
              if (_programmaticMove) {
                _programmaticMove = false;
              } else {
                _userMoved = true;
              }
            }),
            onCameraIdle: () {
              setState(() => _moving = false);
              _resolveAddress(_center, isUserAction: _userMoved);
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
          if (_permissionDenied == true)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _useMyLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _permanentlyDenied
                                ? context.l10n.clientLocationPermanentlyDeniedBanner
                                : context.l10n.clientLocationPermDeniedBanner,
                            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ?widget.overlay,
        ],
      ),
    );
  }
}

/// Real, non-interactive-by-default map for confirm/tracking/preview
/// screens — replaces `MapPlaceholder`'s fake grid background with an
/// actual Google map (`liteModeEnabled`: a static bitmap when not
/// [interactive]).
///
/// Stateful specifically so it can re-center when [lat]/[lng] change after
/// the map already exists — `GoogleMap`'s `initialCameraPosition` is a
/// creation-time-only value; a caller whose `lat`/`lng` start at a
/// placeholder (e.g. `s.currentLat ?? 18.0858` before `fetchCurrentLocation`
/// resolves) would otherwise show a fresh, correctly-positioned marker
/// sitting on a map still centered on the old position forever.
class LiveMapPreview extends StatefulWidget {
  const LiveMapPreview({super.key, required this.lat, required this.lng, this.height, this.markers = const {}, this.zoom = 14, this.overlay, this.interactive = false});

  final double lat;
  final double lng;
  final double? height;
  final Set<Marker> markers;
  final double zoom;
  final Widget? overlay;

  /// When true, renders a real pannable/zoomable map (used on confirm
  /// screens that want the map itself explorable) instead of the cheap
  /// static `liteModeEnabled` bitmap used everywhere else (tracking/preview
  /// cards, where nothing on the map moves so a live map buys nothing).
  final bool interactive;

  @override
  State<LiveMapPreview> createState() => _LiveMapPreviewState();
}

class _LiveMapPreviewState extends State<LiveMapPreview> {
  GoogleMapController? _map;

  /// Same silent-failure gap `LocationPickerMap` had — a client whose
  /// location permission is denied/permanently-denied used to see this
  /// (read-only) map silently centered on whatever placeholder the caller
  /// fell back to, with zero indication why. Ported the same banner here.
  bool? _permissionDenied;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _permissionDenied = !status.isGranted;
      _permanentlyDenied = status.isPermanentlyDenied;
    });
  }

  Future<void> _requestPermission() async {
    if (_permanentlyDenied) {
      await openAppSettings();
    } else {
      await Permission.locationWhenInUse.request();
    }
    await _checkPermission();
  }

  @override
  void didUpdateWidget(LiveMapPreview old) {
    super.didUpdateWidget(old);
    if (widget.lat != old.lat || widget.lng != old.lng) {
      // Same reasoning as LocationPickerMap: a fresher lat/lng landing here
      // almost always means the controller's own fetchCurrentLocation just
      // got a real GPS fix, which only happens if permission is actually
      // granted -- re-check so the stale "location unavailable" banner
      // doesn't keep showing after location clearly started working.
      _checkPermission();
      _map?.animateCamera(CameraUpdate.newLatLng(LatLng(widget.lat, widget.lng)));
    }
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: widget.zoom),
            onMapCreated: (c) => _map = c,
            markers: widget.markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            scrollGesturesEnabled: widget.interactive,
            zoomGesturesEnabled: widget.interactive,
            rotateGesturesEnabled: widget.interactive,
            tiltGesturesEnabled: widget.interactive,
            liteModeEnabled: !widget.interactive,
          ),
          if (_permissionDenied == true)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _requestPermission,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _permanentlyDenied
                                ? context.l10n.clientLocationPermanentlyDeniedBanner
                                : context.l10n.clientLocationPermDeniedBanner,
                            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ?widget.overlay,
        ],
      ),
    );
  }
}
