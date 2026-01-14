import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'services/data_service.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _logoPositionAnimation;

  @override
  void initState() {
    super.initState();
    
    // Load data from API
    _loadData();
    
    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation: dari 1x ke 3x
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    // Logo position animation: dari tengah ke kanan atas
    _logoPositionAnimation = Tween<Offset>(
      begin: Offset(0, 0), // tengah
      end: Offset(-2, -2), // kiri atas (offset relatif dari center)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    // Listener untuk navigasi saat animasi hampir selesai
    bool hasNavigated = false;
    _controller.addListener(() {
      // Navigasi saat animasi mencapai 98% untuk transisi Hero yang smooth
      if (_controller.value >= 1 && !hasNavigated && mounted) {
        hasNavigated = true;
        // Gunakan SchedulerBinding untuk memastikan frame sudah di-render
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          }
        });
      }
    });

    // Start animation setelah delay singkat
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  // Load data from API
  Future<void> _loadData() async {
    try {
      final dataService = DataService();
      await dataService.fetchData();
      print('Data loaded successfully');
      if (dataService.cachedData != null) {
        print('Video guides: ${dataService.cachedData!.videoGuide.length}');
        print('Mobile services: ${dataService.cachedData!.mobileService.length}');
        print('Resources: ${dataService.cachedData!.resource.length}');
        print('Book appointments: ${dataService.cachedData!.bookAppointment.length}');
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: Hero(
                  tag: "splash-image",
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.bottomRight,
                    child: SvgPicture.asset(
                      'assets/images/willow_splashscreen.svg',
                      width: MediaQuery.of(context).size.width, // ukuran final
                      // fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Logo dengan animasi bergeser ke kanan atas
              Center(
                child: SlideTransition(
                  position: _logoPositionAnimation,
                  child: Image.asset(
                    'assets/images/willow_logo.png',
                    width: 240,
                  ),
                ),
              ),
            ],
          );
          },
        ),
      );  
    
  }
}
