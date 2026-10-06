import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_notification.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._client);

  final DioClient _client;

  Future<NotificationPage> getNotifications({
    required int page,
    required int perPage,
    required bool unreadOnly,
  }) async {
    final response = await _client.get<dynamic>(
      ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (unreadOnly) 'unread': 1,
      },
    );
    final payload = _data(response.data);
    final rows = payload['notifications'];
    final meta = payload['meta'] is Map
        ? Map<String, dynamic>.from(payload['meta'] as Map)
        : <String, dynamic>{};

    return NotificationPage(
      notifications: rows is List
          ? rows
              .whereType<Map>()
              .map((row) => UserNotification.fromJson(Map<String, dynamic>.from(row)))
              .where((item) => item.id.isNotEmpty)
              .toList()
          : const [],
      currentPage: _asInt(meta['current_page'], page),
      lastPage: _asInt(meta['last_page'], page),
      unreadCount: _asInt(meta['unread_count'], 0),
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get<dynamic>(
      ApiConstants.notificationsUnreadCount,
    );
    return _asInt(_data(response.data)['unread_count'], 0);
  }

  Future<UserNotification> getNotification(String id) async {
    final response = await _client.get<dynamic>(
      '${ApiConstants.notifications}/$id',
    );
    final json = _data(response.data)['notification'];
    if (json is! Map) throw StateError('Invalid notification response');
    return UserNotification.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> markAsRead(String id) async {
    final response = await _client.post<dynamic>(
      '${ApiConstants.notifications}/$id/read',
    );
    _data(response.data);
  }

  Future<void> markAllAsRead() async {
    final response = await _client.post<dynamic>(
      ApiConstants.notificationsReadAll,
    );
    _data(response.data);
  }

  Future<void> deleteNotification(String id) async {
    final response = await _client.delete<dynamic>(
      '${ApiConstants.notifications}/$id',
    );
    _data(response.data);
  }

  Map<String, dynamic> _data(dynamic response) {
    if (response is! Map) throw StateError('Invalid notification response');
    final body = Map<String, dynamic>.from(response);
    if (body['success'] == false) {
      throw StateError(body['message']?.toString() ?? 'Notification request failed');
    }
    final payload = body['data'];
    return payload is Map ? Map<String, dynamic>.from(payload) : body;
  }

  int _asInt(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? fallback;
}
