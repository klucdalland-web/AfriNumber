import 'package:flutter/foundation.dart';

/// Helpers plateforme pour UI adaptative (Material / Cupertino).
/// Web → toujours Material (évite Cupertino + BottomAppBar sans Scaffold).
bool get isApplePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
