import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../core/utils/app_utils.dart';
import '../core/theme/app_theme.dart';
import '../screens/map_screen.dart';
/// Card responsivo e moderno para exibição de dados climáticos
class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Gradiente dinâmico baseado na condição de clima
    final gradient = weather.condition.toLowerCase().contains('claro') || weather.condition.toLowerCase().contains('sol')
        ? AppTheme.dayGradient
        : AppTheme.nightGradient;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cidade e Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${weather.stateName} • Brasil',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
               Row(
                 children: [
                   Icon(
                     AppUtils.getWeatherIcon(weather.condition),
                     color: Colors.white,
                     size: 40,
                   ),
                   const SizedBox(width: 12),
                   IconButton(
                     icon: const Icon(Icons.map, color: Colors.white70),
                     tooltip: 'Ver no mapa',
                     onPressed: () {
                       // Navigate to map screen with coordinates
                       Navigator.of(context).push(
                         MaterialPageRoute(
                           builder: (_) => MapScreen(
                             latitude: weather.latitude,
                             longitude: weather.longitude,
                             cityName: weather.cityName,
                           ),
                         ),
                       );
                     },
                   ),
                 ],
               ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Temperatura e Condição
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppUtils.formatTemperature(weather.temp),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      weather.condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
          
          // Informações Extra (Umidade, Vento, Min/Max)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildExtraInfo(
                Icons.arrow_downward_rounded,
                'Min',
                AppUtils.formatTemperature(weather.tempMin),
              ),
              _buildExtraInfo(
                Icons.arrow_upward_rounded,
                'Max',
                AppUtils.formatTemperature(weather.tempMax),
              ),
              _buildExtraInfo(
                Icons.water_drop_rounded,
                'Umidade',
                '${weather.humidity}%',
              ),
              _buildExtraInfo(
                Icons.air_rounded,
                'Vento',
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
