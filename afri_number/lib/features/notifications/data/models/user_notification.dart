class UserNotification {
  const UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isUnread,
    required this.createdAt,
    this.typeLabel,
    this.typeCode,
    this.data = const {},
  });

  final String id;
  final String title;
  final String body;
  final bool isUnread;
  final DateTime? createdAt;
  final String? typeLabel;
  final String? typeCode;
  final Map<String, dynamic> data;

  UserNotification copyWith({bool? isUnread}) => UserNotification(
    id: id,
    title: title,
    body: body,
    isUnread: isUnread ?? this.isUnread,
    createdAt: createdAt,
    typeLabel: typeLabel,
    typeCode: typeCode,
    data: data,
  );

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    final type = rawType is Map ? Map<String, dynamic>.from(rawType) : null;
    final rawData = json['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : const <String, dynamic>{};
    final rawDate = json['created_at']?.toString();

    return UserNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? type?['label']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isUnread: json['is_read'] != true && json['read_at'] == null,
      createdAt: rawDate == null ? null : DateTime.tryParse(rawDate)?.toLocal(),
      typeLabel: type?['label']?.toString(),
      typeCode: type?['code']?.toString(),
      data: data,
    );
  }
}

class NotificationPage {
  const NotificationPage({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.unreadCount,
  });

  final List<UserNotification> notifications;
  final int currentPage;
  final int lastPage;
  final int unreadCount;
}
