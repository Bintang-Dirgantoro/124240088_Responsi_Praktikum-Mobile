import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String baseUrl = 'https://681388b3129f6313e2119693.mockapi.io/api/v1';

  // Mengambil daftar film dengan opsi filter genre & search judul
  static Future<List<Movie>> getMovies({
    String? genre,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/movie');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List results = [];
        if (decoded is List) {
          results = decoded;
        } else if (decoded is Map<String, dynamic>) {
          results = decoded['results'] ?? decoded['data'] ?? [];
        }

        List<Movie> movies = results.map((item) => Movie.fromJson(item)).toList();

        // Filter genre (client-side filter aman & akurat untuk MockAPI)
        if (genre != null && genre.isNotEmpty && genre.toLowerCase() != 'all') {
          movies = movies.where((m) {
            return m.genre.any((g) => g.toLowerCase() == genre.toLowerCase());
          }).toList();
        }

        // Search judul
        if (search != null && search.trim().isNotEmpty) {
          final query = search.trim().toLowerCase();
          movies = movies.where((m) {
            return m.title.toLowerCase().contains(query);
          }).toList();
        }

        return movies;
      } else {
        throw Exception('Gagal memuat film (Status code: ${response.statusCode})');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Format data tidak valid');
      }
      rethrow;
    }
  }

  // Mengambil detail film berdasarkan ID
  static Future<Movie> getMovieDetail(String id) async {
    final uri = Uri.parse('$baseUrl/movie/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Film tidak ditemukan (Status code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
