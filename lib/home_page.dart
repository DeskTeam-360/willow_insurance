import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main_menu/main_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start fade in animation
    _fadeController.forward();

    // Navigasi ke page 3 setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainMenu(),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Text di tengah layar
          
          // SVG di kanan bawah dengan zoom 3x
          Positioned(
            bottom: 0,
            right: 0,
            child: Hero(
              tag: "splash-image",
              child: Transform.scale(
                scale: 3.0, // sama dengan final scale di splash screen
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset(
                  'assets/images/willow_splashscreen.svg',
                  width: MediaQuery.of(context).size.width, // ukuran sama dengan splash screen
                ),
              ),
            ),
          ),
          // Text Welcome dan Loading Indicator
          Align(
            alignment: Alignment(0, -0.5), // center horizontal, condong ke atas
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF497844),
                    ),
                  ),
                  SizedBox(height: 30),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF497844)),
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
