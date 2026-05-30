import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';

class TemperatureChart extends StatelessWidget {
  final List<ForecastDay> forecast;
  final TemperatureUnit unit;

  const TemperatureChart({
    Key? key,
    required this.forecast,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }
    final spots = forecast.asMap().entries.map((e) {
      final idx = e.key.toDouble();
      final temp = unit == TemperatureUnit.celsius
          ? e.value.temp
          : e.value.temp * 9 / 5 + 32;
      return FlSpot(idx, temp);
    }).toList();
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(enabled: true),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= forecast.length) return const SizedBox();
              final date = forecast[idx].date;
              return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
            })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
