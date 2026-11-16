class News {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String updatedAt;
  final List<String> authors;

  News({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    this.updatedAt = '',
    required this.authors,
  });

  String get authorDisplay {
    if (authors.isEmpty) {
      return newsSite.isNotEmpty ? newsSite : 'Space Reporter';
    }
    return authors.join(', ');
  }

  String get formattedPublishedDate {
    if (publishedAt.isEmpty) return '-';
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return publishedAt;
    }
  }

  factory News.fromJson(Map<dynamic, dynamic> json) {
    List<String> parsedAuthors = [];
    final rawAuthors = json['authors'];
    if (rawAuthors is List) {
      for (var a in rawAuthors) {
        if (a is Map) {
          final name = a['name'];
          if (name != null && name.toString().trim().isNotEmpty) {
            parsedAuthors.add(name.toString().trim());
          }
        } else if (a != null && a.toString().trim().isNotEmpty) {
          parsedAuthors.add(a.toString().trim());
        }
      }
    }

    if (parsedAuthors.isEmpty) {
      final site = json['news_site'] ?? json['newsSite'];
      if (site != null && site.toString().trim().isNotEmpty) {
        parsedAuthors.add(site.toString().trim());
      }
    }

    final rawId = json['id'];
    int parsedId = 0;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }

    return News(
      id: parsedId,
      title: json['title']?.toString() ?? 'No Title',
      url: (json['url'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? '').toString(),
      newsSite: (json['news_site'] ?? json['newsSite'] ?? 'SpaceNews').toString(),
      summary: (json['summary'] ?? json['description'] ?? 'Tidak ada ringkasan.').toString(),
      publishedAt: (json['published_at'] ?? json['publishedAt'] ?? json['publish_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      authors: parsedAuthors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'updated_at': updatedAt,
      'authors': authors.map((a) => {'name': a}).toList(),
    };
  }
}

typedef Article = News;
