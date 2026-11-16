import 'package:flutter/material.dart';
import 'bookmark_screen.dart';

// Alias for FavoriteScreen to ensure compatibility
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookmarkScreen();
  }
}
