import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorite_service.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  void _toggleFavorite(BuildContext context) async {
    final isNowFav = await FavoriteService.toggleFavorite(movie);

    if (!context.mounted) return;
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
    return Scaffold(
      backgroundColor: const Color(0xFF11141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2C),
        elevation: 0,
        title: Text(
          movie.title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoriteService.favoriteIdsNotifier,
            builder: (context, favIds, _) {
              final isFav = favIds.contains(movie.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white70,
                ),
                onPressed: () => _toggleFavorite(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Besar di Tengah
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: Image.network(
                    movie.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 180,
                      height: 250,
                      color: const Color(0xFF1A1F2C),
                      child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Judul Film
            Text(
              movie.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // Row Info Cepat (Rating, Durasi, Bahasa)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickInfo(Icons.star, Colors.amber, 'Rating', movie.rating),
                  _buildDivider(),
                  _buildQuickInfo(Icons.timer_outlined, Colors.blueAccent, 'Durasi', movie.duration),
                  _buildDivider(),
                  _buildQuickInfo(Icons.language, Colors.greenAccent, 'Bahasa', movie.language),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Genre Chips
            const Text(
              'Genre',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: movie.genre.map((g) {
                return Chip(
                  label: Text(g),
                  backgroundColor: const Color(0xFF1E2433),
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  side: const BorderSide(color: Colors.white12),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Sutradara & Rilis
            _buildInfoRow('Sutradara', movie.director),
            _buildInfoRow('Tanggal Rilis', movie.releaseDate),

            const Divider(color: Colors.white12, height: 28),

            // Sinopsis
            const Text(
              'Sinopsis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            const SizedBox(height: 8),
            Text(
              movie.description,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // Pemeran / Casts
            if (movie.casts.isNotEmpty) ...[
              const Text(
                'Pemeran (Casts)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: movie.casts.map((actor) {
                  return Chip(
                    avatar: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, size: 14, color: Colors.black),
                    ),
                    label: Text(actor),
                    backgroundColor: const Color(0xFF1A1F2C),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    side: const BorderSide(color: Colors.white12),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),

            // Tombol Toggle Favorit Bawah
            ValueListenableBuilder<Set<String>>(
              valueListenable: FavoriteService.favoriteIdsNotifier,
              builder: (context, favIds, _) {
                final isFav = favIds.contains(movie.id);
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleFavorite(context),
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black,
                    ),
                    label: Text(
                      isFav ? 'HAPUS DARI FAVORIT' : 'TAMBAH KE FAVORIT',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFav ? const Color(0xFF2A1F24) : Colors.amber,
                      foregroundColor: isFav ? Colors.red : Colors.black,
                      side: isFav ? const BorderSide(color: Colors.red) : BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, Color iconColor, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white10);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
