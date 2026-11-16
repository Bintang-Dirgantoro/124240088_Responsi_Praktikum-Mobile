import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'services/bookmark_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive Local Database
  await Hive.initFlutter();

  // Inisialisasi Auth & Bookmark Service
  await AuthService.init();
  await BookmarkService.init();

  // Cek session login tersimpan di SharedPreferences
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(SpaceNewsApp(isLoggedIn: isLoggedIn));
}

class SpaceNewsApp extends StatelessWidget {
  final bool isLoggedIn;

  const SpaceNewsApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Explorer',
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
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
