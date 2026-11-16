# 🎬 Panduan Proyek `latianresponsi_movie` (Katalog Film)

> Proyek ini adalah versi **bersih dan mudah dipahami** dari responsi film tahun lalu (`prasasti_terdahulu`).  
> **100% BEBAS DARI `.g.dart`, `build_runner`, dan `GetX`!**  
> Semua arsitektur dan pola kodenya **persis sama dengan `latian_responsi` kamu**.

---

## 🗂️ Struktur Folder

```
latianresponsi_movie/
├── lib/
│   ├── main.dart                      # Init Hive, AuthService, FavoriteService, Cek Login
│   ├── models/
│   │   ├── user.dart                  # Model akun user (username, password, fullName)
│   │   └── movie.dart                 # Model film (fromJson & toJson manual, TANPA .g.dart!)
│   ├── services/
│   │   ├── auth_service.dart          # Register & Login ke Hive, Session SharedPreferences
│   │   ├── api_service.dart           # GET https://681388b3129f6313e2119693.mockapi.io/api/v1/movie
│   │   └── favorite_service.dart      # Simpan list JSON ke SharedPreferences + ValueNotifier
│   └── screens/
│       ├── login_screen.dart          # Login form + demo user sukuna/sukuna123
│       ├── register_screen.dart       # Register akun baru ke Hive
│       ├── main_navigation_screen.dart# Bottom Navigation (Film & Favorit) + Tombol Logout
│       ├── home_screen.dart           # Search, Filter Genre Chips, List Card Film, Realtime Love
│       ├── detail_screen.dart         # Poster, Sinopsis, Rating, Durasi, Genre, Casts, Fav Button
│       └── favorite_screen.dart       # List Favorit + Swipe to Delete (Dismissible) + Undo
└── pubspec.yaml                       # Dependencies: http, shared_preferences, hive, hive_flutter
```

---

## 🔍 Mengapa Proyek Kating Pakai `.g.dart` & Kenapa Kita Buang?

Di proyek kating (`prasasti_terdahulu`), mereka menggunakan:
```dart
part 'movie.g.dart';
@HiveType(typeId: 1)
class Movie { ... }
```
Ini mewajibkan menjalankan command terminal:
```bash
dart run build_runner build
```
Kalau lupa atau gagal, kode langsung error merah semua!

### ✅ Solusi Bersih Kita:
1. **User (Hive Local DB):** Disimpan sebagai `Map<String, dynamic>` biasa (`box.put(username, user.toMap())`). Tidak butuh generator apa pun!
2. **Favorit (SharedPreferences):** Disimpan sebagai List String JSON (`jsonEncode(movie.toJson())`).
3. **State & Navigasi:** Menggunakan bawaan Flutter standar (`StatefulWidget`, `ValueNotifier`, `Navigator.push`). Tidak butuh GetX yang bikin bingung.

---

## 🚀 Fitur Lengkap yang Berjalan:
1. **Auth Session:** Register akun baru $\rightarrow$ Login $\rightarrow$ Auto-login tersimpan saat aplikasi ditutup $\rightarrow$ Logout bersih.
2. **Koneksi API Asli:** Menggunakan API ujian kating `https://681388b3129f6313e2119693.mockapi.io/api/v1/movie`.
3. **Search & Filter Genre:** Filter berdasarkan Horror, Mystery, Action, Drama, dll.
4. **Sinkronisasi Favorit Realtime:** Ikon love merah di Home, Detail, dan List Favorit langsung sinkron berkat `ValueNotifier`.
5. **Swipe to Delete:** Geser card favorit ke kiri untuk menghapus, dilengkapi tombol *BATALKAN (Undo)*.
