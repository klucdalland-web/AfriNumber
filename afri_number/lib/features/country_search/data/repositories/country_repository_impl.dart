import '../../domain/models/country_item.dart';
import '../../domain/repositories/country_repository.dart';
import '../datasources/country_remote_datasource.dart';

/// Implémentation réelle de [CountryRepository].
/// Délègue à [CountryRemoteDataSource] pour appeler l'API.
class CountryRepositoryImpl implements CountryRepository {
  const CountryRepositoryImpl(this._dataSource);

  final CountryRemoteDataSource _dataSource;

  @override
  Future<List<CountryItem>> fetchCountries() => _dataSource.fetchCountries();
}
