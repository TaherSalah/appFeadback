import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

// ─────────────────────────────────────────────────────────────────
// TODO: iOS Push Notifications — يحتاج حساب Apple Developer
// ─────────────────────────────────────────────────────────────────
// عند الاستعداد لـ iOS، اتبع هذه الخطوات:
//
// 1. Firebase Console → Add iOS app → Bundle ID: com.rafiq.muslimdaily
//    حمّل GoogleService-Info.plist وضعه في ios/Runner/
//
// 2. Apple Developer → Keys → New Key → APNs ✅
//    حمّل .p8 → ارفعه في Firebase → Cloud Messaging → Apple app config
//
// 3. استبدل هذا الملف بالنسخة الكاملة الموجودة في:
//    الملف المحفوظ: AppDelegate_ios_ready.swift.bak
//    (سيتم إنشاؤه عند الاستعداد لـ iOS)
//
// 4. في Xcode: Signing & Capabilities → Push Notifications + Background Modes
// ─────────────────────────────────────────────────────────────────
