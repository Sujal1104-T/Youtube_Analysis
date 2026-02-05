import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/splash/splash_screen.dart';
// Removed: import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// Removed: import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // Add a static method to access the state from child widgets
  static MyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>()!;
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = true; // Default to dark mode

  // Removed: Deep linking state variables and streams

  @override
  void initState() {
    super.initState();
    // Removed: Deep linking stream initialization logic
  }

  @override
  void dispose() {
    // Removed: Deep linking stream disposal
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightTube',
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      // Removed: Passing initialUrl
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  // Dark Theme - Cyan-Teal Aesthetic
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00D9FF),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    cardColor: const Color(0xFF1A1F3A).withOpacity(0.6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0E27),
      elevation: 0,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      TextTheme(
        displayLarge: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.jetBrainsMono(color: const Color(0xFF00FFB9), fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w400),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00D9FF),
      secondary: Color(0xFFFF6B9D),
      surface: Color(0xFF1A1F3A),
      error: Color(0xFFFF5252),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
  );

  // Light Theme - Complementary Palette
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0099CC),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      TextTheme(
        displayLarge: const TextStyle(color: Color(0xFF0A0E27), fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: const TextStyle(color: Color(0xFF0A0E27), fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: const TextStyle(color: Color(0xFF0A0E27), fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.outfit(color: const Color(0xFF0A0E27), fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.outfit(color: const Color(0xFF0A0E27), fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: const Color(0xFF0A0E27), fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: const Color(0xFF0A0E27), fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(color: Color(0xFF0A0E27), fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Color(0xFF0A0E27), fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(color: Color(0xFF0A0E27), fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.jetBrainsMono(color: const Color(0xFF0099CC), fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w400),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0099CC),
      secondary: Color(0xFFFF6B9D),
      surface: Colors.white,
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0A0E27),
      onError: Colors.white,
    ),
  );
}