import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/home/home_screen.dart';
// Removed: import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// Removed: import 'dart:async';

void main() {
  runApp(MyApp());
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
      home: InsightTubeticsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  // Dark Theme - Cyan-Teal Aesthetic
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF00D9FF),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFF0A0E27),
    cardColor: Color(0xFF1A1F3A).withOpacity(0.6),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0A0E27),
      elevation: 0,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.jetBrainsMono(color: Color(0xFF00FFB9), fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w400),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF00D9FF),
      secondary: Color(0xFFFF6B9D),
      surface: Color(0xFF1A1F3A),
      background: Color(0xFF0A0E27),
      error: Color(0xFFFF5252),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
  );

  // Light Theme - Complementary Palette
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF0099CC),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFFF8FAFC),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: Color(0xFF0A0E27), fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: Color(0xFF0A0E27), fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: TextStyle(color: Color(0xFF0A0E27), fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.outfit(color: Color(0xFF0A0E27), fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.outfit(color: Color(0xFF0A0E27), fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: Color(0xFF0A0E27), fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: Color(0xFF0A0E27), fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Color(0xFF0A0E27), fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFF0A0E27), fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: Color(0xFF0A0E27), fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.jetBrainsMono(color: Color(0xFF0099CC), fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w400),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0099CC),
      secondary: Color(0xFFFF6B9D),
      surface: Colors.white,
      background: Color(0xFFF8FAFC),
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF0A0E27),
      onBackground: Color(0xFF0A0E27),
      onError: Colors.white,
    ),
  );
}