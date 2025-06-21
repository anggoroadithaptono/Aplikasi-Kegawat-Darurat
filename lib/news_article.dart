class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;

  NewsArticle({
    required this.title, 
    required this.description, 
    required this.url, 
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title', 
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '', 
      source: json['source'] != null ? json['source']['name'] ?? 'Unknown Source' : 'Unknown Source',
      publishedAt: json['publishedAt'] != null 
        ? DateTime.parse(json['publishedAt']) 
        : DateTime.now(),
    );
  }

  String get formattedDate {
    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }
}