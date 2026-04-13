import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  // --- Service card: ukuran logo (ubah di sini) ---
  /// Tinggi maksimum area logo. **Naikkan nilai ini** agar logo terlihat lebih besar;
  /// tinggi kartu ikut menyesuaikan otomatis.
  static const double _kServiceLogoMaxHeight = 48.0;

  static const double _kServiceCardVPad = 10.0;
  static const double _kServiceCardBtnSize = 36.0;
  static const double _kServiceCardIconSize = 15.0;
  static const double _kServiceCardFallbackIconSize = 28.0;

  /// Tinggi kartu = padding atas/bawah + max(logo, tombol panah).
  static double get _kServiceCardHeight =>
      2 * _kServiceCardVPad +
      (_kServiceLogoMaxHeight > _kServiceCardBtnSize
          ? _kServiceLogoMaxHeight
          : _kServiceCardBtnSize);

  bool _isLoading = false;
  List<String> _groupOrder = [];
  Map<String, List<MobileService>> _groupedServices = {};

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
    if (data == null) return;

    final sorted = List<MobileService>.from(data.mobileService);
    sorted.sort((a, b) => a.order.compareTo(b.order));

    final groupOrder = <String>[];
    final grouped = <String, List<MobileService>>{};

    for (final s in sorted) {
      final key = s.groupType.trim();
      if (!grouped.containsKey(key)) {
        groupOrder.add(key);
        grouped[key] = [];
      }
      grouped[key]!.add(s);
    }

    if (mounted) {
      setState(() {
        _groupOrder = groupOrder;
        _groupedServices = grouped;
      });
    }
  }

  int get _totalServiceCount =>
      _groupedServices.values.fold(0, (sum, list) => sum + list.length);

  /// API `group_layout` overrides; otherwise names like "Health Insurance" → 2 columns.
  ServiceGroupLayout _layoutForGroup(String groupKey, List<MobileService> items) {
    for (final s in items) {
      final raw = s.groupLayout
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
      if (raw == 'two_column' ||
          raw == 'twocolumn' ||
          raw == 'grid' ||
          raw == '2col' ||
          raw == 'columns_2') {
        return ServiceGroupLayout.twoColumn;
      }
      if (raw == 'full_width' ||
          raw == 'fullwidth' ||
          raw == 'stack' ||
          raw == 'full') {
        return ServiceGroupLayout.fullWidth;
      }
    }
    final g = groupKey.toLowerCase();
    if (g.contains('health') || g.contains('travel')) {
      return ServiceGroupLayout.twoColumn;
    }
    return ServiceGroupLayout.fullWidth;
  }

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
    LogUtil.saveLog('Opening service $title').catchError((_) {});
  }

  Widget _buildGroupHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.fromLTRB(32, 11, 14, 11),
          decoration: BoxDecoration(
            color: Color(0xFF71A33F),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    MobileService service, {
    required bool compact,
  }) {
    final hasFeaturedImage = service.featuredImage != null &&
        service.featuredImage != false &&
        service.featuredImage.toString().isNotEmpty;
    final featuredImageStr =
        hasFeaturedImage ? service.featuredImage.toString() : '';
    final isNetworkImage =
        hasFeaturedImage && featuredImageStr.startsWith('http');

    final hPad = compact ? 10.0 : 16.0;

    return SizedBox(
      height: _kServiceCardHeight,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: compact ? 0.8 : 1.2,
        shadowColor: Colors.black26,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _openWebView(context, service.link, service.title),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: _kServiceCardVPad,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: _kServiceLogoMaxHeight,
                        minHeight: 24,
                      ),
                      child: hasFeaturedImage
                        ? (isNetworkImage
                            ? Image.network(
                                featuredImageStr,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF71A33F)),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: _kServiceCardFallbackIconSize,
                                ),
                              )
                            : Image.asset(
                                featuredImageStr,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: _kServiceCardFallbackIconSize,
                                ),
                              ))
                        : Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: _kServiceCardFallbackIconSize,
                          ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 8 : 12),
              GestureDetector(
                onTap: () =>
                    _openWebView(context, service.link, service.title),
                child: Container(
                  width: _kServiceCardBtnSize,
                  height: _kServiceCardBtnSize,
                  decoration: BoxDecoration(
                    color: Color(0xFFDFFEB9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/arrow.svg',
                      width: _kServiceCardIconSize,
                      height: _kServiceCardIconSize,
                      colorFilter: ColorFilter.mode(
                        Color(0xFF497844),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildFullWidthStack(List<MobileService> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: 10),
          _buildServiceCard(items[i], compact: false),
        ],
      ],
    );
  }

  Widget _buildTwoColumnGrid(List<MobileService> items) {
    const gap = 10.0;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      if (i + 1 < items.length) {
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildServiceCard(items[i], compact: true)),
                SizedBox(width: gap),
                Expanded(
                    child: _buildServiceCard(items[i + 1], compact: true)),
              ],
            ),
          ),
        );
      } else {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildServiceCard(items[i], compact: true)),
              SizedBox(width: gap),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
      }
      rows.add(SizedBox(height: gap));
    }
    if (rows.isNotEmpty) rows.removeLast();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _buildGroupSection(int index, String groupKey) {
    final items = _groupedServices[groupKey]!;
    final layout = _layoutForGroup(groupKey, items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (groupKey.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: index > 0 ? 14 : 0),
            child: _buildGroupHeader(groupKey),
          ),
        Padding(
          padding: EdgeInsets.only(left: 16,bottom: 10),
          child: layout == ServiceGroupLayout.twoColumn
              ? _buildTwoColumnGrid(items)
              : _buildFullWidthStack(items),
        ),
      ],
    );
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
