enum ConnectivityServiceType { esim, callForwarding, smsNotification }

/// Service de connectivité de l'utilisateur (eSIM, renvoi d'appel, SMS…).
class ConnectivityService {
  const ConnectivityService({
    required this.id,
    required this.type,
    required this.name,
    required this.isActive,
  });

  final String id;
  final ConnectivityServiceType type;
  final String name;
  final bool isActive;

  ConnectivityService copyWith({bool? isActive}) => ConnectivityService(
        id: id,
        type: type,
        name: name,
        isActive: isActive ?? this.isActive,
      );
}
