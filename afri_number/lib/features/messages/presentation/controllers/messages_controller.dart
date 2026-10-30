import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/message_preview.dart';

/// État UI de l'écran Messages : liste + recherche locale.
class MessagesController extends GetxController {
  static const String maskedNumber = '**** 9548';

  /// Données fictives — à remplacer par un use case / repository.
  static const List<MessagePreview> _mock = [
    MessagePreview(
      sender: 'Google',
      preview: 'Votre code de vérification est 4829',
      timeLabel: '14:30',
      logoAsset: 'assets/images/services/google.png',
      isUnread: true,
    ),
    MessagePreview(
      sender: 'PayPal',
      preview: 'Votre code de sécurité est 4829',
      timeLabel: '13:15',
      logoAsset: 'assets/images/services/paypal.png',
      isUnread: true,
    ),
    MessagePreview(
      sender: 'WhatsApp',
      preview: 'Salut, comment vas-tu ?',
      timeLabel: 'Hier',
      logoAsset: 'assets/images/services/whatsapp.png',
    ),
    MessagePreview(
      sender: '+33 6 XX XX XX XX',
      preview: "Bonjour, j'attends ta réponse",
      timeLabel: '20 Sep',
      logoAsset: 'assets/images/flags/fr.png',
      fallbackIcon: Icons.add_rounded,
      fallbackIconColor: Color(0xFFE5232C),
      fillAvatar: true,
      isUnread: true,
      isTranslated: true,
    ),
    MessagePreview(
      sender: 'Airtel Money',
      preview: 'Votre solde est de 50 000 MGA',
      timeLabel: '19 Sep',
      logoAsset: 'assets/images/services/airtel_money.png',
    ),
    MessagePreview(
      sender: 'Uber',
      preview: 'Votre code de connexion est 4829',
      timeLabel: '18 Sep',
      logoAsset: 'assets/images/services/uber.png',
    ),
    MessagePreview(
      sender: 'Adobe Creator',
      preview: 'Votre abonnement mensuel est déjà disponible.',
      timeLabel: '17 Sep',
      logoAsset: 'assets/images/services/adobe.png',
    ),
    MessagePreview(
      sender: 'Amazon',
      preview: 'Consultez les dernières promotions !',
      timeLabel: '17 Sep',
      logoAsset: 'assets/images/services/amazon.png',
    ),
    MessagePreview(
      sender: 'Apple Music',
      preview: 'Votre code de connexion est 3037',
      timeLabel: '15 Sep',
      logoAsset: 'assets/images/services/apple_music.png',
    ),
  ];

  final RxList<MessagePreview> messages = <MessagePreview>[..._mock].obs;
  final RxString query = ''.obs;

  int get unreadCount => messages.where((m) => m.isUnread).length;

  /// Liste filtrée par la recherche (expéditeur ou contenu).
  List<MessagePreview> get filteredMessages {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return messages;
    return messages
        .where((m) =>
            m.sender.toLowerCase().contains(q) ||
            m.preview.toLowerCase().contains(q))
        .toList();
  }

  void onQueryChanged(String value) => query.value = value;
}
