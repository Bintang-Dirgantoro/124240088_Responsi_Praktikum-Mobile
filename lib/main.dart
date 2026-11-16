import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive Local Database (NO .g.dart!)
  await Hive.initFlutter();

  // Inisialisasi Auth & Favorite Service
  await AuthService.init();
  await FavoriteService.init();

  // Cek session login tersimpan di SharedPreferences
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(MovieExplorerApp(isLoggedIn: isLoggedIn));
}

class MovieExplorerApp extends StatelessWidget {
  final bool isLoggedIn;

  const MovieExplorerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF11141C),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
          surface: Color(0xFF1A1F2C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F2C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
