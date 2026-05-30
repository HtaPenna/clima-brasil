import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../core/utils/app_utils.dart';

/// Card para exibição de previsão de dias futuros
class ForecastCard extends StatelessWidget {
  final ForecastDay forecast;

  const ForecastCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.20 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dia da semana
          FittedBox(
            child: Text(
              AppUtils.getWeekdayAbbreviation(forecast.date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Data
          Text(
            '${forecast.date.day.toString().padLeft(2, '0')}/${forecast.date.month.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 6),

          // Ícone
          Icon(
            AppUtils.getWeatherIcon(forecast.condition),
            color: theme.colorScheme.primary,
            size: 24,
          ),

          const SizedBox(height: 6),

          // Condição
          Text(
            forecast.condition,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Temperaturas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${forecast.min.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${forecast.max.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 11,
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