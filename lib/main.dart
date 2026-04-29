import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/db_service.dart';
import 'services/notification_service.dart';
import 'providers/plant_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init DB and Notifications
  final dbService = DbService();
  await dbService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider(dbService, notificationService)),
      ],
      child: const PlantCareApp(),
    ),
  );
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Urban Houseplant Care',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              primary: Colors.green[700],
              secondary: Colors.lightGreen,
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
              primary: Colors.green[400],
              secondary: Colors.lightGreen,
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[900],
              foregroundColor: Colors.white,
            ),
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}
