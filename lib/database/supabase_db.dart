import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

/// Classe gerenciadora do Banco de Dados online (Supabase) com fallback local (SharedPreferences)
class SupabaseDb {
  static final SupabaseDb _instance = SupabaseDb._internal();

  factory SupabaseDb() {
    return _instance;
  }

  SupabaseDb._internal();

  SharedPreferences? _prefs;
  bool _isSupabaseInitialized = false;
  bool get isSupabaseInitialized => _isSupabaseInitialized;

  static const String _localHistoryKey = 'local_weather_history';

  /// Inicializa as configurações do Supabase e SharedPreferences
  Future<void> initialize({
    String? url,
    String? anonKey,
    SharedPreferences? prefs,
  }) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();

    if (url != null && url.isNotEmpty && anonKey != null && anonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _isSupabaseInitialized = true;
        print('Banco de Dados Supabase conectado com sucesso.');
      } catch (e) {
        print('Falha ao inicializar o Supabase, utilizando SharedPreferences local: $e');
        _isSupabaseInitialized = false;
      }
    } else {
      print('Credenciais do Supabase ausentes. Utilizando SharedPreferences local por padrão.');
      _isSupabaseInitialized = false;
    }
  }

  /// Salva uma busca de clima no histórico (online se ativo, caso contrário local)
  Future<void> saveWeatherSearch(WeatherData weather) async {
    // Sempre salva no cache local primeiro
    await _saveToLocalHistory(weather);

    // Se Supabase estiver configurado, tenta salvar remotamente
    if (_isSupabaseInitialized) {
      try {
        await Supabase.instance.client.from('weather_history').insert({
          'city_name': weather.cityName,
          'state_name': weather.stateName,
          'temp': weather.temp,
          'temp_min': weather.tempMin,
          'temp_max': weather.tempMax,
          'condition': weather.condition,
          'description': weather.description,
          'humidity': weather.humidity,
          'wind_speed': weather.windSpeed,
          'latitude': weather.latitude,
          'longitude': weather.longitude,
        });
        print('Histórico climático salvo no Supabase com sucesso.');
      } catch (e) {
        print('Erro ao persistir dados no Supabase: $e');
      }
    }
  }

  /// Recupera as buscas de clima salvas no histórico (tenta Supabase, cai no local se falhar)
  Future<List<WeatherData>> getSavedSearches() async {
    if (_isSupabaseInitialized) {
      try {
        final response = await Supabase.instance.client
            .from('weather_history')
            .select()
            .order('created_at', ascending: false)
            .limit(10);
        final list = response as List;
        return list.map((item) {
          final map = Map<String, dynamic>.from(item);
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
            latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
            date: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
            forecast: [],
          );
        }).toList();
      } catch (e) {
        print('Erro ao carregar do Supabase, buscando do histórico local: $e');
      }
    }
    // Fallback para histórico local
    return _getLocalHistory();
  }

  /// Salva no cache local do SharedPreferences
  Future<void> _saveToLocalHistory(WeatherData weather) async {
    if (_prefs == null) return;

    final currentHistory = _getLocalHistory();
    // Evita duplicidades na lista rápida (remove se já existir com o mesmo nome)
    currentHistory.removeWhere((item) => item.cityName.toLowerCase() == weather.cityName.toLowerCase());
    currentHistory.insert(0, weather);

    // Limita o histórico local a 10 buscas
    if (currentHistory.length > 10) {
      currentHistory.removeLast();
    }

    final jsonList = currentHistory.map((item) => item.toMap()).toList();
    await _prefs!.setString(_localHistoryKey, json.encode(jsonList));
  }

  /// Recupera do cache local do SharedPreferences
  List<WeatherData> _getLocalHistory() {
    if (_prefs == null) return [];
    final jsonStr = _prefs!.getString(_localHistoryKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = json.decode(jsonStr) as List;
      return list.map((item) => WeatherData.fromMap(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      print('Erro ao decodificar histórico local: $e');
      return [];
    }
  }
}
