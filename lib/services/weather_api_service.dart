import 'http_service.dart';

/// Serviço que realiza as chamadas diretas às APIs de clima (BrasilAPI/CPTEC e Open-Meteo)
class WeatherApiService {
  final HttpService _httpService;

  WeatherApiService(this._httpService);

  /// Busca cidades por nome na BrasilAPI (CPTEC)
  /// Retorna uma lista de cidades correspondentes com seus respectivos códigos (IDs)
  Future<List<Map<String, dynamic>>> searchCity(String cityName) async {
    final encodedName = Uri.encodeComponent(cityName);
    final response = await _httpService.get(
      'https://brasilapi.com.br/api/cptec/v1/cidade/$encodedName',
    );
    
    if (response.data is List) {
      return List<Map<String, dynamic>>.from(
        (response.data as List).map((item) => Map<String, dynamic>.from(item)),
      );
    }
    throw Exception('Formato de resposta inválido ao buscar cidade.');
  }

  /// Busca a previsão do tempo para os próximos dias na BrasilAPI pelo ID da cidade
  Future<Map<String, dynamic>> getForecastByCityId(int cityId) async {
    final response = await _httpService.get(
      'https://brasilapi.com.br/api/cptec/v1/clima/previsao/$cityId',
    );
    
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    throw Exception('Formato de resposta inválido ao obter previsão climática.');
  }

  /// Busca o clima atual e diário com base em coordenadas GPS usando Open-Meteo
  Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    final response = await _httpService.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
        'timezone': 'America/Sao_Paulo',
      },
    );

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }
    throw Exception('Formato de resposta inválido ao buscar clima por coordenadas.');
  }

  /// Busca coordenadas (latitude e longitude) de uma cidade por nome usando a API de Geocodificação do Open-Meteo
  Future<Map<String, double>> getCoordinates(String cityName, String stateName) async {
    final query = '$cityName, $stateName, Brasil';
    final encodedQuery = Uri.encodeComponent(query);
    final response = await _httpService.get(
      'https://geocoding-api.open-meteo.com/v1/search?name=$encodedQuery&count=5&language=pt&format=json',
    );

    if (response.data is Map) {
      final data = Map<String, dynamic>.from(response.data);
      final results = data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final firstResult = Map<String, dynamic>.from(results.first);
        final lat = (firstResult['latitude'] as num).toDouble();
        final lon = (firstResult['longitude'] as num).toDouble();
        return {'latitude': lat, 'longitude': lon};
      }
    }

    // Fallback: busca apenas pelo nome da cidade se a busca completa com estado e país falhar
    final encodedCity = Uri.encodeComponent(cityName);
    final responseFallback = await _httpService.get(
      'https://geocoding-api.open-meteo.com/v1/search?name=$encodedCity&count=5&language=pt&format=json',
    );

    if (responseFallback.data is Map) {
      final data = Map<String, dynamic>.from(responseFallback.data);
      final results = data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final firstResult = Map<String, dynamic>.from(results.first);
        final lat = (firstResult['latitude'] as num).toDouble();
        final lon = (firstResult['longitude'] as num).toDouble();
        return {'latitude': lat, 'longitude': lon};
      }
    }

    throw Exception('Coordenadas não encontradas para a cidade "$cityName, $stateName".');
  }
}
