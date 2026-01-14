import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'about_us_page.dart';
import 'video_page.dart';
import 'note_page.dart';
import 'reminders_page.dart';

class ImportantListPage extends StatelessWidget {
  ImportantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
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
                Positioned(
                  bottom: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text("Willow App Version 1.0.0", style: TextStyle(color: Color(0xFF497844), fontSize: 14, fontWeight: FontWeight.w500),)
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/willow_logo.png',
                        width: 150,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 60),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important list',
                            style: TextStyle(
                              color: Color(0xFF497844),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            color: Color(0xFFE3E3E3),
                            thickness: 1,
                            height: 25,
                          ),

                          // About us link
                          _buildLinkItem(
                            context,
                            title: 'About us',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutUsPage(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          // Notes link
                          _buildLinkItem(
                            context,
                            title: 'Notes',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotePage(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          // Video Guides link
                          _buildLinkItem(
                            context,
                            title: 'Video Guides',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPage(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          // Reminders link
                          _buildLinkItem(
                            context,
                            title: 'Reminders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RemindersPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    // Version text
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Color(0xFF497844),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required String title,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Color(0xFF3E3E3E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFFDFFEB9),
                // hijau lebih gelap
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.north_east,
                  color: Color(0xFF497844),
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
