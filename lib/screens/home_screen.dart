import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clima_brasil/core/utils/app_utils.dart';
import 'package:clima_brasil/models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';

/// Tela inicial responsiva e moderna do Clima Brasil
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeatherByCity(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_queue_rounded, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Clima Brasil',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
            ),
            tooltip: 'Alternar Tema',
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Usar Localização Atual (GPS)',
            onPressed: () {
              // Simulação de geolocalização com coordenadas reais (São Paulo)
              context.read<WeatherProvider>().fetchWeatherByLocation(-23.5489, -46.6388);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Obtendo dados climáticos para sua localização (São Paulo - SP)...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de Busca Premium
                  _buildSearchBar(),
                  const SizedBox(height: 32),

                  // Consumo do estado reativo
                  Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return _buildLoadingState();
                      }

                      if (provider.errorMessage != null) {
                        return _buildErrorState(provider.errorMessage!);
                      }

                      final weather = provider.currentWeather;
                      if (weather == null) {
                        return _buildEmptyState();
                      }

                      // Layout Adaptativo com base no tamanho da tela
                      if (isLargeScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lado esquerdo: Clima Atual e Previsões Futuras
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  WeatherCard(weather: weather),
                                  const SizedBox(height: 28),
                                  _buildForecastSection(weather.forecast),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Lado direito: Histórico de Pesquisa
                            Expanded(
                              flex: 3,
                              child: _buildHistorySection(provider),
                            ),
                          ],
                        );
                      }

                      // Layout Mobile Empilhado
                      return Column(
                        children: [
                          WeatherCard(weather: weather),
                          const SizedBox(height: 28),
                          _buildForecastSection(weather.forecast),
                          const SizedBox(height: 28),
                          _buildHistorySection(provider),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Barra de pesquisa estilizada
  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cidade brasileira...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }

  /// Estado de carregamento moderno
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Column(
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Buscando clima atualizado...',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de erro amigável
  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: theme.colorScheme.error, size: 56),
              const SizedBox(height: 16),
              Text(
                'Ops! Ocorreu um problema',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<WeatherProvider>().clearError(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado vazio inicial elegante
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Explore o Clima',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Digite o nome de uma cidade acima ou clique\nno ícone de GPS para obter a previsão local.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Seção de Previsão Semanal (Horizontal)
  Widget _buildForecastSection(List<ForecastDay> forecast) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previsão para os Próximos Dias',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ForecastCard(forecast: forecast[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Seção de Histórico lateral ou inferior
  Widget _buildHistorySection(WeatherProvider provider) {
    if (provider.searchHistory.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pesquisas Recentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.searchHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = provider.searchHistory[index];
            return InkWell(
              onTap: () {
                _searchController.text = item.cityName;
                provider.fetchWeatherByCity(item.cityName);
              },
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.03),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppUtils.getWeatherIcon(item.condition),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.cityName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.condition,
                            style: TextStyle(fontSize: 12, color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.temp.toStringAsFixed(0)}°C',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
