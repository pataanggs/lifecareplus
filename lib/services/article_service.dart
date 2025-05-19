import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Article {
  final String title;
  final String imageUrl;
  final String category;
  final String url;
  final String timeToRead;
  final String source;
  final String publishedAt;

  Article({
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.url,
    required this.timeToRead,
    this.source = '',
    this.publishedAt = '',
  });
}

class ArticleService {
  static const String _apiKey = '3bab95e7f6994acd89d8f8f378113095';

  static Future<List<Article>> fetchHealthArticles() async {
    try {
      // Use Indonesian news sources with health category
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/top-headlines?country=id&category=health&apiKey=$_apiKey',
        ),
      );

      if (kDebugMode) {
        print('NewsAPI response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('Articles found: ${data['articles'].length}');
        }

        final articles = <Article>[];

        for (var item in data['articles']) {
          // Calculate reading time based on content length
          final title = item['title'] ?? 'Artikel Kesehatan';
          final description = item['description'] ?? '';
          final readTimeMinutes = _calculateReadTime(title, description);

          // Parse the date
          String formattedDate = '';
          try {
            final publishedAt = item['publishedAt'];
            if (publishedAt != null) {
              final date = DateTime.parse(publishedAt);
              formattedDate = _formatDate(date);
            }
          } catch (e) {
            formattedDate = '';
          }

          articles.add(
            Article(
              title: title,
              imageUrl: item['urlToImage'] ?? '',
              category: 'Kesehatan',
              timeToRead: '$readTimeMinutes menit baca',
              url: item['url'] ?? '',
              source: item['source']['name'] ?? 'News',
              publishedAt: formattedDate,
            ),
          );
        }

        // If we got articles, return them. Otherwise use fallback.
        if (articles.isNotEmpty) {
          return articles;
        } else {
          if (kDebugMode) {
            print('No articles returned from API, using fallback');
          }
          return getFallbackArticles();
        }
      } else {
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }
        throw Exception(
          'Failed to load articles. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching articles: $e');
      }
      return getFallbackArticles();
    }
  }

  // Helper method to calculate reading time
  static int _calculateReadTime(String title, String description) {
    // Average reading speed: ~200 words per minute
    // Calculate based on title and description length
    final wordCount = (title.split(' ').length + description.split(' ').length);
    final minutes = (wordCount / 200).ceil();
    // Ensure a minimum reading time
    return minutes < 1 ? 1 : (minutes > 10 ? 10 : minutes);
  }

  // Helper method to format the date
  static String _formatDate(DateTime date) {
    // Get today and yesterday for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final articleDate = DateTime(date.year, date.month, date.day);

    if (articleDate == today) {
      return 'Hari ini';
    } else if (articleDate == yesterday) {
      return 'Kemarin';
    } else {
      // Format date as day/month/year
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static List<Article> getFallbackArticles() {
    return [
      Article(
        title: 'Manfaat Minum Air Putih Cukup untuk Kesehatan Jantung',
        imageUrl:
            'https://akcdn.detik.net.id/community/media/visual/2022/07/26/ilustrasi-minum-air-putih-1_169.jpeg',
        category: 'Kesehatan Jantung',
        timeToRead: '3 menit baca',
        url:
            'https://health.detik.com/berita-detikhealth/d-6245633/4-manfaat-minum-air-putih-cukup-untuk-kesehatan-jantung',
        source: 'DetikHealth',
      ),
      Article(
        title: '5 Manfaat Olahraga Pagi yang Sayang untuk Dilewatkan',
        imageUrl:
            'https://akcdn.detik.net.id/community/media/visual/2022/03/11/ilustrasi-olahraga-pagi_169.jpeg',
        category: 'Olahraga',
        timeToRead: '5 menit baca',
        url:
            'https://health.detik.com/kebugaran/d-5941115/5-manfaat-olahraga-pagi-yang-sayang-untuk-dilewatkan',
        source: 'DetikHealth',
      ),
      Article(
        title:
            'Cegah Penyakit Jantung, Ini 7 Makanan yang Baik untuk Kesehatan Jantung',
        imageUrl:
            'https://akcdn.detik.net.id/community/media/visual/2023/01/24/ilustrasi-kacang-pistachio_169.jpeg',
        category: 'Nutrisi',
        timeToRead: '4 menit baca',
        url:
            'https://health.detik.com/berita-detikhealth/d-6532115/cegah-penyakit-jantung-ini-7-makanan-yang-baik-untuk-kesehatan-jantung',
        source: 'DetikHealth',
      ),
    ];
  }
}
