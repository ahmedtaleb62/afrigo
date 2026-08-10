import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Unlike Android (which just shows blank/watermarked tiles without a
    // key), iOS's Google Maps SDK hard-crashes the moment any GoogleMap
    // widget tries to render if this is never called at all — this was
    // missing entirely, crashing every screen with a map (ride origin,
    // food delivery address, etc.) on real iPhones. Same key already used
    // for Android (see android/app/src/main/res/values/maps_api_key.xml) —
    // it's restricted to the Android package + SHA-1 there, so it likely
    // won't authenticate real tiles here either until a separate
    // iOS-restricted key is created, but having *any* key registered is
    // what prevents the crash; tiles degrade to blank in the meantime,
    // same graceful-degradation behavior Android already has.
    GMSServices.provideAPIKey("AIzaSyBswXjlPqP3Zc6i6gSJQURN-gW4d3C6Ibw")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
