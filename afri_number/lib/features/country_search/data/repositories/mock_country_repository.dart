import '../../domain/models/country_item.dart';
import '../../domain/repositories/country_repository.dart';

/// Implémentation de test (mock) de [CountryRepository].
/// Utilisée uniquement en développement si [CountryRepositoryImpl] n'est pas branché.
/// Les données reflètent la même structure que l'API `/pays`.
class MockCountryRepository implements CountryRepository {
  @override
  Future<List<CountryItem>> fetchCountries() async => const [
        CountryItem(id: 1,  name: 'États-Unis',     code: 'US', dialCode: '+1',   isPopular: true),
        CountryItem(id: 2,  name: 'Royaume-Uni',    code: 'GB', dialCode: '+44',  isPopular: true),
        CountryItem(id: 3,  name: 'France',          code: 'FR', dialCode: '+33',  isPopular: true),
        CountryItem(id: 4,  name: 'Canada',          code: 'CA', dialCode: '+1',   isPopular: true),
        CountryItem(id: 5,  name: 'Allemagne',       code: 'DE', dialCode: '+49'),
        CountryItem(id: 28, name: 'Madagascar',      code: 'MG', dialCode: '+261'),
        CountryItem(id: 6,  name: "Côte d'Ivoire",  code: 'CI', dialCode: '+225'),
        CountryItem(id: 7,  name: 'Sénégal',         code: 'SN', dialCode: '+221'),
        CountryItem(id: 11, name: 'Congo',           code: 'CG', dialCode: '+242'),
      ];
}
