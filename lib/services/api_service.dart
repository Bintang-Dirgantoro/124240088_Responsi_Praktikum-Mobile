import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // Mengambil daftar berita luar angkasa dengan opsi filter news_site & pencarian
  static Future<List<News>> getNews({
    String? newsSite,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (newsSite != null &&
        newsSite.isNotEmpty &&
        newsSite.toLowerCase() != 'all' &&
        newsSite.toLowerCase() != 'semua') {
      queryParams['news_site'] = newsSite;
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/articles/').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List results = [];
        if (decoded is Map<String, dynamic>) {
          results = decoded['results'] ?? [];
        } else if (decoded is List) {
          results = decoded;
        }

        return results.map((item) => News.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat berita luar angkasa (Kode status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Format data respon tidak valid');
      }
      rethrow;
    }
  }

  // Alias getArticles
  static Future<List<News>> getArticles({
    String? newsSite,
    String? search,
    int limit = 20,
  }) =>
      getNews(newsSite: newsSite, search: search, limit: limit);

  // Mengambil daftar sumber publikasi (news sites) dari endpoint info
  static Future<List<String>> getNewsSites() async {
    final uri = Uri.parse('$baseUrl/info/');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List sites = data['news_sites'] ?? [];
        final list = sites.map((e) => e.toString()).toList();
        if (list.isNotEmpty) {
          return list;
        }
      }
    } catch (_) {
      // Fallback list jika koneksi offline/timeout
    }

    return [
      'NASA',
      'SpaceNews',
      'Space.com',
      'Spaceflight Now',
      'Arstechnica',
      'Teslarati',
      'ESA',
      'SpaceX',
      'Blue Origin',
      'European Spaceflight',
      'The Verge',
      'CNBC',
    ];
  }
}
