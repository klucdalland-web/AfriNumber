import '../../domain/models/country_item.dart';
import '../../domain/repositories/country_repository.dart';

class MockCountryRepository implements CountryRepository {
  @override
  Future<List<CountryItem>> fetchCountries() async => const [
    CountryItem(id: 'us', name: 'États-Unis', code: '+1', availableNumbers: 1240, isPopular: true),
    CountryItem(id: 'uk', name: 'Royaume-Uni', code: '+44', availableNumbers: 850, isPopular: true),
    CountryItem(id: 'fr', name: 'France', code: '+33', availableNumbers: 2100, isPopular: true),
    CountryItem(id: 'ca', name: 'Canada', code: '+1', availableNumbers: 1500, isPopular: true),
    CountryItem(id: 'de', name: 'Allemagne', code: '+49', availableNumbers: 920),
    CountryItem(id: 'mg', name: 'Madagascar', code: '+261', availableNumbers: 430),
    CountryItem(id: 'ci', name: "Côte d'Ivoire", code: '+225', availableNumbers: 670),
    CountryItem(id: 'sn', name: 'Sénégal', code: '+221', availableNumbers: 510),
    CountryItem(id: 'cm', name: 'Cameroun', code: '+237', availableNumbers: 390),
  ];
}
