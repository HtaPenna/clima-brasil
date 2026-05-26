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

  /// Retorna a abreviação do dia da semana (ex: Seg, Ter, Qua...)
  static String getWeekdayAbbreviation(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return 'Seg';
      case DateTime.tuesday: return 'Ter';
      case DateTime.wednesday: return 'Qua';
      case DateTime.thursday: return 'Qui';
      case DateTime.friday: return 'Sex';
      case DateTime.saturday: return 'Sáb';
      case DateTime.sunday: return 'Dom';
      default: return '';
    }
  }
}
