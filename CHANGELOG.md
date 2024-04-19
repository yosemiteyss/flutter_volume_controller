## 1.3.2
* iOS: fix AudioSessionCategory reset to ambient.

## 1.3.1
* Update minimum dart sdk version to 2.19.0.
* Android: update `flutter_plugin_android_lifecycle` to 2.0.17.
* Android: fix gradle namespace issue with AGP 8.

## 1.3.0
* iOS: fix volume slider not shown when pressing physical buttons after `showSystemUI` is reset.
* Deprecated: `showSystemUI` setter is deprecated and migrated to `updateShowSystemUI`.

## 1.2.7
* Fixed audio session not activated with ambient state on iOS.

## 1.2.6
* Added volume slider example.
* Updated documentation.

## 1.2.5
* Added `getAndroidAudioStream` method.
* Added `getIOSAudioSessionCategory` method.
* Updated flutter_plugin_android_lifecycle plugin to 2.0.9.

## 1.2.4
* Added `setIOSAudioSessionCategory` method.
* Added `category` option to `addListener` method.
* Update example with audio stream and audio session category pickers.
* Fixed deactivating audio session after removing volume listener on iOS.
* Fixed setting audio stream after attaching volume listener on Android.
* Fixed restoring audio stream after activity is resumed on Android.

## 1.2.3
* Fixed allow music playback when start listening or reading the volume. (by DerJojo11)
  https://github.com/yosemiteyss/flutter_volume_controller/pull/32

## 1.2.2
* Fixed incorrect volume level due to floating point conversion.

## 1.2.1+1
* Updated set mute documentation.

## 1.2.1
* Added mute functions.
* Added distinct error codes for exception handling.
* Fixed volume level not emitted immediately after attaching volume listener. Set `emitOnStart` to
  false if you want to keep the previous behavior.
* Fixed getting inaccurate volume level on Windows.
* Updated documentation.

## 1.2.0
* Add linux support

## 1.1.1
* Fix nullable step value not being handled in windows

## 1.1.0
* Add windows support

## 1.0.1+1
* Fix iOS resume audio stream when return to foreground

## 1.0.1
* Add setAndroidAudioStream() to set the default audio stream on Android.

## 1.0.0+1
* Update example

## 1.0.0
* Initial release.
