import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../core/utils/app_utils.dart';

/// Card para exibição de previsão de dias futuros em formato de lista ou grid
class ForecastCard extends StatelessWidget {
  final ForecastDay forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dia da Semana
          Text(
            AppUtils.getWeekdayAbbreviation(forecast.date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          
          // Data Formatada (dia/mês)
          Text(
            '${forecast.date.day.toString().padLeft(2, '0')}/${forecast.date.month.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),

          // Ícone Meteorológico
          Icon(
            AppUtils.getWeatherIcon(forecast.condition),
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),

          // Condição resumida
          Text(
            forecast.condition,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Temperatura Min / Max
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${forecast.min.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                '${forecast.max.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
