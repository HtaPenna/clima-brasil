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
}
