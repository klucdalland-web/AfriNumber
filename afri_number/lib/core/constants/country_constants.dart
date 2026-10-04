class CountryData {
  final int id;
  final String name;
  final String code;
  final String dialCode;

  const CountryData({
    required this.id,
    required this.name,
    required this.code,
    required this.dialCode,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    String dial =
        (json['indicatif'] ?? json['dial_code'] ?? json['phone_code'] ?? '')
            .toString()
            .trim();
    if (dial.isNotEmpty && !dial.startsWith('+')) dial = '+$dial';

    return CountryData(
      id: int.parse(json['id'].toString()),
      name: (json['label'] ?? json['nom'] ?? json['name'] ?? '').toString(),
      code: (json['code'] ?? json['iso'] ?? '').toString().toUpperCase(),
      dialCode: dial,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code;

  @override
  int get hashCode => id.hashCode ^ code.hashCode;
}
<<<<<<< HEAD
=======

const List<CountryData> kCountries = [
  CountryData(id: 1, name: 'Madagascar', code: 'MG', dialCode: '+261'),
  CountryData(id: 2, name: 'France', code: 'FR', dialCode: '+33'),
  CountryData(id: 3, name: 'Côte d\'Ivoire', code: 'CI', dialCode: '+225'),
  CountryData(id: 4, name: 'Sénégal', code: 'SN', dialCode: '+221'),
  CountryData(id: 5, name: 'Cameroun', code: 'CM', dialCode: '+237'),
  CountryData(id: 6, name: 'RD Congo', code: 'CD', dialCode: '+243'),
  CountryData(id: 7, name: 'États-Unis', code: 'US', dialCode: '+1'),
  CountryData(id: 8, name: 'Royaume-Uni', code: 'UK', dialCode: '+44'),
  CountryData(id: 9, name: 'Canada', code: 'CA', dialCode: '+1'),
  CountryData(id: 10, name: 'Allemagne', code: 'DE', dialCode: '+49'),
];

const kDefaultCountry = CountryData(id: 1, name: 'Madagascar', code: 'MG', dialCode: '+261');
>>>>>>> 627667f33349cb9693445d0fb740d8c91f7db0a1
