import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notifications_page.dart';
import 'resources_page.dart';
import 'about_us_page.dart';
import 'video_page.dart';
import 'contact_page.dart';
import '../../services/notification_database.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onPageChange;

  HomePage({this.onPageChange});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> carouselItems = [
    
    {
      'title': 'Resources',
      'iconPath': 'assets/images/main_menu_carousel/resource_icon.svg',
      'color': Color(0xFF6DA544),
      'page': ResourcesPage(),
      'mainmenuindex': 2,
    },
  
    {
      'title': 'About Us',
      'iconPath': 'assets/images/main_menu_carousel/about_us_icon2.svg',
      'color': Color(0xFF6DA544),
      'page': AboutUsPage(),
      'mainmenuindex': -1,
    },
  ];

  int currentIndex = 0;
  int countNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notificationDb = NotificationDatabase();
      final count = await notificationDb.getUnreadCount();
      if (mounted) {
        setState(() {
          countNotifications = count;
        });
      }
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String iconPath,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      color: Color(0xFFffffff),
      // width: MediaQuery.of(context).size.width - 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child:
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        
          child: Stack(
            children: [
              Container(
                width: 60,
                height: 100,
                decoration: BoxDecoration(
                  color: title == 'Services' || title == 'Resources' ? Color(0xFF6DA544) : Color(0xFFB0D766),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), bottomLeft: Radius.circular(16.0)),
                ),
              ),
              // Left: Icon container
              Positioned(
                top: 20,
                left: 20,
                child:
                
                Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  // color: Color(0xFFDFFEB9),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Image.asset(iconPath, width: 30, height: 30),
              ), 
                ),
              // Center: Title and subtitle
              Positioned(
                // top: 20,
                left: 90,
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF497844))),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ],
                ),
              ),
              // Right: Open button
              Positioned(
                top: 10,
                right: 10,
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
              )
            ],
          ),
        ),
      ) 
    
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Header with notification icon (fixed position)
          
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 160,
                        child: SvgPicture.asset(
                          'assets/images/willow_home_illustration.svg',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 70,
                      child: Text(
                        'Hello !!',
                        style: TextStyle(
                          color: Color(0xFF497844),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Carousel Slider
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                SizedBox(height: 20),
                // GestureDetector(
                //   onTap: () {
                //     if (widget.onPageChange != null) {
                //       widget.onPageChange!(1); // Services tab index is 1
                //     }
                //   },
                //   child: Material(
                //     elevation: 2,
                //     borderRadius: BorderRadius.circular(20),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(20),
                //           child: Container(
                //             width: MediaQuery.of(context).size.width,
                //             height: 120,
                //             decoration: BoxDecoration(
                //               color: Color(0xFF6DA544),
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //           ),
                          
                //         ),
                //       // Services Logo/Icon - Left side
                //       Positioned(
                //         bottom: 35,
                //         left: 20,
                //         child: SvgPicture.asset(
                //           'assets/images/main_menu_carousel/my_sgi_g2.svg',
                //           width: 40,
                //           height: 40,
                //           colorFilter: ColorFilter.mode(
                //             Colors.white.withOpacity(0.9),
                //             BlendMode.srcIn,
                //           ),
                //         ),
                //       ),
                      
                //       // Title - Right side of logo, aligned with logo
                      
                //       // Description - Below title
                //       Positioned(
                        
                //         left: 85,
                //         right: 30,
                //         bottom: 35,
                //         child: 
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //           'Services',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 20,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         Text(
                //           'Access Online Services',
                //           style: TextStyle(color: Colors.white, fontSize: 12),
                //         ),
                //         ],
                //       ),
                //       ),

                //       Positioned(
                //         top: 10,
                //         right: 10,
                //         child: Container(
                //           width: 80,
                //           height: 35,
                //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //           decoration: BoxDecoration(
                //             color: Color(0xFFDFFEB9), // hijau lebih gelap
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Center(
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,

                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               mainAxisSize: MainAxisSize.min,
                //             children: [
                //               Text(
                //                 'Open',
                //                 style: TextStyle(color: Color(0xFF497844), fontSize: 14, fontWeight: FontWeight.w600),
                //               ),
                //               Expanded(child: SizedBox(width: 5)),
                //               SvgPicture.asset(
                //                 'assets/images/arrow.svg',
                //                 width: 12,
                //                 height: 12,
                //                 colorFilter: ColorFilter.mode(
                //                   Color(0xFF497844),
                //                   BlendMode.srcIn,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           )
                //         ),
                //       ),
                //       ],
                //     ),
                //   ),
                // ),

                // SizedBox(height: 20),
                // GestureDetector(
                //   onTap: () {
                //     // Set the tab index to open Book Appointment tab (index 1)
                //     ContactPage.setInitialTab(1);
                //     // Navigate to ContactPage using onPageChange to keep navbar visible
                //     if (widget.onPageChange != null) {
                //       widget.onPageChange!(3); // ContactPage is at index 3
                //     }
                //   },
                //   child: Material(
                //     elevation: 2,
                //     borderRadius: BorderRadius.circular(20),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(20),
                //           child: Image.asset(
                //             'assets/images/willow_booking.png',
                //             width: MediaQuery.of(context).size.width,
                //             fit: BoxFit.fitWidth,
                //           ),
                //         ),
                //       Image.asset(
                //         'assets/images/willow_home_illustration2.png',
                //         width: MediaQuery.of(context).size.width,
                //         fit: BoxFit.fitWidth,
                //       ),
                //       Positioned(
                //         bottom: 20,
                //         left: 20,
                //         child: Text(
                //           'Book an Appointment',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 20,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                    
                //      Positioned(
                //         top: 10,
                //         right: 10,
                //         child: Container(
                //           width: 80,
                //           height: 35,
                //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //           decoration: BoxDecoration(
                //             color: Color(0xFF4E7A3C), // hijau lebih gelap
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Center(
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,

                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               mainAxisSize: MainAxisSize.min,
                //             children: [
                //               Text(
                //                 'Open',
                //                 style: TextStyle(color: Color(0xFFDFFEB9), fontSize: 14, fontWeight: FontWeight.w600),
                //               ),
                //               Expanded(child: SizedBox(width: 5)),
                //               SvgPicture.asset(
                //                 'assets/images/arrow.svg',
                //                 width: 12,
                //                 height: 12,
                //                 colorFilter: ColorFilter.mode(
                //                   Color(0xFFDFFEB9),
                //                   BlendMode.srcIn,
                //                 ),
                //               ),
                //             ],
                //           ),
                //           )
                //         ),
                //       ),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20),
                // CarouselSlider(
                //   options: CarouselOptions(
                //     height: MediaQuery.of(context).size.width * 0.4,
                //     // autoPlay: true,
                //     // autoPlayInterval: Duration(seconds: 3),
                //     // autoPlayAnimationDuration: Duration(milliseconds: 800),
                //     autoPlayCurve: Curves.fastOutSlowIn,
                //     enlargeCenterPage: true,
                //     viewportFraction: 0.5,
                //     aspectRatio: 1.0,
                //     padEnds: false,
                //     onPageChanged: (index, reason) {
                //       setState(() {
                //         currentIndex = index;
                //       });
                //       print('Page changed: $index');
                //     },
                //   ),
                //   items: carouselItems.map((item) {
                //     return Builder(
                //       builder: (BuildContext context) {
                //         final int index = carouselItems.indexOf(item);
                //         final String title = item['title'] as String;
                //         final String iconPath = item['iconPath'] as String;
                //         return GestureDetector(
                //           onTap: () {
                //             final int? mainMenuIndex =
                //                 item['mainmenuindex'] as int?;
                //             final Widget? page = item['page'] as Widget?;
                //             if (mainMenuIndex == -1) {
                //               Navigator.push(
                //                 context,
                //                 MaterialPageRoute(builder: (context) => AboutUsPage()),
                //               );
                //               return;
                //             }
                //             // Navigate to Book Appointment page directly
                //             if (page is BookAppointmentPage) {
                //               Navigator.push(
                //                 context,
                //                 MaterialPageRoute(builder: (context) => page),
                //               );
                //             } else if (mainMenuIndex != null &&
                //                 widget.onPageChange != null) {
                //               widget.onPageChange!(mainMenuIndex);
                //             }
                //           },
                //           child: Stack(
                //             key: ValueKey(item['page']),
                //             clipBehavior: Clip.none,
                //             children: [
                //               // Container utama dengan lubang di pojok kanan atas
                //               ClipPath(
                //                 clipper: NotchClipper(),
                //                 child: Container(
                //                   width: MediaQuery.of(context).size.width,
                //                   margin: EdgeInsets.symmetric(horizontal: 5.0),
                //                   padding: EdgeInsets.only(
                //                     left: 15.0,
                //                     bottom: 15.0,
                //                   ),
                //                   decoration: BoxDecoration(
                //                     color: currentIndex == index
                //                         ? Color(0xFF6DA544)
                //                         : Color(0xFFffffff),
                //                     borderRadius: BorderRadius.circular(20),
                //                   ),
                //                   child: Column(
                //                     mainAxisAlignment: MainAxisAlignment.end,
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       SvgPicture.asset(
                //                         iconPath,
                //                         width: 60,
                //                         height: 60,
                //                         colorFilter: ColorFilter.mode(
                //                           currentIndex == index
                //                               ? Colors.white
                //                               : Color(0xFF6DA544),
                //                           BlendMode.srcIn,
                //                         ),
                //                       ),
                //                       SizedBox(height: 12),
                //                       Text(
                //                         title,
                //                         style: TextStyle(
                //                           color: currentIndex == index
                //                               ? Colors.white
                //                               : Color(0xFF6DA544),
                //                           fontSize: 20,
                //                           fontWeight: FontWeight.bold,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               // Kotak kecil di pojok kanan atas (terlihat menembus)
                //               Positioned(
                //                 top: 0,
                //                 right: 0,
                //                 child: Container(
                //                   width: 40,
                //                   height: 40,
                //                   decoration: BoxDecoration(
                //                     color: currentIndex == index
                //                         ? Color(0xFF4E7A3C)
                //                         : Color(
                //                             0xFFDFFEB9,
                //                           ), // hijau lebih gelap
                //                     borderRadius: BorderRadius.circular(10),
                //                   ),
                //                   child: Center(
                //                     child: SvgPicture.asset(
                //                       'assets/images/arrow.svg',
                //                       width: 20,
                //                       height: 20,
                //                       colorFilter: ColorFilter.mode(
                //                         currentIndex == index
                //                             ? Color(0xFFDFFEB9)
                //                             : Color(0xFF4E7A3C),
                //                         BlendMode.srcIn,
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         );
                //       },
                //     );
                //   }).toList(),
                //   carouselController: CarouselSliderController(),
                // ),
                // SizedBox(height: 20),
                
                // Menu Cards List
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                //   child:
                   Column(
                    children: [
                      // Services Card
                      _buildMenuCard(
                        context: context,
                        iconPath: 'assets/images/icon_home_services3.png',
                        title: 'Services',
                        subtitle: 'Access Online Services',
                        onTap: () {
                          if (widget.onPageChange != null) {
                            widget.onPageChange!(1); // Services tab index is 1
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      // Resources Card
                      _buildMenuCard(
                        context: context,
                        iconPath: 'assets/images/icon_home_resources.png',
                        title: 'Resources',
                        subtitle: null,
                        onTap: () {
                          if (widget.onPageChange != null) {
                            widget.onPageChange!(2); // Resources tab index is 2
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      // Book an Appointment Card
                      _buildMenuCard(
                        context: context,
                        iconPath: 'assets/images/icon_home_book.png',
                        title: 'Book an Appointment',
                        subtitle: null,
                        onTap: () {
                          ContactPage.setInitialTab(1);
                          if (widget.onPageChange != null) {
                            widget.onPageChange!(3); // ContactPage is at index 3
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      // Video Guides Card
                      _buildMenuCard(
                        context: context,
                        iconPath: 'assets/images/icon_home_video.png',
                        title: 'Video Guides',
                        subtitle: 'Our simple, easy-to-follow videos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VideoPage()),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      // About Us Card
                      _buildMenuCard(
                        context: context,
                        iconPath: 'assets/images/icon_home_about.png',
                        title: 'About Us',
                        subtitle: null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AboutUsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                // ),
                
                // SizedBox(height: 20),
                
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => VideoPage()),
                //     );
                //   },
                //   child: Material(
                //     elevation: 2,
                //     borderRadius: BorderRadius.circular(20),
                //     child: Stack(
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(20),
                //           child: Image.asset(
                //             'assets/images/willow_farm.png',
                //             width: MediaQuery.of(context).size.width,
                //             fit: BoxFit.fitWidth,
                //           ),
                //         ),
                //         Image.asset(
                //           'assets/images/willow_home_illustration2.png',
                //           width: MediaQuery.of(context).size.width,
                //           fit: BoxFit.fitWidth,
                //         ),
                //         Positioned(
                //           bottom: 20,
                //           left: 20,
                //           child: Text(
                //             'Video Guides',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 20,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ),
                //         Positioned(
                //           bottom: 8,
                //           left: 20,
                //           child: Text(
                //             'Our simple, easy-to-follow videos',
                //             style: TextStyle(color: Colors.white, fontSize: 12),
                //           ),
                //         ),

                //         Positioned(
                //           top: 10,
                //           right: 10,
                //           child: Container(
                //             width: 80,
                //             height: 35,
                //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //             decoration: BoxDecoration(
                //               color: Color(0xFF4E7A3C), // hijau lebih gelap
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //             child: Center(
                //               child: Row(
                //                 mainAxisAlignment: MainAxisAlignment.center,

                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Text(
                //                   'Open',
                //                   style: TextStyle(color: Color(0xFFDFFEB9), fontSize: 14, fontWeight: FontWeight.w600),
                //                 ),
                //                 Expanded(child: SizedBox(width: 1)),
                //                 SvgPicture.asset(
                //                   'assets/images/arrow.svg',
                //                   width: 12,
                //                   height: 12,
                //                   colorFilter: ColorFilter.mode(
                //                     Color(0xFFDFFEB9),
                //                     BlendMode.srcIn,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //             )
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                
                // Description Card
                Card(
                    elevation: 1,
                    color: Color(0xFFffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How well do you really understand your insurance coverage or the coverage options available to you?',
                            style: TextStyle(
                              color: Color(0xFF497844),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'It can be devastating to suffer a loss — and even more so if you thought you had coverage but don\'t for that situation. At Willow Insurance, we simplify insurance by making sure your coverage matches your expectations. As an award-winning brokerage, we\'re committed to helping you understand your policies while giving you easy access through our mobile app.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 20),
                SizedBox(height: 70),
              ],
            ),
          ),
        ],
      ),
    ),
    Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(),
                  ),
                );
                // Reload notification count when returning from notifications page
                _loadNotificationCount();
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    countNotifications > 0
                        ? Icons.notifications
                        : Icons.notifications_none,
                    color: Color(0xFF497844),
                    size: 30,
                  ),
                  if (countNotifications > 0)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFDFFEB9),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double notchSize = 50;
    double borderRadius = 20;
    double notchRadius = 15;

    Path path = Path();

    // Kiri atas
    path.moveTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    // Menuju notch
    double notchStartX = size.width - notchSize;
    path.lineTo(notchStartX - notchRadius, 0);

    // Masuk notch (atas kiri)
    path.quadraticBezierTo(
      notchStartX - notchRadius * 0.1,
      0,
      notchStartX,
      notchRadius,
    );

    // Turun (kiri notch)
    path.lineTo(notchStartX, notchSize - notchRadius);

    // Bawah kiri notch
    path.quadraticBezierTo(
      notchStartX,
      notchSize,
      notchStartX + notchRadius,
      notchSize,
    );

    // Bawah notch → kanan
    path.lineTo(size.width - notchRadius, notchSize);

    // Bawah kanan notch → radius kecil → langsung masuk sisi kanan
    path.quadraticBezierTo(
      size.width,
      notchSize,
      size.width,
      notchSize + notchRadius * 3, // radius sedikit ke bawah, bukan ke atas
    );

    // Turun ke kanan bawah
    path.lineTo(size.width, size.height - borderRadius);

    // ⭐ Radius kanan bawah (lebih benar dari versi kamu)
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );

    // Kiri bawah
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Go to top-right
    path.lineTo(size.width, 0);

    // Go to bottom-right
    path.lineTo(size.width, size.height - 30);

    // Create wave pattern at the bottom (from right to left)
    double waveHeight = 50;
    double waveLength = size.width / 2;
    double baseY = size.height - 30;
    // Second wave
    path.quadraticBezierTo(
      size.width - waveLength * 1.5,
      baseY + waveHeight,
      size.width - waveLength * 2,
      baseY,
    );
    // First wave (going left from right edge)
    path.quadraticBezierTo(
      size.width - waveLength * 0.5,
      baseY - waveHeight,
      size.width - waveLength,
      baseY,
    );

    // Complete the path to bottom-left
    path.lineTo(0, baseY);

    // Close the path back to top-left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
