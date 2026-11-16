class Movie {
  final String id;
  final String title;
  final String releaseDate;
  final String image;
  final String rating;
  final List<String> genre;
  final String createdAt;
  final String description;
  final String director;
  final List<String> casts;
  final String language;
  final String duration;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.image,
    required this.rating,
    required this.genre,
    required this.createdAt,
    required this.description,
    required this.director,
    required this.casts,
    required this.language,
    required this.duration,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Parse genre list aman
    final rawGenre = json['genre'];
    List<String> parsedGenre = [];
    if (rawGenre is List) {
      parsedGenre = rawGenre.map((e) => e.toString()).toList();
    }

    // Parse cast list aman
    final rawCast = json['cast'] ?? json['casts'];
    List<String> parsedCast = [];
    if (rawCast is List) {
      parsedCast = rawCast.map((e) => e.toString()).toList();
    }

    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      releaseDate: (json['release_date'] ?? json['releaseDate'] ?? '').toString(),
      image: (json['imgUrl'] ?? json['image'] ?? '').toString(),
      rating: (json['rating'] ?? '0.0').toString(),
      genre: parsedGenre,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      description: (json['description'] ?? 'Tidak ada sinopsis.').toString(),
      director: (json['director'] ?? '-').toString(),
      casts: parsedCast,
      language: (json['language'] ?? '-').toString(),
      duration: (json['duration'] ?? '-').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'release_date': releaseDate,
      'imgUrl': image,
      'rating': rating,
      'genre': genre,
      'created_at': createdAt,
      'description': description,
      'director': director,
      'cast': casts,
      'language': language,
      'duration': duration,
    };
  }
}
