import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

/// Contrato para o repositório climático
abstract class WeatherRepository {
  Future<WeatherData> getWeatherForCity(String city);
  Future<WeatherData> getWeatherForLocation(double lat, double lon);
}

/// Implementação integrada com serviços de APIs reais (BrasilAPI/CPTEC e Open-Meteo)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepositoryImpl(this._apiService);

  @override
  Future<WeatherData> getWeatherForCity(String city) async {
    try {
      // 1. Pesquisa a cidade por nome para obter o ID (código CPTEC)
      final cities = await _apiService.searchCity(city);
      if (cities.isEmpty) {
        throw Exception('Nenhuma cidade encontrada com o nome "$city".');
      }

      // Filtra por preferência de correspondência exata ou simplesmente pega a primeira
      final matchedCity = cities.first;
      final int cityId = matchedCity['id'];

      // 2. Busca a previsão para o ID da cidade encontrada
      final forecastData = await _apiService.getForecastByCityId(cityId);
      final climaList = forecastData['clima'] as List?;
      
      if (climaList == null || climaList.isEmpty) {
        throw Exception('Previsão indisponível no momento para esta localidade.');
      }

      // Pega o primeiro dia da previsão como clima atual aproximado
      final todayForecast = Map<String, dynamic>.from(climaList.first);
      final double tempMin = (todayForecast['min'] as num).toDouble();
      final double tempMax = (todayForecast['max'] as num).toDouble();
      
      // Média simples como temperatura representativa
      final double tempAverage = (tempMin + tempMax) / 2;

      return WeatherData(
        cityName: forecastData['cidade'] ?? matchedCity['nome'] ?? city,
        stateName: forecastData['estado'] ?? matchedCity['estado'] ?? 'BR',
        temp: tempAverage,
        tempMin: tempMin,
        tempMax: tempMax,
        condition: _mapCptecCondition(todayForecast['condicao']),
        description: 'Índice UV máximo: ${todayForecast['indice_uv'] ?? "Não informado"}',
        humidity: 60, // CPTEC previsão diária padrão
        windSpeed: 12.0, // Vento médio representativo
        date: DateTime.tryParse(todayForecast['data'] ?? '') ?? DateTime.now(),
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
      );
    } catch (e) {
      throw Exception('Falha ao obter clima por coordenadas: $e');
    }
  }

  /// Mapeador de códigos climáticos da CPTEC/INPE
  String _mapCptecCondition(String? code) {
    switch (code?.toLowerCase()) {
      case 'ec': return 'Encoberto';
      case 'ci': return 'Chuvas Isoladas';
      case 'cl': return 'Parcialmente Nublado';
      case 'c': return 'Claro';
      case 'ch': return 'Chuvoso';
      case 't': return 'Tempestade';
      case 'pn': return 'Parcialmente Nublado';
      case 'pm': return 'Poucas Nuvens';
      case 'np': return 'Pancadas de Chuva';
      case 'n': return 'Nublado';
      case 'pc': return 'Pancadas de Chuva';
      default: return 'Tempo Instável';
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
