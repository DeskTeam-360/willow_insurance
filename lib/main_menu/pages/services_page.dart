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

  Future<void> _openWebView(BuildContext context, String url, String title) async {
    await LogUtil.saveLog('Opening service $title');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: url, title: title),
      ),
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
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
              color: Color(0xFF71A33F)
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
           SizedBox(height: 15),
           Text(
             'We simplify insurance',
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
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF71A33F)),
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
              padding: EdgeInsets.all(16.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final hasFeaturedImage =
                    service.featuredImage != null &&
                    service.featuredImage != false &&
                    service.featuredImage.toString().isNotEmpty;
                final featuredImageStr = hasFeaturedImage
                    ? service.featuredImage.toString()
                    : '';
                final isNetworkImage = hasFeaturedImage &&
                    featuredImageStr.startsWith('http');

                return Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  elevation: 1,
                  color: Color(0xFFffffff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: InkWell(
                    onTap: () => _openWebView(
                      context,
                      service.link,
                      service.title,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                // height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: hasFeaturedImage
                                    ? (isNetworkImage
                                        ? Image.network(
                                            featuredImageStr,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF71A33F)),
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            featuredImageStr,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              );
                                            },
                                          ))
                                    : Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  
                                  ],
                                )
                              ),
                              
                            
                            ],
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 40.0, bottom: 0.0),
                            child: 
                          Html(
                                      data: service.shortDescription,
                                      style: {
                                        "body": Style(
                                          fontSize: FontSize(14),
                                          // color: Colors.grey[600],
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "p": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "ul": Style(
                                          margin: Margins.only(left: 15.0),
                                          padding: HtmlPaddings.zero,
                                        ),
                                        "li": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                        ),
                                      },
                                    ),
                          ),

                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Empty tap handler
                              },
                              child: Container(
                                width: 80,
                                height: 35,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDFFEB9),
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
                                        style: TextStyle(color: Color(0xFF497844), fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      Expanded(child: SizedBox(width: 5)),
                                      SvgPicture.asset(
                                        'assets/images/arrow.svg',
                                        width: 12,
                                        height: 12,
                                        colorFilter: ColorFilter.mode(
                                          Color(0xFF497844),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
