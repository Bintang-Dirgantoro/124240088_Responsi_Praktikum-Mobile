import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedGenre = 'All';
  Timer? _debounceTimer;

  // Daftar opsi genre film
  final List<String> _genreOptions = [
    'All',
    'Horror',
    'Mystery',
    'Action',
    'Drama',
    'Comedy',
    'Adventure',
    'Romance',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getMovies(
        genre: _selectedGenre == 'All' ? null : _selectedGenre,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _movies = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchMovies();
    });
  }

  void _onGenreSelected(String genre) {
    if (_selectedGenre == genre) return;
    setState(() {
      _selectedGenre = genre;
    });
    _fetchMovies();
  }

  void _toggleFavorite(Movie movie) async {
    final isNowFav = await FavoriteService.toggleFavorite(movie);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNowFav ? Icons.favorite : Icons.favorite_border,
              color: isNowFav ? Colors.red : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isNowFav
                    ? '${movie.title} ditambahkan ke favorit'
                    : '${movie.title} dihapus dari favorit',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E2433),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari judul film...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.amber),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _fetchMovies();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1A1F2C),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 2. Horizontal Genre Filter Chips
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _genreOptions.length,
            itemBuilder: (context, index) {
              final genre = _genreOptions[index];
              final isSelected = _selectedGenre == genre;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (_) => _onGenreSelected(genre),
                  selectedColor: Colors.amber,
                  checkmarkColor: Colors.black,
                  backgroundColor: const Color(0xFF1A1F2C),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.amber : Colors.white12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // 3. Konten Utama (Loading / Error / List)
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchMovies,
            color: Colors.amber,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchMovies,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Film tidak ditemukan.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _movies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final movie = _movies[index];

        return Card(
          color: const Color(0xFF1A1F2C),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(movie: movie),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster Film
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 75,
                      height: 105,
                      child: Image.network(
                        movie.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black26,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Info Film
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 15, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              movie.releaseDate,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Genre tags
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: movie.genre.take(3).map((g) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                g,
                                style: const TextStyle(fontSize: 10, color: Colors.amber),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Love Favorit (Realtime ValueNotifier)
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoriteService.favoriteIdsNotifier,
                    builder: (context, favIds, _) {
                      final isFav = favIds.contains(movie.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(movie),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
