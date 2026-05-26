import '../models/weather_model.dart';

/// Interface para o repositório climático
abstract class WeatherRepository {
  Future<WeatherData> getWeatherForCity(String city);
  Future<WeatherData> getWeatherForLocation(double lat, double lon);
}

/// Implementação do repositório de Clima (atualmente mockupada, será integrada na Etapa 5)
class WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<WeatherData> getWeatherForCity(String city) async {
    // Simula uma chamada de API para teste inicial
    await Future.delayed(const Duration(milliseconds: 800));
    return WeatherData(
      cityName: city,
      stateName: 'BR',
      temp: 24.5,
      tempMin: 18.0,
      tempMax: 29.5,
      condition: 'Claro',
      description: 'Céu ensolarado com poucas nuvens',
      humidity: 65,
      windSpeed: 12.5,
      date: DateTime.now(),
    );
  }

  @override
  Future<WeatherData> getWeatherForLocation(double lat, double lon) async {
    // Simula chamada por geolocalização
    await Future.delayed(const Duration(milliseconds: 800));
    return WeatherData(
      cityName: 'Sua Localização',
      stateName: 'BR',
      temp: 22.0,
      tempMin: 15.0,
      tempMax: 26.0,
      condition: 'Nublado',
      description: 'Céu encoberto por nuvens',
      humidity: 80,
      windSpeed: 8.0,
      date: DateTime.now(),
    );
  }
}
