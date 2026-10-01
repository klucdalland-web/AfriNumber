/// Modèle UI (temporaire) d'une notification.
class NotificationItem {
  const NotificationItem({
    required this.service,
    required this.message,
    required this.timeLabel,
    this.logoAsset,
    this.isUnread = false,
  });

  final String service;
  final String message;
  final String timeLabel;
  final String? logoAsset;
  final bool isUnread;
}

/// Groupe de notifications (« Aujourd'hui », « Cette semaine »…).
class NotificationGroup {
  const NotificationGroup({required this.title, required this.items});

  final String title;
  final List<NotificationItem> items;
}
