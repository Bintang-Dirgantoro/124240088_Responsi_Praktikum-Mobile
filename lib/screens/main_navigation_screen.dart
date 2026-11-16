import 'package:flutter/material.dart';
import 'home_screen.dart';

// MainNavigationScreen forwarded to HomeScreen as required by the responsi specification
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
