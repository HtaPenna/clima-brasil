import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';

/// Gerencia o estado dos dados de clima no aplicativo
class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository;

  WeatherProvider(this._repository);

  WeatherData? _currentWeather;
  WeatherData? get currentWeather => _currentWeather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<WeatherData> _searchHistory = [];
  List<WeatherData> get searchHistory => List.unmodifiable(_searchHistory);

  /// Busca clima de uma cidade pelo nome
  Future<void> fetchWeatherByCity(String city) async {
    if (city.isEmpty) return;
    _setLoading(true);
    _errorMessage = null;

    try {
      final data = await _repository.getWeatherForCity(city);
      _currentWeather = data;
      
      // Adiciona ao histórico, evitando duplicidades de nome de cidade
      _searchHistory.removeWhere((item) => item.cityName.toLowerCase() == data.cityName.toLowerCase());
      _searchHistory.insert(0, data);
      
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast(); // Mantém apenas as 5 últimas buscas no histórico rápido
      }
    } catch (e) {
      _errorMessage = 'Não foi possível encontrar o clima para "$city". Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  /// Busca clima usando as coordenadas GPS
  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final data = await _repository.getWeatherForLocation(lat, lon);
      _currentWeather = data;
    } catch (e) {
      _errorMessage = 'Falha ao buscar clima baseado na sua localização.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Limpa erros ativos
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
