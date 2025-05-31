import 'dart:math'; // For Math.min if you prefer, or use ternary for substring

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
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
  static Future<List<Article>> fetchHealthArticles() async {
    try {
      // Try to fetch articles from DetikHealth first
      final articles = await fetchArticlesFromDetikHealth();

      // If we got articles, return them
      if (articles.isNotEmpty) {
        if (kDebugMode) {
          print(
              'Successfully fetched ${articles.length} articles from DetikHealth.');
        }
        return articles;
      } else {
        if (kDebugMode) {
          print(
              'No articles returned from web scraping DetikHealth, using fallback.');
        }
        return getFallbackArticles();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching health articles: $e. Using fallback.');
      }
      return getFallbackArticles();
    }
  }

  static List<Article> getFallbackArticles() {
    // Fallback articles remain the same, you can update their publishedAt for variety
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
        publishedAt: 'Kemarin',
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
        publishedAt: '2 hari lalu',
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
        publishedAt: 'Minggu lalu',
      ),
    ];
  }

  // Helper to ensure URLs are absolute
  static String _sanitizeUrl(String url, String baseUrl) {
    if (url.isEmpty) return '';
    Uri parsedUri = Uri.parse(url);
    if (parsedUri.isAbsolute) {
      return url;
    }
    // Handles cases like //cdn.example.com/image.jpg
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    // Handles cases like /path/to/article
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    // Fallback for other relative paths, assuming they relate to the baseUrl
    return '$baseUrl/$url';
  }

  static Future<List<Article>> fetchArticlesFromDetikHealth() async {
    final List<Article> articles = [];
    const String detikHealthBaseUrl = 'https://health.detik.com';
    const String defaultImageUrl = 'https://via.placeholder.com/150/CCCCCC/FFFFFF?Text=No+Image'; // Default image

    try {
      if (kDebugMode) {
        print('Fetching articles from DetikHealth: $detikHealthBaseUrl');
      }

      final response = await http.get(Uri.parse(detikHealthBaseUrl));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        // !!! CRUCIAL STEP: VERIFY AND UPDATE THESE SELECTORS !!!
        // Use your browser's developer tools to inspect health.detik.com
        // and find the correct selectors for article containers.
        // The original selectors were: 'article.list-content__item, .media__article, .grid-row article'
        // Below are some common patterns, but they WILL LIKELY NEED ADJUSTMENT.
        final articleElements = document.querySelectorAll(
          // Try to be specific. Examples:
          'article.list-content__item', // A common pattern
          // 'div.berita-listing article', // If articles are nested
          // '.media_rows > article', // Another possible structure
          // If the above don't work, broaden your search and then narrow down:
          // 'article' // This might get too many unrelated things
        ); // TODO: REPLACE WITH ACCURATE SELECTOR(S)

        if (kDebugMode) {
          print(
              'Found ${articleElements.length} potential article elements from DetikHealth.');
          if (articleElements.isEmpty) {
            print(
                'No article elements found with the current selectors. The HTML structure of DetikHealth might have changed.');
            // For debugging, you can print a part of the HTML:
            // print('HTML Body Snippet: ${response.body.substring(0, min(response.body.length, 2000))}...');
          }
        }

        int successfullyParsedArticles = 0;
        for (var articleElement in articleElements) {
          if (successfullyParsedArticles >= 10) {
            break; // Limit to 10 successfully parsed articles
          }

          try {
            // !!! VERIFY AND UPDATE INNER SELECTORS !!!
            // Selector for Title and URL (usually an <a> tag inside a heading)
            // Original: 'h2.media__title a, .title a, h3 a'
            final titleElement = articleElement.querySelector(
              'h2.media__title a, h3.media__title a, .media__title a, .title a, h2 a, h3 a', // TODO: ADJUST
            );

            // Selector for Image (<img> tag, check 'src' or 'data-src')
            // Original: 'img'
            final imageElement = articleElement.querySelector(
              'img.media__image, .media__image img, figure img, img', // TODO: ADJUST
            );

            // Selector for Category
            // Original: '.media__category, .category'
            final categoryElement = articleElement.querySelector(
              '.media__category, .category, .label, .post-category', // TODO: ADJUST
            );

            if (titleElement != null) {
              String title = titleElement.text.trim();
              String articleUrl = titleElement.attributes['href'] ?? '';

              if (title.isEmpty || articleUrl.isEmpty) {
                if (kDebugMode) {
                  // print('Skipping article due to empty title or URL. Title Element HTML: ${titleElement.outerHtml}');
                }
                continue; // Skip if essential info is missing
              }
              articleUrl = _sanitizeUrl(articleUrl, detikHealthBaseUrl);

              String imageUrl = imageElement?.attributes['data-src'] ?? // Prioritize data-src for lazy loading
                                imageElement?.attributes['src'] ??
                                '';
              imageUrl = _sanitizeUrl(imageUrl, detikHealthBaseUrl);
              if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.isAbsolute) {
                imageUrl = defaultImageUrl; // Fallback if image is not found or invalid
              }


              String category = categoryElement?.text.trim() ?? 'Kesehatan';
              if (category.isEmpty) category = 'Kesehatan';


              // --- Placeholder for actual scraped data (if available) ---
              // To scrape publishedAt:
              // final dateElement = articleElement.querySelector('time, .date, .timestamp');
              // String publishedAt = dateElement?.text.trim() ?? _formatPublishedDate(dateElement?.attributes['datetime']);
              String publishedAt =
                  'Hari Ini'; // Placeholder - scraping dates can be complex

              // To scrape or calculate timeToRead:
              // This is rarely available directly. Your simulation is a good approach.
              // String articleBodyText = articleElement.querySelector('.article__body')?.text ?? title; // Need to get full article text if possible
              // String timeToRead = _calculateReadingTime(articleBodyText);
              String timeToRead =
                  '${2 + (title.length % 4) + 1} menit baca'; // Simulated: 2-5 mins
              // --- End Placeholder ---

              articles.add(
                Article(
                  title: title,
                  imageUrl: imageUrl,
                  category: category,
                  url: articleUrl,
                  timeToRead: timeToRead,
                  source: 'DetikHealth',
                  publishedAt: publishedAt,
                ),
              );
              successfullyParsedArticles++;
            } else {
              if (kDebugMode) {
                // String snippet = articleElement.outerHtml;
                // print('Could not find title element in article snippet: ${snippet.substring(0, min(snippet.length, 300))}...');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              String snippet = articleElement.outerHtml;
              print(
                  'Error parsing an individual DetikHealth article: $e. Snippet: ${snippet.substring(0, min(snippet.length, 300))}...');
            }
            continue; // Skip this article and proceed to the next
          }
        }

        if (kDebugMode && articles.isEmpty && articleElements.isNotEmpty) {
          print(
              'Found article elements but failed to parse any into Article objects. Double-check your inner selectors (title, image, category) for each article item.');
        }
        return articles;
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch from DetikHealth. Status code: ${response.statusCode}');
        }
        return []; // Return empty list on non-200 response
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception during fetchArticlesFromDetikHealth: $e');
      }
      return []; // Return empty list on exception
    }
  }

  // Example: Helper method to calculate reading time (if you can get article content)
  // static String _calculateReadingTime(String text) {
  //   if (text.isEmpty) return '3 menit baca';
  //   final wordCount = text.split(RegExp(r'\s+')).length;
  //   final readingTimeMinutes = (wordCount / 200).ceil(); // Average reading speed: 200 WPM
  //   return '$readingTimeMinutes menit baca';
  // }

  // Example: Helper method to format a scraped date (very site-specific)
  // static String _formatPublishedDate(String? rawDate) {
  //   if (rawDate == null || rawDate.isEmpty) return 'Hari Ini';
  //   try {
  //     // TODO: Implement actual date parsing based on DetikHealth's format
  //     // For example, if it's an ISO string: DateTime.parse(rawDate).toLocal().toString()
  //     // Or use intl package for more complex formatting.
  //     return rawDate; // Placeholder
  //   } catch (e) {
  //     return 'Baru saja'; // Fallback for parsing errors
  //   }
  // }
}