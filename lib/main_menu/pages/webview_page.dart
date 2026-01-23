import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  Timer? _loadingTimeout;
  String? _errorMessage;
  String? _finalUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  bool _isFileUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // List of file extensions that should open in external browser
    final fileExtensions = [
      '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
      '.zip', '.rar', '.7z', '.tar', '.gz',
      '.mp3', '.mp4', '.avi', '.mov', '.wmv',
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff',
    ];
    return fileExtensions.any((ext) => lowerUrl.contains(ext));
  }

  Future<void> _openInExternalBrowser(String url) async {
    try {
      String finalUrl = url.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }
      
      final Uri uri = Uri.parse(finalUrl);
      
      // Try to launch directly (canLaunchUrl can be unreliable on emulators)
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          // Successfully opened in browser, close WebView
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }
      } catch (launchError) {
        print('[WebView] Failed to launch in external browser: $launchError');
        // Fall through to WebView fallback
      }
      
      // Fallback: Try to load in WebView instead
      print('[WebView] Falling back to WebView for file: $finalUrl');
      if (mounted) {
        _finalUrl = finalUrl;
        _loadUrlInWebView(finalUrl);
      }
    } catch (e) {
      print('[WebView] Error opening in browser: $e');
      // Last resort: try WebView
      if (mounted) {
        String finalUrl = url.trim();
        if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
          finalUrl = 'https://$finalUrl';
        }
        _finalUrl = finalUrl;
        _loadUrlInWebView(finalUrl);
      }
    }
  }

  void _loadUrlInWebView(String url) {
    try {
      final uri = Uri.parse(url);
      _controller.loadRequest(uri);
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } catch (e) {
      print('[WebView] Error loading in WebView: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load file. Please try opening in external browser.';
        });
      }
    }
  }

  void _initializeWebView() {
    try {
      // Validate and parse URL
      final url = widget.url.trim();
      if (url.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'URL is empty';
        });
        return;
      }

      // Ensure URL has protocol
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      _finalUrl = finalUrl;
      print('[WebView] Loading URL: $finalUrl');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('[WebView] Page started loading: $url');
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              // Set timeout for loading (30 seconds)
              _loadingTimeout?.cancel();
              _loadingTimeout = Timer(Duration(seconds: 30), () {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Loading timeout. Please check your connection.';
                  });
                }
              });
            },
            onPageFinished: (String url) {
              print('[WebView] Page finished loading: $url');
              _loadingTimeout?.cancel();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = null;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('[WebView] Error: ${error.errorCode} - ${error.description}');
              _loadingTimeout?.cancel();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to load page: ${error.description}';
                });
                if (error.errorCode != -3) { // Ignore ERR_BLOCKED_BY_ORB if it's just a warning
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading page: ${error.description}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              print('[WebView] Navigation request: ${request.url}');
              // Check if navigating to a file URL - try to open in external browser
              if (_isFileUrl(request.url)) {
                print('[WebView] Detected file in navigation, opening in external browser: ${request.url}');
                _openInExternalBrowser(request.url);
                return NavigationDecision.prevent;
              }
              // Allow all other navigation requests
              return NavigationDecision.navigate;
            },
          ),
        );

      // Check if URL is a file (PDF, DOC, etc.) - try to open in external browser first
      if (_isFileUrl(finalUrl)) {
        print('[WebView] Detected file URL, trying to open in external browser: $finalUrl');
        _openInExternalBrowser(finalUrl);
        // Don't return - let it fall through to WebView as fallback
      }

      // Load in WebView (either as primary or fallback)
      final uri = Uri.parse(finalUrl);
      _controller.loadRequest(uri);
    } catch (e) {
      print('[WebView] Exception initializing: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid URL: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 60, 30, 20),
            decoration: BoxDecoration(
              
              color: Color(0xFF71A33F),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/images/back_button.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      Color(0xFFffffff),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/willow_logo_white.png',
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final urlToOpen = _finalUrl ?? widget.url;
                    await _openInExternalBrowser(urlToOpen);
                  },
                  child: Icon(
                    Icons.open_in_browser,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_errorMessage != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _isLoading = true;
                              });
                              _initializeWebView();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF71A33F),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  WebViewWidget(controller: _controller),
                if (_isLoading && _errorMessage == null)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6DA544),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






