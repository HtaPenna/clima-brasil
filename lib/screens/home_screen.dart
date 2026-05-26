import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';

/// Tela inicial responsiva do aplicativo Clima Brasil
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
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Brasil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Detectar minha localização',
            onPressed: () {
              // Simulando geolocalização por coordenadas de São Paulo
              context.read<WeatherProvider>().fetchWeatherByLocation(-23.5505, -46.6333);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Obtendo localização atual... (Simulado)')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Como está o tempo hoje?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busque o clima em tempo real para qualquer cidade brasileira.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Barra de Pesquisa Responsiva
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Digite a cidade... Ex: São Paulo, RJ',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _onSearch,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Gerenciamento de Estado Reativo
                  Consumer<WeatherProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (provider.errorMessage != null) {
                        return Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Theme.of(context).colorScheme.error, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  provider.errorMessage!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final weather = provider.currentWeather;
                      if (weather == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'Pesquise uma cidade acima para ver as condições climáticas.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      // Se a tela for larga (Web/Tablet), coloca o clima e o histórico lado a lado
                      if (isLargeScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: WeatherCard(weather: weather),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: _buildHistorySection(provider),
                            ),
                          ],
                        );
                      }

                      // Layout Mobile empilhado
                      return Column(
                        children: [
                          WeatherCard(weather: weather),
                          const SizedBox(height: 24),
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

  Widget _buildHistorySection(WeatherProvider provider) {
    if (provider.searchHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pesquisas Recentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.searchHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = provider.searchHistory[index];
            return ListTile(
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(item.cityName),
              subtitle: Text(item.condition),
              trailing: Text(
                '${item.temp.toStringAsFixed(0)}°C',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () {
                _searchController.text = item.cityName;
                provider.fetchWeatherByCity(item.cityName);
              },
            );
          },
        ),
      ],
    );
  }
}
