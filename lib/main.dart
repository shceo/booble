import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize audio
  await AudioService.initialize();

  runApp(const LaserMirrorMiniApp());
}

class LaserMirrorMiniApp extends StatelessWidget {
  const LaserMirrorMiniApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Mirror Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00D4FF),
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF),
          secondary: Color(0xFFAA00FF),
          tertiary: Color(0xFF00FF88),
          background: Color(0xFF0A0E27),
          surface: Color(0xFF1A1F3A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F3A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1F3A),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
