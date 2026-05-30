import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

/// Contrato para o repositório climático
abstract class WeatherRepository {
  Future<WeatherData> getWeatherForCity(String city);
  Future<WeatherData> getWeatherForLocation(double lat, double lon);
}

/// Implementação integrada com serviços de APIs reais (BrasilAPI e Open-Meteo)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepositoryImpl(this._apiService);

  @override
  Future<WeatherData> getWeatherForCity(String city) async {
    try {
      // 1. Pesquisa a cidade por nome na BrasilAPI (CPTEC) para obter o nome e estado oficiais
      final cities = await _apiService.searchCity(city);
      if (cities.isEmpty) {
        throw Exception('Nenhuma cidade encontrada com o nome "$city".');
      }

      final matchedCity = cities.first;
      final String cityName = matchedCity['nome'] ?? city;
      final String stateName = matchedCity['estado'] ?? 'BR';

      // 2. Busca coordenadas da cidade usando a API do Open-Meteo
      final coords = await _apiService.getCoordinates(cityName, stateName);
      final double lat = coords['latitude']!;
      final double lon = coords['longitude']!;

      // 3. Consulta a API Open-Meteo usando essas coordenadas para obter clima atual e previsões
      final weatherData = await _apiService.getWeatherByCoordinates(lat, lon);

      final current = Map<String, dynamic>.from(weatherData['current'] ?? {});
      final daily = Map<String, dynamic>.from(weatherData['daily'] ?? {});

      final double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
      final int humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final double windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
      final int weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

      final tempMaxList = daily['temperature_2m_max'] as List?;
      final tempMinList = daily['temperature_2m_min'] as List?;
      final timeList = daily['time'] as List?;
      final weatherCodeList = daily['weather_code'] as List?;

      final List<ForecastDay> forecastDays = [];
      if (timeList != null) {
        for (int i = 0; i < timeList.length; i++) {
          forecastDays.add(
            ForecastDay(
              date: DateTime.tryParse(timeList[i].toString()) ?? DateTime.now(),
              min: (tempMinList?[i] as num?)?.toDouble() ?? 0.0,
              max: (tempMaxList?[i] as num?)?.toDouble() ?? 0.0,
              condition: _mapWmoCondition((weatherCodeList?[i] as num?)?.toInt() ?? 0),
              uvIndex: 0,
            ),
          );
        }
      }

      final double tempMax = tempMaxList != null && tempMaxList.isNotEmpty
          ? (tempMaxList.first as num).toDouble()
          : temp;

      final double tempMin = tempMinList != null && tempMinList.isNotEmpty
          ? (tempMinList.first as num).toDouble()
          : temp;

      return WeatherData(
        cityName: cityName,
        stateName: stateName,
        temp: temp,
        tempMin: tempMin,
        tempMax: tempMax,
        condition: _mapWmoCondition(weatherCode),
        description: 'Clima atual e previsão de ${forecastDays.length} dias',
        humidity: humidity,
        windSpeed: windSpeed,
        date: DateTime.now(),
        forecast: forecastDays,
      );
    } catch (e) {
      throw Exception('Falha ao buscar dados climáticos para "$city": $e');
    }
  }

  @override
  Future<WeatherData> getWeatherForLocation(double lat, double lon) async {
    try {
      // Busca informações no Open-Meteo para coordenadas exatas
      final data = await _apiService.getWeatherByCoordinates(lat, lon);
      
      final current = Map<String, dynamic>.from(data['current'] ?? {});
      final daily = Map<String, dynamic>.from(data['daily'] ?? {});
      
      final double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
      final int humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final double windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
      final int weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;

      final tempMaxList = daily['temperature_2m_max'] as List?;
      final tempMinList = daily['temperature_2m_min'] as List?;
      final timeList = daily['time'] as List?;
      final weatherCodeList = daily['weather_code'] as List?;

      final List<ForecastDay> forecastDays = [];
      if (timeList != null) {
        for (int i = 0; i < timeList.length; i++) {
          forecastDays.add(
            ForecastDay(
              date: DateTime.tryParse(timeList[i].toString()) ?? DateTime.now(),
              min: (tempMinList?[i] as num?)?.toDouble() ?? 0.0,
              max: (tempMaxList?[i] as num?)?.toDouble() ?? 0.0,
              condition: _mapWmoCondition((weatherCodeList?[i] as num?)?.toInt() ?? 0),
              uvIndex: 0,
            ),
          );
        }
      }

      final double tempMax = tempMaxList != null && tempMaxList.isNotEmpty
          ? (tempMaxList.first as num).toDouble()
          : temp;

      final double tempMin = tempMinList != null && tempMinList.isNotEmpty
          ? (tempMinList.first as num).toDouble()
          : temp;

      return WeatherData(
        cityName: 'Minha Localização',
        stateName: 'GPS',
        temp: temp,
        tempMin: tempMin,
        tempMax: tempMax,
        condition: _mapWmoCondition(weatherCode),
        description: 'Clima capturado via coordenadas geográficas de satélite',
        humidity: humidity,
        windSpeed: windSpeed,
        date: DateTime.now(),
        forecast: forecastDays,
      );
    } catch (e) {
      throw Exception('Falha ao obter clima por coordenadas: $e');
    }
  }

  /// Mapeador de códigos WMO (Open-Meteo)
  String _mapWmoCondition(int code) {
    if (code == 0) return 'Claro';
    if (code >= 1 && code <= 3) return 'Parcialmente Nublado';
    if (code == 45 || code == 48) return 'Nevoeiro';
    if (code >= 51 && code <= 55) return 'Chuvisco';
    if (code >= 61 && code <= 65) return 'Chuvoso';
    if (code >= 80 && code <= 82) return 'Pancadas de Chuva';
    if (code >= 95) return 'Tempestade';
    return 'Instável';
  }
}
