import 'package:get/get.dart';

import '../models/notification_item.dart';

/// État UI de l'écran Notifications.
class NotificationsController extends GetxController {
  static const String maskedNumber = '**** 9548';

  static const _google = NotificationItem(
    service: 'Google',
    message: 'Votre compte est maintenant accessible via ce numéro.',
    timeLabel: '14:30',
    logoAsset: 'assets/images/services/google.png',
    isUnread: true,
  );
  static const _googleCode = NotificationItem(
    service: 'Google',
    message: 'Votre code de vérification est 4829',
    timeLabel: '14:30',
    logoAsset: 'assets/images/services/google.png',
    isUnread: true,
  );
  static const _paypal = NotificationItem(
    service: 'PayPal',
    message: 'Votre code de sécurité est 4829',
    timeLabel: '13:15',
    logoAsset: 'assets/images/services/paypal.png',
    isUnread: true,
  );
  static const _whatsapp = NotificationItem(
    service: 'WhatsApp',
    message: 'Salut, comment vas-tu ?',
    timeLabel: 'Hier',
    logoAsset: 'assets/images/services/whatsapp.png',
  );
  static const _uber = NotificationItem(
    service: 'Uber',
    message: 'Votre code de connexion est 4829',
    timeLabel: '18 Sep',
    logoAsset: 'assets/images/services/uber.png',
  );
  static const _adobe = NotificationItem(
    service: 'Adobe Creator',
    message: 'Votre abonnement mensuel est déjà disponible.',
    timeLabel: '17 Sep',
    logoAsset: 'assets/images/services/adobe.png',
  );

  /// Données fictives — à remplacer par un use case / repository.
  final RxList<NotificationGroup> groups = <NotificationGroup>[
    const NotificationGroup(
      title: "Aujourd'hui",
      items: [_google, _paypal, _whatsapp, _uber, _adobe, _uber],
    ),
    const NotificationGroup(
      title: 'Cette semaine',
      items: [_googleCode, _paypal, _whatsapp, _uber],
    ),
  ].obs;

  /// Valeur de la maquette (12 non lus).
  final RxInt unreadCount = 12.obs;

  void onFilterPressed() {
    // Aucune feuille de filtres n'est maquettée pour l'instant : action neutre.
  }
}
