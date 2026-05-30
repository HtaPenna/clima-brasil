abstract class PersistenceService {
  Future<void> saveWeatherSearch(WeatherData weather);
  Future<List<WeatherData>> getSavedSearches();
  Future<void> saveTemperatureUnit(TemperatureUnit unit);
  Future<TemperatureUnit> getTemperatureUnit();
  Future<void> toggleFavorite(String cityName);
  Future<List<String>> getFavoriteCities();
}
