import 'dart:async';
import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<News> _newsList = [];
  List<String> _newsSites = ['All'];
  String _selectedSite = 'All';

  bool _isLoading = true;
  String? _errorMessage;
  String _username = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadNewsSites();
    _fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Ambil username pengguna yang sedang login untuk title AppBar
  void _loadUser() async {
    final username = await AuthService.getUsername();
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  // Ambil daftar news sites dari API untuk filter
  Future<void> _loadNewsSites() async {
    final sites = await ApiService.getNewsSites();
    if (mounted) {
      setState(() {
        _newsSites = ['All', ...sites];
      });
    }
  }

  // Ambil berita dari API (minimal 20 data agar > 10)
  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getNews(
        newsSite: _selectedSite == 'All' ? null : _selectedSite,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        limit: 25, // Minimal 10 berita sesuai ketentuan soal
      );

      if (mounted) {
        setState(() {
          _newsList = list;
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
      _fetchNews();
    });
  }

  void _onSiteSelected(String site) {
    if (_selectedSite == site) return;
    setState(() {
      _selectedSite = site;
    });
    _fetchNews();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2433),
        title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar'),
          ),
        ],
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
        // Title AppBar: Menampilkan username pengguna yang sedang login
        title: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _username.isNotEmpty ? _username : 'SpaceNews Explorer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Sediakan button pada bagian kanan AppBar yang mengarah ke halaman Bookmark
          IconButton(
            tooltip: 'Halaman Bookmark',
            icon: const Icon(Icons.bookmark_rounded, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarkScreen()),
              );
            },
          ),
          // Tombol logout
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.amber,
        backgroundColor: const Color(0xFF1A1F2C),
        onRefresh: _fetchNews,
        child: Column(
          children: [
            // Search Bar & Filter Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: const Color(0xFF1A1F2C),
              child: Column(
                children: [
                  // Kolom Pencarian
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari berita luar angkasa...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.amber),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _fetchNews();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF11141C),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Header Filter News Site & Dropdown
                  Row(
                    children: [
                      const Icon(Icons.filter_list_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter Sumber (News Site):',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),

                      // Dropdown untuk memilih dari seluruh daftar news sites
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _newsSites.contains(_selectedSite) ? _selectedSite : 'All',
                          dropdownColor: const Color(0xFF1E2433),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          onChanged: (String? value) {
                            if (value != null) {
                              _onSiteSelected(value);
                            }
                          },
                          items: _newsSites.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value == 'All' ? 'Semua Sumber' : value,
                                style: TextStyle(
                                  color: value == _selectedSite ? Colors.amber : Colors.white,
                                  fontWeight: value == _selectedSite
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Chips untuk Sumber Populer
            Container(
              height: 44,
              color: const Color(0xFF1A1F2C),
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All',
                  'NASA',
                  'SpaceNews',
                  'Space.com',
                  'Spaceflight Now',
                  'Arstechnica',
                  'Teslarati',
                  'ESA',
                  'SpaceX',
                ].map((site) {
                  final isSelected = _selectedSite == site;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(site == 'All' ? 'Semua' : site),
                      selected: isSelected,
                      selectedColor: Colors.amber,
                      backgroundColor: const Color(0xFF11141C),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.amber : Colors.white12,
                        ),
                      ),
                      onSelected: (_) => _onSiteSelected(site),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Konten Utama Berita
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Loading Indicator ketika data sedang dimuat
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Memuat berita luar angkasa...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 2. Error Message
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _fetchNews,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State
    if (_newsList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.article_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Tidak Ada Berita Ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedSite != 'All'
                    ? 'Tidak ada berita dari sumber "$_selectedSite". Coba pilih sumber lain.'
                    : 'Tidak ada berita yang cocok dengan kata kunci.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (_selectedSite != 'All' || _searchController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSiteSelected('All');
                  },
                  child: const Text('Reset Filter', style: TextStyle(color: Colors.amber)),
                ),
            ],
          ),
        ),
      );
    }

    // 4. Daftar Berita (Menampilkan gambar, judul, sumber berita, tanggal publikasi)
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _newsList.length,
      itemBuilder: (context, index) {
        final item = _newsList[index];

        return Card(
          color: const Color(0xFF1A1F2C),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(news: item),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Berita
                Stack(
                  children: [
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF252D3F),
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF252D3F),
                              child: const Center(
                                child: Icon(Icons.newspaper, size: 48, color: Colors.grey),
                              ),
                            ),
                    ),
                    // Sumber Berita (News Site Badge di atas gambar)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              item.newsSite,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Quick Bookmark Button di sudut kanan atas
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder<Set<int>>(
                        valueListenable: BookmarkService.bookmarkIdsNotifier,
                        builder: (context, bookmarkIds, _) {
                          final isBookmarked = bookmarkIds.contains(item.id);
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 22,
                              icon: Icon(
                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: isBookmarked ? Colors.amber : Colors.white,
                              ),
                              onPressed: () async {
                                final added = await BookmarkService.toggleBookmark(item);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? 'Berita berhasil ditambahkan ke bookmark'
                                          : 'Berita berhasil dihapus dari bookmark',
                                    ),
                                    backgroundColor: added ? Colors.green[700] : Colors.red[700],
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Info Berita
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Berita
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tanggal Publikasi & News Site
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            item.formattedPublishedDate,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Spacer(),
                          const Text(
                            'Baca Selengkapnya',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
