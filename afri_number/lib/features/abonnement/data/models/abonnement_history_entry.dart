class AbonnementHistoryEntry {
  const AbonnementHistoryEntry({
    required this.id,
    required this.planName,
    required this.status,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String planName;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  factory AbonnementHistoryEntry.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'];
    final planMap = plan is Map ? Map<String, dynamic>.from(plan) : null;
    return AbonnementHistoryEntry(
      id: (json['id'] ?? '').toString(),
      planName: (planMap?['label'] ??
              planMap?['name'] ??
              planMap?['code'] ??
              json['plan_name'] ??
              '')
          .toString(),
      status: (json['status'] ?? '').toString(),
      startsAt: DateTime.tryParse((json['starts_at'] ?? '').toString()),
      endsAt: DateTime.tryParse((json['ends_at'] ?? '').toString()),
    );
  }
}
