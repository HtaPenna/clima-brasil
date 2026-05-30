import 'dart:convert';

/// Representa a previsão de um dia específico futuro
class ForecastDay {
  final DateTime date;
  final double min;
  final double max;
  final String condition;
  final int uvIndex;

  ForecastDay({
    required this.date,
    required this.min,
    required this.max,
    required this.condition,
    required this.uvIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'min': min,
      'max': max,
      'condition': condition,
      'uv_index': uvIndex,
    };
  }

  factory ForecastDay.fromMap(Map<String, dynamic> map) {
    return ForecastDay(
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      min: (map['min'] as num?)?.toDouble() ?? 0.0,
      max: (map['max'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] ?? 'Desconhecido',
      uvIndex: (map['uv_index'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Representa os dados meteorológicos completos de uma cidade, incluindo a previsão dos próximos dias
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
  final List<ForecastDay> forecast;
  final double latitude;
  final double longitude;

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
    required this.forecast,
    required this.latitude,
    required this.longitude,
  });

  /// Converte para Map (para persistência em Banco de Dados)
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
      'forecast': forecast.map((x) => x.toMap()).toList(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Cria a partir de um Map
  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      cityName: map['city_name'] ?? '',
      stateName: map['state_name'] ?? '',
      temp: (map['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (map['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (map['temp_max'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] ?? '',
      description: map['description'] ?? '',
      humidity: (map['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (map['wind_speed'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      forecast: map['forecast'] != null
          ? List<ForecastDay>.from(
              (map['forecast'] as List).map((x) => ForecastDay.fromMap(Map<String, dynamic>.from(x))),
            )
          : [],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherData.fromJson(String source) => WeatherData.fromMap(json.decode(source));
}
