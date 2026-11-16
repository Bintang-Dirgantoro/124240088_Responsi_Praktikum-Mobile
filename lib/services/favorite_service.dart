import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoriteService {
  static const String _keyFavorites = 'favorite_movies_list';

  // ValueNotifier untuk sinkronisasi realtime status favorit di semua screen
  static final ValueNotifier<Set<String>> favoriteIdsNotifier = ValueNotifier<Set<String>>({});

  // Inisialisasi awal saat aplikasi mulai
  static Future<void> init() async {
    final favorites = await getFavorites();
    favoriteIdsNotifier.value = favorites.map((m) => m.id).toSet();
  }

  // Mengambil daftar semua film favorit dari SharedPreferences
  static Future<List<Movie>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_keyFavorites);
      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }
      return jsonList.map((item) {
        final Map<String, dynamic> map = jsonDecode(item);
        return Movie.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  // Cek apakah film difavoritkan secara sinkron (instan tanpa async)
  static bool isFavoriteSync(String movieId) {
    return favoriteIdsNotifier.value.contains(movieId);
  }

  // Menambahkan film ke favorit
  static Future<bool> addFavorite(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentList = prefs.getStringList(_keyFavorites) ?? [];

      final exists = currentList.any((item) {
        final map = jsonDecode(item);
        return map['id'] == movie.id;
      });

      if (!exists) {
        currentList.add(jsonEncode(movie.toJson()));
        await prefs.setStringList(_keyFavorites, currentList);

        // Update notifier realtime
        final updated = Set<String>.from(favoriteIdsNotifier.value)..add(movie.id);
        favoriteIdsNotifier.value = updated;
      }
      return true;
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return false;
    }
  }

  // Menghapus film dari favorit
  static Future<bool> removeFavorite(String movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentList = prefs.getStringList(_keyFavorites) ?? [];

      currentList.removeWhere((item) {
        final map = jsonDecode(item);
        return map['id'] == movieId;
      });

      await prefs.setStringList(_keyFavorites, currentList);

      // Update notifier realtime
      final updated = Set<String>.from(favoriteIdsNotifier.value)..remove(movieId);
      favoriteIdsNotifier.value = updated;
      return true;
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return false;
    }
  }

  // Toggle favorit (tambah jika belum, hapus jika sudah)
  // Return true jika baru ditambahkan, false jika dihapus
  static Future<bool> toggleFavorite(Movie movie) async {
    final isFav = isFavoriteSync(movie.id);
    if (isFav) {
      await removeFavorite(movie.id);
      return false;
    } else {
      await addFavorite(movie);
      return true;
    }
  }
}
