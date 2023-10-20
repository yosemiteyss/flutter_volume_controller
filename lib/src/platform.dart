import 'dart:io';

bool get isDesktopPlatform =>
    Platform.isMacOS || Platform.isLinux || Platform.isWindows;
