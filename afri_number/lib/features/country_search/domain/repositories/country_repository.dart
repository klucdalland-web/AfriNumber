import '../models/country_item.dart';

abstract class CountryRepository {
  Future<List<CountryItem>> fetchCountries();
}
