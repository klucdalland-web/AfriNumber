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
