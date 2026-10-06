import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/user_notification.dart';
import '../models/notification_item.dart';

/// Charge et modifie les notifications du compte connecté.
class NotificationsController extends GetxController {
  static const int _perPage = 30;

  final notifications = <NotificationItem>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isMarkingAllRead = false.obs;
  final errorMessage = ''.obs;
  final unreadOnly = false.obs;
  final scrollController = ScrollController();

  late final NotificationRemoteDataSource _dataSource;
  int _currentPage = 0;
  int _lastPage = 1;
  int _unreadCountRevision = 0;
  bool get hasMore => _currentPage < _lastPage;

  List<NotificationGroup> get groups {
    final grouped = <String, List<NotificationItem>>{};
    for (final item in notifications) {
      final label = _groupLabel(item.createdAt);
      grouped.putIfAbsent(label, () => []).add(item);
    }
    return grouped.entries
        .map((entry) => NotificationGroup(title: entry.key, items: entry.value))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _dataSource = NotificationRemoteDataSource(Get.find<DioClient>());
    scrollController.addListener(_onScroll);
    loadNotifications();
  }

  @override
  void onClose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.onClose();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (isLoading.value || isLoadingMore.value) return;
    final countRevision = _unreadCountRevision;
    isLoading.value = true;
    errorMessage.value = '';
    if (refresh) notifications.clear();
    _currentPage = 0;
    _lastPage = 1;

    try {
      final result = await _dataSource.getNotifications(
        page: 1,
        perPage: _perPage,
        unreadOnly: unreadOnly.value,
      );
      notifications.assignAll(result.notifications.map(_toItem));
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      if (_unreadCountRevision == countRevision) {
        unreadCount.value = result.unreadCount;
      }
      // Run after the list request so an older parallel response cannot
      // overwrite a newer unread count in the header.
      await loadUnreadCount();
    } catch (_) {
      errorMessage.value = 'notifications.load_error'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    final countRevision = _unreadCountRevision;
    try {
      final count = await _dataSource.getUnreadCount();
      if (_unreadCountRevision == countRevision) unreadCount.value = count;
    } catch (_) {
      // The list response also includes the unread count.
    }
  }

  void onFilterPressed() {
    unreadOnly.toggle();
    loadNotifications(refresh: true);
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAllRead.value || unreadCount.value == 0) return;
    isMarkingAllRead.value = true;
    try {
      await _dataSource.markAllAsRead();
      for (var index = 0; index < notifications.length; index++) {
        notifications[index] = notifications[index].copyWith(isUnread: false);
      }
      _unreadCountRevision++;
      unreadCount.value = 0;
      if (unreadOnly.value) await loadNotifications(refresh: true);
    } catch (_) {
      _showError('notifications.action_error'.tr);
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  Future<UserNotification?> loadDetails(NotificationItem item) async {
    try {
      var detail = await _dataSource.getNotification(item.id);
      if (detail.isUnread && item.isUnread) {
        final marked = await markAsRead(item.id);
        if (marked) detail = detail.copyWith(isUnread: false);
      }
      return detail;
    } catch (_) {
      _showError('notifications.action_error'.tr);
      return null;
    }
  }

  Future<bool> markAsRead(String id) async {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index < 0 || !notifications[index].isUnread) return true;
    try {
      await _dataSource.markAsRead(id);
      if (unreadOnly.value) {
        notifications.removeAt(index);
      } else {
        notifications[index] = notifications[index].copyWith(isUnread: false);
      }
      _unreadCountRevision++;
      unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 31).toInt();
      return true;
    } catch (_) {
      _showError('notifications.action_error'.tr);
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    final wasUnread = notifications[index].isUnread;
    try {
      await _dataSource.deleteNotification(id);
      notifications.removeAt(index);
      if (wasUnread) {
        _unreadCountRevision++;
        unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 31).toInt();
      }
      return true;
    } catch (_) {
      _showError('notifications.action_error'.tr);
      return false;
    }
  }

  Future<void> _loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    final countRevision = _unreadCountRevision;
    isLoadingMore.value = true;
    try {
      final result = await _dataSource.getNotifications(
        page: _currentPage + 1,
        perPage: _perPage,
        unreadOnly: unreadOnly.value,
      );
      final knownIds = notifications.map((item) => item.id).toSet();
      notifications.addAll(
        result.notifications
            .where((item) => !knownIds.contains(item.id))
            .map(_toItem),
      );
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      if (_unreadCountRevision == countRevision) {
        unreadCount.value = result.unreadCount;
      }
    } catch (_) {
      _showError('notifications.load_more_error'.tr);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoading.value || isLoadingMore.value || !hasMore) return;
    if (scrollController.position.extentAfter < 300) _loadMore();
  }

  NotificationItem _toItem(UserNotification notification) => NotificationItem(
    id: notification.id,
    service: notification.title,
    message: notification.body,
    timeLabel: _timeLabel(notification.createdAt),
    isUnread: notification.isUnread,
    typeLabel: notification.typeLabel,
    createdAt: notification.createdAt,
    data: notification.data,
  );

  String _groupLabel(DateTime? date) {
    if (date == null) return 'notifications.older'.tr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'common.today'.tr;
    if (day == today.subtract(const Duration(days: 1))) return 'common.yesterday'.tr;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day != today) return _groupLabel(date);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    Get.snackbar(
      'notifications.title'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
