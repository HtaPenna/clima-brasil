import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Repositório Mock/Instância Inicial
  final weatherRepository = WeatherRepositoryImpl();

  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      title: 'Clima Brasil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Altera dinamicamente com base no SO
      home: const HomeScreen(),
    );
  }
}
