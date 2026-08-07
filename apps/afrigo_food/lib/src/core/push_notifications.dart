import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers this device for real push notifications (FCM) and keeps the
/// registration fresh — called from `doLogin()`/`continueFromSplash()`
/// (a resumed session needs this too, same as every other login-time
/// side-effect in `_routeAfterAuth`).
///
/// Foreground message display is intentionally not handled here: every
/// screen that matters (incoming orders) already gets live updates via
/// Realtime (`watchOrders`) while the app is open. Push exists specifically
/// for when the app is backgrounded/killed and Realtime can't reach it —
/// the OS displays the system notification for that case with no extra
/// code needed on the `notification` payload FCM sends.
abstract final class PushNotifications {
  static bool _listenerAttached = false;

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
      }
    } catch (_) {
      // Non-fatal — every real-time feature already works over Realtime
      // regardless of push; a missing/misconfigured Firebase setup must
      // never block login or any other flow.
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
