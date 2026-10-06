import 'package:phone_form_field/phone_form_field.dart';

import '../constants/country_constants.dart';

/// Correspondance entre les codes ISO de l'API `/pays` et [IsoCode]
/// (package `phone_form_field` / `phone_numbers_parser`).
class CountryIsoMapper {
  CountryIsoMapper._();

  /// Alias API → ISO alpha-2 du package (ex. UK → GB).
  static const Map<String, String> _aliases = {
    'UK': 'GB',
  };

  /// Convertit un code pays API en [IsoCode], ou `null` s'il est inconnu.
  static IsoCode? tryParse(String? code) {
    if (code == null) return null;
    var normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    normalized = _aliases[normalized] ?? normalized;
    try {
      return IsoCode.values.byName(normalized);
    } on ArgumentError {
      return null;
    }
  }

  /// Liste des [IsoCode] reconnus parmi les pays API (les inconnus sont ignorés).
  static List<IsoCode> allowedFrom(Iterable<CountryData> countries) {
    final seen = <IsoCode>{};
    final result = <IsoCode>[];
    for (final country in countries) {
      final iso = tryParse(country.code);
      if (iso != null && seen.add(iso)) {
        result.add(iso);
      }
    }
    return result;
  }

  /// Retrouve le pays API correspondant à un [IsoCode] sélectionné.
  static CountryData? findCountry(
    Iterable<CountryData> countries,
    IsoCode iso,
  ) {
    final isoName = iso.name;
    for (final country in countries) {
      final code = country.code.trim().toUpperCase();
      if (code == isoName) return country;
      if (_aliases[code] == isoName) return country;
    }
    return null;
  }
}
