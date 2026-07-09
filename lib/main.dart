import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const SingleMartApp());
}

class SingleMartApp extends StatelessWidget {
  const SingleMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SingleMart',
      debugShowCheckedModeBanner: false,
      
      // Global Theme Configs (Modern White/Light Theme)
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF0D9488), // Clean Teal accent for merchants
          surface: Color(0xFFF8FAFC),
          error: Colors.redAccent,
        ),
        
        // Premium Typography and text theme setup
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF334155)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),
        ),
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      
      home: const SplashScreen(),
    );
  }
}
