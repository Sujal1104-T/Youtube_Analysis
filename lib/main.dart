import 'package:flutter/material.dart';
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

  // Dark Theme
  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.red,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFF1A1D29),
    cardColor: Color(0xFF2A2F3E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1A1D29),
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.grey[400]),
    ),
  );

  // Light Theme
  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.red,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.grey[600]),
    ),
  );
}