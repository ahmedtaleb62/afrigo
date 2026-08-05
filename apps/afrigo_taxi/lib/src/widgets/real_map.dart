import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Real interactive Google Map — replaces `MapPlaceholder`'s fake grid
/// background on the home/navigate-to-pickup/trip-ongoing screens. The
/// driver never picks a point here (unlike the Client app's
/// `LocationPickerMap`), just watches real markers on a real, pannable/
/// zoomable map — so this is the driver-app equivalent of the Client app's
/// `LiveMapPreview`, but interactive by default since every screen that
/// uses it wants a real explorable map, not a static preview card.
///
/// Needs a real Maps API key in `AndroidManifest.xml` to show actual tiles
/// — see `android/app/src/main/res/values/maps_api_key.xml`; without one
/// the widget still works (no crash), tiles are just blank/watermarked.
///
/// Stateful specifically so it can re-center when [lat]/[lng] change after
/// the map already exists — `GoogleMap`'s `initialCameraPosition` is a
/// creation-time-only value; a caller whose `lat`/`lng` start at a
/// placeholder (e.g. `s.currentLat ?? 18.0858` before `fetchCurrentLocation`
/// resolves) would otherwise show a fresh, correctly-positioned marker
/// sitting on a map still centered on the old position forever.
class LiveMap extends StatefulWidget {
  const LiveMap({super.key, required this.lat, required this.lng, this.zoom = 14, this.markers = const {}, this.overlay});

  final double lat;
  final double lng;
  final double zoom;
  final Set<Marker> markers;
  final Widget? overlay;

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  GoogleMapController? _map;

  @override
  void didUpdateWidget(LiveMap old) {
    super.didUpdateWidget(old);
    if (widget.lat != old.lat || widget.lng != old.lng) {
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
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: widget.zoom),
          onMapCreated: (c) => _map = c,
          markers: widget.markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        ?widget.overlay,
      ],
    );
  }
}
