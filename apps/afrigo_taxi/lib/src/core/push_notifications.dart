import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers this device for real push notifications (FCM) and keeps the
/// registration fresh — called from `doLogin()` and again from Home's
/// `initState` (a resumed session needs this too — exactly the gap
/// `ensureLiveSubscriptions` closed for the incoming-ride Realtime channel;
/// this is the same fix for push).
///
/// A ride-offer push (`data: {type: 'incoming_ride', ride_id}`) is the
/// *reliable* path to the accept/reject sheet — the Realtime Broadcast
/// channel (`_subscribeIncomingRides` in `TaxiFlowController`) only works
/// while this driver's socket happens to be connected at the exact instant
/// `request-ride` broadcasts, which Android drops the moment the app is
/// backgrounded. [rideOfferRideIds] republishes the ride id from every such
/// push — whether it arrived while the app was open, or was tapped from the
/// system tray after being backgrounded/killed — so
/// `TaxiFlowController.showIncomingRideById` can fetch the ride fresh and
/// show the same sheet regardless of which path got the notification there.
abstract final class PushNotifications {
  static bool _listenerAttached = false;

  static final _rideOfferController = StreamController<String>.broadcast();
  static Stream<String> get rideOfferRideIds => _rideOfferController.stream;

  static Future<void> register() async {
    final sb = Supabase.instance.client;
    final uid = sb.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) await _saveToken(uid, token);

      if (!_listenerAttached) {
        _listenerAttached = true;
        messaging.onTokenRefresh.listen((refreshed) {
          final currentUid = Supabase.instance.client.auth.currentUser?.id;
          if (currentUid != null) _saveToken(currentUid, refreshed);
        });
        FirebaseMessaging.onMessage.listen(_handleMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
        final initial = await messaging.getInitialMessage();
        if (initial != null) _handleMessage(initial);
      }
    } catch (e) {
      // Non-fatal — every real-time feature already works over Realtime
      // regardless of push; a missing/misconfigured Firebase setup must
      // never block login, toggling online, or any other flow.
    }
  }

  static void _handleMessage(RemoteMessage message) {
    final rideId = message.data['ride_id'] as String?;
    if (message.data['type'] == 'incoming_ride' && rideId != null) {
      _rideOfferController.add(rideId);
    }
  }

  static Future<void> _saveToken(String uid, String token) async {
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {'user_id': uid, 'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
        onConflict: 'token',
      );
    } catch (_) {
      // Non-fatal — see class doc comment.
    }
  }
}
