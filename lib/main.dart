import 'package:flutter/material.dart';
import 'screens/hero_screen.dart'; // import your hero screen file

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Jeel Patel Portfolio",

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00F5C4),
          brightness: Brightness.dark,
        ),

        fontFamily: 'Poppins',
      ),

      home: const HeroScreen(),
    );
  }
}