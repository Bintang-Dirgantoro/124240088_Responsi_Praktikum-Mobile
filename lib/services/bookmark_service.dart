import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/news.dart';

class BookmarkService {
  static const String _boxName = 'bookmarksBox';
  static final ValueNotifier<Set<int>> bookmarkIdsNotifier = ValueNotifier<Set<int>>({});

  // Inisialisasi Box Bookmark Hive Local Database
  static Future<void> init() async {
    await Hive.openBox(_boxName);
    _syncNotifier();
  }

  static Box _getBox() {
    return Hive.box(_boxName);
  }

  static void _syncNotifier() {
    final box = _getBox();
    final ids = <int>{};
    for (var key in box.keys) {
      final id = int.tryParse(key.toString());
      if (id != null) ids.add(id);
    }
    bookmarkIdsNotifier.value = ids;
  }

  // Cek bookmark secara instan & sinkron
  static bool isBookmarkedSync(int id) {
    return bookmarkIdsNotifier.value.contains(id);
  }

  // Ambil semua daftar bookmark dari Hive
  static Future<List<News>> getBookmarks() async {
    try {
      final box = _getBox();
      final List<News> list = [];
      for (var key in box.keys) {
        final val = box.get(key);
        if (val != null) {
          final map = Map<dynamic, dynamic>.from(val as Map);
          list.add(News.fromJson(map));
        }
      }
      return list.reversed.toList();
    } catch (e) {
      debugPrint('Error getting bookmarks: $e');
      return [];
    }
  }

  // Tambahkan berita ke bookmark Hive
  static Future<bool> addBookmark(News news) async {
    try {
      final box = _getBox();
      await box.put(news.id.toString(), news.toJson());
      _syncNotifier();
      return true;
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
      return false;
    }
  }

  // Hapus berita dari bookmark Hive
  static Future<bool> removeBookmark(int newsId) async {
    try {
      final box = _getBox();
      await box.delete(newsId.toString());
      _syncNotifier();
      return true;
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
      return false;
    }
  }

  // Toggle bookmark (return true jika ditambahkan, false jika dihapus)
  static Future<bool> toggleBookmark(News news) async {
    if (isBookmarkedSync(news.id)) {
      await removeBookmark(news.id);
      return false;
    } else {
      await addBookmark(news);
      return true;
    }
  }
}
