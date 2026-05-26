import 'dart:convert';

/// Representa os dados meteorológicos de uma cidade
class WeatherData {
  final String cityName;
  final String stateName;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final DateTime date;

  WeatherData({
    required this.cityName,
    required this.stateName,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.date,
  });

  /// Converte para Map (ideal para salvar em Banco de Dados)
  Map<String, dynamic> toMap() {
    return {
      'city_name': cityName,
      'state_name': stateName,
      'temp': temp,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'condition': condition,
      'description': description,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'date': date.toIso8601String(),
    };
  }

  /// Cria a partir de um Map
  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      cityName: map['city_name'] ?? '',
      stateName: map['state_name'] ?? '',
      temp: (map['temp'] as num).toDouble(),
      tempMin: (map['temp_min'] as num).toDouble(),
      tempMax: (map['temp_max'] as num).toDouble(),
      condition: map['condition'] ?? '',
      description: map['description'] ?? '',
      humidity: (map['humidity'] as num).toInt(),
      windSpeed: (map['wind_speed'] as num).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherData.fromJson(String source) => WeatherData.fromMap(json.decode(source));
}
