import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'webview_page.dart';
import '../../../services/data_service.dart';
import '../../../models/data_init_model.dart';
import '../../../utils/log_util.dart';

class ResourcesPage extends StatefulWidget {
  ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<Resource> get resources {
    final dataService = DataService();
    final data = dataService.cachedData;
    if (data != null) {
      // Sort by order
      final sortedResources = List<Resource>.from(data.resource);
      sortedResources.sort((a, b) => a.order.compareTo(b.order));
      return sortedResources;
    }
    return [];
  }


  Future<void> _launchURL(BuildContext context, String url, String title) async {
    // Validate URL
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid URL for $title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Opening resource $title');
    print('url: $trimmedUrl');
    
    // Navigate immediately without waiting for log
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: trimmedUrl, title: title),
      ),
    );
    // Log in background (fire and forget) - don't block navigation
    LogUtil.saveLog('Opening resource $title').catchError((e) {
      // Silently handle errors, logging should not affect user experience
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        children:[
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.35,
              child: SvgPicture.asset(
                'assets/images/willow_splashscreen.svg',
                width: MediaQuery.of(context).size.width * 2,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          
          Column(
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
                
                SizedBox(height: 15),

              ],
            ),
          ),
           SizedBox(height: 15),
           Text(
             'Useful Resources',
             style: TextStyle(
               fontSize: 24,
               fontWeight: FontWeight.bold,
               color: Color(0xFF497844),
             ),
           ),
          //  SizedBox(height: 15),
          Expanded(
            child: resources.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No resources available',
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
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      final hasFeaturedImage =
                          resource.featuredImage != null &&
                          resource.featuredImage != false &&
                          resource.featuredImage.toString().isNotEmpty;
                      final featuredImageStr = hasFeaturedImage
                          ? resource.featuredImage.toString()
                          : '';
                      final isNetworkImage =
                          hasFeaturedImage &&
                          featuredImageStr.startsWith('http');

                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        color: Color(0xFFffffff),
                        elevation: 1,
                        child: InkWell(
                          onTap: () => _launchURL(context, resource.link, resource.title),
                          borderRadius: BorderRadius.circular(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row pertama: icon, title, dan open button
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (hasFeaturedImage)
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              // topLeft: Radius.circular(16.0),
                                              // topRight: Radius.circular(16.0),
                                            ),
                                            child: isNetworkImage
                                                ? Image.network(
                                                    featuredImageStr,
                                                    height: 30,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            height: 40,
                                                            color: Color(
                                                              0xFF6DA544,
                                                            ),
                                                            child: Icon(
                                                              Icons.description,
                                                              color:
                                                                  Colors.white,
                                                              size: 50,
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Image.asset(
                                                    featuredImageStr,
                                                    height: 30,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            height: 40,
                                                            color: Color(
                                                              0xFF6DA544,
                                                            ),
                                                            child: Icon(
                                                              Icons.description,
                                                              color:
                                                                  Colors.white,
                                                              size: 50,
                                                            ),
                                                          );
                                                        },
                                                  ),
                                          ),

                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _launchURL(context, resource.link, resource.title),
                                            child: Text(
                                              resource.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF497844),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Container(
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
                                      ],
                                    ),
                                    // Row kedua: description
                                    if (resource.shortDescription.isNotEmpty) ...[
                                      SizedBox(height: 8.0),
                                      Html(
                                        data: resource.shortDescription,
                                        style: {
                                          "body": Style(
                                            fontSize: FontSize(14),
                                            color: Colors.grey[600],
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
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
        ]
      )
    );
  }
}
