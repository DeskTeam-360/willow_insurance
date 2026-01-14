import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/home_page.dart';
import 'pages/services_page.dart';
import 'pages/resources_page.dart';
import 'pages/contact_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pages/important_list_page.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavLabel(String label, int index) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _selectedIndex == index ? Color(0xFFDFFEB9) : Colors.white70,
          fontSize: 10,
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Daftar halaman untuk setiap tab
  List<Widget> get _pages => [
    HomePage(onPageChange: _changePage),
    ServicesPage(),
    ResourcesPage(),
    ContactPage(),
    ImportantListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 0.0;
    final totalBottomPadding = bottomNavHeight + bottomPadding;
    
    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: totalBottomPadding),
        child: Stack(
          children: [
            _pages[_selectedIndex],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CurvedNavigationBar(
              backgroundColor: Colors.transparent,
              color: Color(0xFF497844),
              buttonBackgroundColor: Color(0xFF71A33F),
              items: <Widget>[
                Container(
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset('assets/images/main_menu_carousel/home.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFFDFFEB9), BlendMode.srcIn)),
                ),
                Container(
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset('assets/images/main_menu_carousel/services_icon3.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFFDFFEB9), BlendMode.srcIn)),
                ),
                Container(
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset('assets/images/main_menu_carousel/resource_icon.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFFDFFEB9), BlendMode.srcIn)),
                ),
                Container(
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset('assets/images/main_menu_carousel/contact.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFFDFFEB9), BlendMode.srcIn)),
                ),
                Container(
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset('assets/images/main_menu_carousel/important_list.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Color(0xFFDFFEB9), BlendMode.srcIn)),
                ),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              index: _selectedIndex,
              height: 45.0,
              animationDuration: Duration(milliseconds: 300),
              animationCurve: Curves.easeInOutCubic,
            ),
            Container(
              height: 20.0,
              color: Color(0xFF497844),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavLabel('Home', 0),
                  _buildNavLabel('Services', 1),
                  _buildNavLabel('Resources', 2),
                  _buildNavLabel('Contact', 3),
                  _buildNavLabel('Important', 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

