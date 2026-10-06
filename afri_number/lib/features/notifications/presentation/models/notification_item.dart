/// Modèle d'affichage d'une notification issue de l'API.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.service,
    required this.message,
    required this.timeLabel,
    required this.isUnread,
    this.typeLabel,
    this.createdAt,
    this.data = const {},
  });

  final String id;
  final String service;
  final String message;
  final String timeLabel;
  final String? typeLabel;
  final DateTime? createdAt;
  final Map<String, dynamic> data;
  final bool isUnread;

  NotificationItem copyWith({bool? isUnread}) => NotificationItem(
    id: id,
    service: service,
    message: message,
    timeLabel: timeLabel,
    isUnread: isUnread ?? this.isUnread,
    typeLabel: typeLabel,
    createdAt: createdAt,
    data: data,
  );
}

/// Groupe de notifications (« Aujourd'hui », « Cette semaine »…).
class NotificationGroup {
  const NotificationGroup({required this.title, required this.items});

  final String title;
  final List<NotificationItem> items;
}
