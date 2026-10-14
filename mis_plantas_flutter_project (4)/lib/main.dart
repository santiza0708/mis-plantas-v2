import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación vertical para experiencia móvil óptima
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de estado transparente para diseño inmersivo Material Design 3
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111412),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar servicio de notificaciones locales de Android
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: MisPlantasApp(),
    ),
  );
}

class MisPlantasApp extends StatelessWidget {
  const MisPlantasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Plantas',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
