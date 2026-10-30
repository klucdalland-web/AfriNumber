import 'package:flutter/material.dart';

/// Opérateur Mobile Money.
class MobileMoneyOperator {
  const MobileMoneyOperator({
    required this.id,
    required this.label,
    required this.color,
    required this.prefixes,
  });

  /// Identifiant envoyé à l'API  
  final String id;
  final String label;
  final Color color;

  /// Préfixes locaux valides 
  final List<String> prefixes;
}

/// Configuration Mobile Money d'un pays.
class MobileMoneyCountry {
  const MobileMoneyCountry({
    required this.code,
    required this.dialCode,
    required this.localNumberLength,
    required this.phoneHint,
    required this.operators,
  });

  /// ISO-3166 alpha-2 (ex: 'MG', 'SN', 'CI').
  final String code;

  /// Indicatif international (ex: '+261').
  final String dialCode;

  /// Longueur du numéro local (10 pour MG, 9 pour SN, …).
  final int localNumberLength;

  /// Hint affiché dans le champ.
  final String phoneHint;

  final List<MobileMoneyOperator> operators;

  bool get isSupported => operators.isNotEmpty;

  bool isValidLocalNumber(String local) {
    if (local.length != localNumberLength) return false;
    if (!local.startsWith('0')) return false;
    return RegExp(r'^\d+$').hasMatch(local);
  }
}

/// Registre statique pays → opérateurs.
///
/// Ajouter un pays = ajouter une entrée ici. Aucun autre fichier à toucher.
class MobileMoneyRegistry {
  const MobileMoneyRegistry._();

  static const _countries = <String, MobileMoneyCountry>{
    // ─── Madagascar ───
    'MG': MobileMoneyCountry(
      code: 'MG',
      dialCode: '+261',
      localNumberLength: 10,
      phoneHint: '03X XX XXX XX',
      operators: [
        MobileMoneyOperator(
          id: 'mvola',
          label: 'MVola',
          color: Color(0xFFFFC400),
          prefixes: ['034', '038'],
        ),
        MobileMoneyOperator(
          id: 'orange_money',
          label: 'Orange Money',
          color: Color(0xFFFF7900),
          prefixes: ['032', '037'],
        ),
        MobileMoneyOperator(
          id: 'airtel_money',
          label: 'Airtel Money',
          color: Color(0xFFE4002B),
          prefixes: ['033'],
        ),
      ],
    ),

    // ─── Sénégal ───
    'SN': MobileMoneyCountry(
      code: 'SN',
      dialCode: '+221',
      localNumberLength: 9,
      phoneHint: '7X XXX XX XX',
      operators: [
        MobileMoneyOperator(
          id: 'orange_money',
          label: 'Orange Money',
          color: Color(0xFFFF7900),
          prefixes: ['77', '78'],
        ),
        MobileMoneyOperator(
          id: 'wave',
          label: 'Wave',
          color: Color(0xFF1DC8FF),
          prefixes: ['70', '75', '76', '77', '78'],
        ),
        MobileMoneyOperator(
          id: 'free_money',
          label: 'Free Money',
          color: Color(0xFFE4002B),
          prefixes: ['76'],
        ),
      ],
    ),

    // ─── Côte d'Ivoire ───
    'CI': MobileMoneyCountry(
      code: 'CI',
      dialCode: '+225',
      localNumberLength: 10,
      phoneHint: '0X XX XXX XXX',
      operators: [
        MobileMoneyOperator(
          id: 'orange_money',
          label: 'Orange Money',
          color: Color(0xFFFF7900),
          prefixes: ['07'],
        ),
        MobileMoneyOperator(
          id: 'mtn_momo',
          label: 'MTN MoMo',
          color: Color(0xFFFFCC00),
          prefixes: ['05'],
        ),
        MobileMoneyOperator(
          id: 'moov_money',
          label: 'Moov Money',
          color: Color(0xFF0066B3),
          prefixes: ['01'],
        ),
        MobileMoneyOperator(
          id: 'wave',
          label: 'Wave',
          color: Color(0xFF1DC8FF),
          prefixes: ['07', '05'],
        ),
      ],
    ),

    // ─── Cameroun ───
    'CM': MobileMoneyCountry(
      code: 'CM',
      dialCode: '+237',
      localNumberLength: 9,
      phoneHint: '6XX XX XX XX',
      operators: [
        MobileMoneyOperator(
          id: 'mtn_momo',
          label: 'MTN MoMo',
          color: Color(0xFFFFCC00),
          prefixes: ['67', '68'],
        ),
        MobileMoneyOperator(
          id: 'orange_money',
          label: 'Orange Money',
          color: Color(0xFFFF7900),
          prefixes: ['69'],
        ),
      ],
    ),

    // ─── RD Congo ───
    'CD': MobileMoneyCountry(
      code: 'CD',
      dialCode: '+243',
      localNumberLength: 9,
      phoneHint: '8XX XXX XXX',
      operators: [
        MobileMoneyOperator(
          id: 'mpesa',
          label: 'M-Pesa',
          color: Color(0xFFE60000),
          prefixes: ['81', '82', '83'],
        ),
        MobileMoneyOperator(
          id: 'orange_money',
          label: 'Orange Money',
          color: Color(0xFFFF7900),
          prefixes: ['84', '89'],
        ),
        MobileMoneyOperator(
          id: 'airtel_money',
          label: 'Airtel Money',
          color: Color(0xFFE4002B),
          prefixes: ['97', '98', '99'],
        ),
      ],
    ),

    // ─── Bénin ───
    'BJ': MobileMoneyCountry(
      code: 'BJ',
      dialCode: '+229',
      localNumberLength: 10,
      phoneHint: '01 XX XX XX XX',
      operators: [
        MobileMoneyOperator(
          id: 'mtn_momo',
          label: 'MTN MoMo',
          color: Color(0xFFFFCC00),
          prefixes: ['0166', '0167', '0168'],
        ),
        MobileMoneyOperator(
          id: 'moov_money',
          label: 'Moov Money',
          color: Color(0xFF0066B3),
          prefixes: ['0160', '0161', '0162'],
        ),
      ],
    ),

    // ─── Togo ───
    'TG': MobileMoneyCountry(
      code: 'TG',
      dialCode: '+228',
      localNumberLength: 8,
      phoneHint: '9X XX XX XX',
      operators: [
        MobileMoneyOperator(
          id: 'flooz',
          label: 'Flooz (Togocom)',
          color: Color(0xFF00A0E3),
          prefixes: ['90', '91', '92', '93'],
        ),
        MobileMoneyOperator(
          id: 'moov_money',
          label: 'Moov Money',
          color: Color(0xFF0066B3),
          prefixes: ['96', '97', '98', '99'],
        ),
      ],
    ),
  };

  /// Retourne la config du pays, ou `null` si non supporté.
  static MobileMoneyCountry? forCountry(String? code) {
    if (code == null || code.trim().isEmpty) return null;
    return _countries[code.trim().toUpperCase()];
  }

  static List<String> get supportedCountries => _countries.keys.toList();
}