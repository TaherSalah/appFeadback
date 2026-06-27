// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.4.0"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-9.0.1"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.5"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.5.1"),
        .package(name: "app_links", path: "../.packages/app_links-6.4.1"),
        .package(name: "speech_to_text", path: "../.packages/speech_to_text-7.3.0"),
        .package(name: "screen_brightness_macos", path: "../.packages/screen_brightness_macos-2.1.2"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.10.5"),
        .package(name: "audio_session", path: "../.packages/audio_session-0.1.25"),
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus-7.1.1"),
        .package(name: "audio_service", path: "../.packages/audio_service-0.18.18"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.2"),
        .package(name: "in_app_review", path: "../.packages/in_app_review-2.0.11"),
        .package(name: "file_selector_macos", path: "../.packages/file_selector_macos-0.9.5"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.3.13"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.25.0"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.8.9"),
        .package(name: "network_info_plus", path: "../.packages/network_info_plus-7.0.0"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-15.2.10"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-3.15.2"),
        .package(name: "sqlite3_flutter_libs", path: "../.packages/sqlite3_flutter_libs-0.5.42"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "app-links", package: "app_links"),
                .product(name: "speech-to-text", package: "speech_to_text"),
                .product(name: "screen-brightness-macos", package: "screen_brightness_macos"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "audio-service", package: "audio_service"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "in-app-review", package: "in_app_review"),
                .product(name: "file-selector-macos", package: "file_selector_macos"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "network-info-plus", package: "network_info_plus"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "sqlite3-flutter-libs", package: "sqlite3_flutter_libs"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
