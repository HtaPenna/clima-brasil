import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'providers/weather_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/http_service.dart';
import 'services/weather_api_service.dart';
import 'database/supabase_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa SharedPreferences antes da renderização do app
  final prefs = await SharedPreferences.getInstance();
  
  final httpService = DioHttpService();
  final apiService = WeatherApiService(httpService);
  final supabaseDb = SupabaseDb();
  await supabaseDb.initialize(prefs: prefs);
  final weatherRepository = WeatherRepositoryImpl(apiService, supabaseDb);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(weatherRepository),
        ),
      ],
      child: const ClimaBrasilApp(),
    ),
  );
}

class ClimaBrasilApp extends StatelessWidget {
  const ClimaBrasilApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o ThemeProvider para reconstruir a árvore visual quando o tema muda
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Clima Brasil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
