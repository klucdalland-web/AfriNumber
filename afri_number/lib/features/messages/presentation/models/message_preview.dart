import 'package:flutter/widgets.dart';

/// Modèle UI (temporaire) d'un aperçu de conversation.
class MessagePreview {
  const MessagePreview({
    required this.sender,
    required this.preview,
    required this.timeLabel,
    this.logoAsset,
    this.fallbackIcon,
    this.fallbackIconColor,
    this.fillAvatar = false,
    this.isUnread = false,
    this.isTranslated = false,
  });

  final String sender;
  final String preview;
  final String timeLabel;

  /// Logo exporté depuis Figma (ex. `assets/images/services/google.png`).
  final String? logoAsset;
  final IconData? fallbackIcon;
  final Color? fallbackIconColor;

  /// Le logo remplit toute la pastille (drapeaux).
  final bool fillAvatar;
  final bool isUnread;

  /// Affiche l'icône globe (message traduit).
  final bool isTranslated;
}
