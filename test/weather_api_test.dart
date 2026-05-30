import 'package:flutter_test/flutter_test.dart';
import 'package:clima_brasil/services/http_service.dart';
import 'package:clima_brasil/services/weather_api_service.dart';
import 'package:clima_brasil/repositories/weather_repository.dart';

void main() {
  group('Testes de Integração de Clima API', () {
    late DioHttpService httpService;
    late WeatherApiService apiService;
    late WeatherRepositoryImpl repository;

    setUp(() {
      httpService = DioHttpService();
      apiService = WeatherApiService(httpService);
      repository = WeatherRepositoryImpl(apiService);
    });

    test('Deve buscar cidades pelo nome na BrasilAPI', () async {
      final cities = await apiService.searchCity('Sao Paulo');
      
      expect(cities, isNotEmpty);
      expect(cities.first['nome'].toString().toLowerCase(), contains('são paulo'));
      expect(cities.first['id'], isNotNull);
    });

    test('Deve retornar previsão por ID de cidade do CPTEC na BrasilAPI', () async {
      final cities = await apiService.searchCity('Sao Paulo');
      final int cityId = cities.first['id'];
      
      final forecast = await apiService.getForecastByCityId(cityId);
      
      expect(forecast, isNotEmpty);
      expect(forecast['cidade'], isNotNull);
      expect(forecast['clima'], isA<List>());
    });

    test('Deve obter coordenadas para uma cidade do Brasil via Open-Meteo Geocoding', () async {
      final coords = await apiService.getCoordinates('São Paulo', 'SP');
      
      expect(coords, isNotEmpty);
      expect(coords['latitude'], closeTo(-23.5489, 1.0));
      expect(coords['longitude'], closeTo(-46.6388, 1.0));
    });

    test('Deve retornar previsão completa com histórico por cidade no Repositório', () async {
      final weather = await repository.getWeatherForCity('Sao Paulo');
      
      expect(weather.cityName, contains('São Paulo'));
      expect(weather.forecast, isNotEmpty);
      // Garante que retorna previsões para múltiplos dias (no mínimo 7 dias do Open-Meteo)
      expect(weather.forecast.length, greaterThanOrEqualTo(7));
      expect(weather.forecast.first.max, isNotNull);
    });

    test('Deve retornar previsão por coordenadas no Open-Meteo com lista de previsões', () async {
      final weather = await repository.getWeatherForLocation(-23.5505, -46.6333);
      
      expect(weather.cityName, equals('Minha Localização'));
      expect(weather.temp, isA<double>());
      expect(weather.forecast, isNotEmpty);
      expect(weather.forecast.length, greaterThanOrEqualTo(7));
    });
  });
}
