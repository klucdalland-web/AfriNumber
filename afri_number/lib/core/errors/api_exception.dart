class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  /// Message le plus pertinent pour l'UI (champ Laravel prioritaire si message générique).
  String get displayMessage {
    final fieldMessage = firstFieldMessage(errors);
    if (fieldMessage == null) return message;
    if (isGenericValidationMessage(message)) return fieldMessage;
    // Les erreurs `code` (OTP incorrect, etc.) sont plus utiles que le message générique.
    if (errors!.containsKey('code')) return fieldMessage;
    return message;
  }

  int? get lockedMinutesLeft => asInt(errors?['locked_minutes_left']);

  int? get retryAfterSeconds => asInt(errors?['retry_after_seconds']);

  int? get resendCount => asInt(errors?['resend_count']);

  DateTime? get lockedUntil {
    final raw = errors?['locked_until'] ?? errors?['next_resend_at'];
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  DateTime? get nextResendAt {
    final raw = errors?['next_resend_at'];
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  bool get isLocked => statusCode == 423;
  bool get isThrottled => statusCode == 429 || statusCode == 423;

  static String? firstFieldMessage(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return null;

    const preferredKeys = [
      'code',
      'email',
      'phone_number',
      'login',
      'password',
      'contrie_id',
    ];

    for (final key in preferredKeys) {
      final msg = messageFromField(errors[key]);
      if (msg != null) return msg;
    }

    for (final value in errors.values) {
      final msg = messageFromField(value);
      if (msg != null) return msg;
    }
    return null;
  }

  static String? messageFromField(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
    }
    return null;
  }

  static bool isGenericValidationMessage(String message) {
    final lower = message.toLowerCase().trim();
    return lower.contains('given data was invalid') ||
        lower.contains('the given data was invalid') ||
        lower == 'validation failed' ||
        lower.contains('unprocessable entity');
  }

  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
