import 'package:flutter/material.dart';

/// Classes utilitárias auxiliares para formatação e helpers visuais
class AppUtils {
  /// Formata temperatura com símbolo de graus
  static String formatTemperature(double? temp) {
    if (temp == null) return '--°C';
    return '${temp.toStringAsFixed(0)}°C';
  }

  /// Retorna o ícone do Flutter correspondente ao tipo de clima
  static IconData getWeatherIcon(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('chuva') || cond.contains('tempestade') || cond.contains('temporal')) {
      return Icons.umbrella_rounded;
    } else if (cond.contains('nublado') || cond.contains('encoberto')) {
      return Icons.cloud_rounded;
    } else if (cond.contains('sol') || cond.contains('limpo') || cond.contains('claro')) {
      return Icons.wb_sunny_rounded;
    } else if (cond.contains('nevoeiro') || cond.contains('névoa')) {
      return Icons.grain_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }
}
