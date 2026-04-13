import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'webview_page.dart';
import '../../../services/data_service.dart';
import '../../../models/data_init_model.dart';
import '../../../utils/log_util.dart';

class ServicesPage extends StatefulWidget {
  ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool _isLoading = false;
  List<MobileService> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final dataService = DataService();

    // Check if data is already cached
    if (dataService.isDataLoaded) {
      _updateServices(dataService.cachedData);
    } else {
      // Show loading and fetch data
      setState(() {
        _isLoading = true;
      });

      try {
        final data = await dataService.fetchData();
        _updateServices(data);
      } catch (e) {
        print('Error loading services: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _updateServices(DataInit? data) {
    if (data != null) {
      final sortedServices = List<MobileService>.from(data.mobileService);
      sortedServices.sort((a, b) => a.order.compareTo(b.order));
      if (mounted) {
        setState(() {
          _services = sortedServices;
        });
      }
    }
  }

  List<MobileService> get services => _services;

  static const Color _defaultCardAccentGreen = Color(0xFF6DA544);
  static const Color _openButtonFill = Color(0xFFDFFEB9);
  static const Color _logoBorderGreen = Color(0xFF497844);
  static const double _cardRadius = 15.0;
  /// Sudut logo badge — lebih moderat dari kapsul penuh (Stadium).
  static const double _logoBadgeRadius = 15.0;

  Widget _buildLogoPill({
    required Widget logoChild,
    required double maxWidth,
  }) {
    final logoShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_logoBadgeRadius),
      side: BorderSide(color: _logoBorderGreen, width: 1),
    );
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: logoShape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 44),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical:5),
          child: Center(child: logoChild),
        ),
      ),
    );
  }

  Widget _buildOpenPillButton(BuildContext context, MobileService service) {
    const openGreen = Color(0xFF497844);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openWebView(context, service.link, service.title),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 80,
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _openButtonFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open',
                  style: TextStyle(
                    color: openGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(child: SizedBox(width: 5)),
                SvgPicture.asset(
                  'assets/images/arrow.svg',
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    openGreen,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, MobileService service) {
    final hasFeaturedImage = service.featuredImage != null &&
        service.featuredImage != false &&
        service.featuredImage.toString().isNotEmpty;
    final featuredImageStr =
        hasFeaturedImage ? service.featuredImage.toString() : '';
    final isNetworkImage =
        hasFeaturedImage && featuredImageStr.startsWith('http');

    final hasDescription = service.shortDescription.trim().isNotEmpty;
    final cardAccent = service.accentColor ?? _defaultCardAccentGreen;

    Widget logoChild;
    if (hasFeaturedImage) {
      if (isNetworkImage) {
        logoChild = Image.network(
          featuredImageStr,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.business,
            size: 28,
            color: _logoBorderGreen,
          ),
        );
      } else {
        logoChild = Image.asset(
          featuredImageStr,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.business,
            size: 28,
            color: _logoBorderGreen,
          ),
        );
      }
    } else {
      logoChild = Icon(
        Icons.apps,
        size: 28,
        color: _logoBorderGreen,
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _openWebView(context, service.link, service.title),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final greenW = (w * 0.17).clamp(52.0, 82.0);
                final logoMaxW = (w * 0.35).clamp(120.0, 220.0);
                final overlap = 40.0;

                return IntrinsicHeight(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: greenW,
                            color: cardAccent,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                10,
                                52,
                                12,
                                14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 10),
                                  if (hasDescription)
                                    Html(
                                      data: service.shortDescription,
                                      shrinkWrap: true,
                                      onLinkTap:
                                          (url, attributes, element) {
                                        if (url != null &&
                                            url.isNotEmpty) {
                                          _openWebView(
                                            context,
                                            url,
                                            service.title,
                                          );
                                        }
                                      },
                                      style: {
                                        "body": Style(
                                          fontSize: FontSize(16),
                                          color: Color(0xFF212121),
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "p": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "ul": Style(
                                          margin: Margins.only(
                                            left: 12.0,
                                          ),
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "li": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "a": Style(
                                          color: _logoBorderGreen,
                                        ),
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: greenW - overlap,
                        top: 12,
                        child: _buildLogoPill(
                          logoChild: logoChild,
                          maxWidth: logoMaxW,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildOpenPillButton(context, service),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWebView(
    BuildContext context,
    String url,
    String title,
  ) async {
    // Navigate immediately without waiting for log
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url, title: title),
      ),
    );
    // Log in background (fire and forget) - don't block navigation
    LogUtil.saveLog('Opening service $title').catchError((e) {
      // Silently handle errors, logging should not affect user experience
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              color: Color(0xFF71A33F),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30),
                Image.asset('assets/images/willow_logo_white.png', width: 150),
                // SizedBox(height: 5),
                // Text(
                //   'We Simplify Insurance',
                //   style: TextStyle(
                //     color: Color(0xFFffffff),
                //     fontSize: 14,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                SizedBox(height: 15),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'We Simplify Insurance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF497844),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/willow_logo.png',
                          width: 120,
                        ),
                        SizedBox(height: 30),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF71A33F),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading services...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : services.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(context, services[index]);
                    },
                  ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
