import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const ArticleWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends State<ArticleWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  static const String _customUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();

    // Make sure the URL has a proper scheme
    String url = widget.url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    if (kDebugMode) {
      print("Loading WebView with URL: $url");
    }

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(_customUserAgent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                if (kDebugMode) {
                  print("WebView page started loading: $url");
                }
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                if (kDebugMode) {
                  print("WebView page finished loading: $url");
                }
                setState(() {
                  isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                if (kDebugMode) {
                  print(
                    "WebView error (\u001b[31m[0m${error.errorCode}): ${error.description} "
                    "URL: ${error.url} "
                    "isForMainFrame: ${error.isForMainFrame}",
                  );
                }
                // Only show error for main frame
                if (error.isForMainFrame ?? false) {
                  _handleError(error);
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(url));

    // Enable cookies using WebViewCookieManager
    final cookieManager = WebViewCookieManager();
    cookieManager.setCookie(
      WebViewCookie(
        name: 'accept_cookies',
        value: 'true',
        domain: Uri.parse(url).host,
      ),
    );
  }

  void _handleError(WebResourceError error) {
    String message;
    switch (error.errorCode) {
      case -2: // net::ERR_INTERNET_DISCONNECTED
        message = 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.';
        break;
      case -6: // net::ERR_CONNECTION_REFUSED
        message =
            'Artikel tidak dapat diakses. Server artikel mungkin sedang bermasalah.';
        break;
      case -8: // net::ERR_CONNECTION_TIMED_OUT
        message = 'Koneksi timeout. Silakan coba lagi nanti.';
        break;
      case -10: // net::ERR_ACCESS_DENIED
        message = 'Akses ke artikel ditolak. Coba buka di browser.';
        break;
      case -118: // net::ERR_CONNECTION_TIMED_OUT (iOS)
        message = 'Koneksi timeout. Silakan coba lagi nanti.';
        break;
      default:
        message =
            'Terjadi kesalahan saat memuat artikel. Situs ini mungkin membatasi akses dari aplikasi. Coba buka di browser.';
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = message;
      });
    }
  }

  Future<void> _openInBrowser(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) {
        print('Error launching URL in browser: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka di browser')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF05606B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                hasError = false;
                isLoading = true;
              });
              controller.reload();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _openInBrowser(widget.url),
            tooltip: 'Buka di browser',
          ),
        ],
      ),
      body: SafeArea(
        child:
            hasError
                ? _buildErrorView()
                : Stack(
                  children: [
                    WebViewWidget(controller: controller),
                    if (isLoading)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF05606B),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat artikel...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 24),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  isLoading = true;
                });
                controller.reload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05606B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _openInBrowser(widget.url),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF05606B),
              ),
              child: const Text('Buka di Browser'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
