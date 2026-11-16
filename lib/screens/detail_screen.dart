import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';
import '../services/bookmark_service.dart';

class DetailScreen extends StatelessWidget {
  final News news;

  const DetailScreen({super.key, required this.news});

  // Membuka artikel asli di browser
  Future<void> _openFullArticle(BuildContext context) async {
    final rawUrl = news.url.trim();
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL artikel tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri? uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format URL tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka link artikel di browser'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka browser: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Toggle bookmark dengan SnackBar Hijau (tambah) dan Merah (hapus)
  void _toggleBookmark(BuildContext context) async {
    final isNowBookmarked = await BookmarkService.toggleBookmark(news);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (isNowBookmarked) {
      // Snackbar Hijau saat menambahkan bookmark
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berita berhasil ditambahkan ke bookmark',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Snackbar Merah saat menghapus bookmark
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Berita berhasil dihapus dari bookmark',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2C),
        elevation: 0,
        title: const Text(
          'Detail Berita',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Tombol bookmark di AppBar
          ValueListenableBuilder<Set<int>>(
            valueListenable: BookmarkService.bookmarkIdsNotifier,
            builder: (context, bookmarkIds, _) {
              final isBookmarked = bookmarkIds.contains(news.id);

              return IconButton(
                tooltip: isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? Colors.amber : Colors.white70,
                  size: 26,
                ),
                onPressed: () => _toggleBookmark(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Berita
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: news.imageUrl.isNotEmpty
                    ? Image.network(
                        news.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: const Color(0xFF1A1F2C),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: const Color(0xFF1A1F2C),
                        child: const Center(
                          child: Icon(Icons.newspaper, size: 64, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Sumber Berita (News Site) Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.public_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        news.newsSite,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Tanggal Publikasi
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      news.formattedPublishedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Judul Berita
            Text(
              news.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Penulis Berita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF252D3F),
                    child: Icon(Icons.person_outline_rounded, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Penulis / Author',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          news.authorDisplay,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ringkasan Berita (Summary)
            const Text(
              'Ringkasan Berita',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                news.summary.trim().isNotEmpty
                    ? news.summary.trim()
                    : 'Tidak ada ringkasan yang tersedia untuk artikel ini.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Tombol Read Full Article
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.open_in_browser_rounded, size: 22),
                label: const Text(
                  'Read Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () => _openFullArticle(context),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
