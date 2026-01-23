import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Willow Corp',
         debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Splash screen is the first page shown when app starts
      home: SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
     return Scaffold(
  backgroundColor: Colors.white,
  body: Stack(
    fit: StackFit.expand,
    children: [
      

      Positioned(
  bottom: 0,
  right: 0,
  child: Hero(
    tag: 'splashSVG',
    flightShuttleBuilder: _heroZoomBuilder,
    child: SvgPicture.asset(
      'assets/images/willow_splashscreen.svg',
      width: MediaQuery.of(context).size.width * 3, // ukuran final
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomRight,
    ),
  ),
),

      Center(
        child: Hero(
          tag: 'logo',
          // flightShuttleBuilder: _zoomTransition,
          child: Text(
            'Welcome',
            style: TextStyle(
              fontSize: 50, // lebih besar
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    ],
  ),
);

  }
}



Widget _heroZoomBuilder(
  BuildContext context,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      double scale = Tween<double>(begin: 1.0, end: 3.0) // ×3
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .evaluate(animation);

      return Transform.scale(
        scale: scale,
        alignment: Alignment.bottomRight, // fokus zoom ke kanan bawah
        child: child,
      );
    },
    child: direction == HeroFlightDirection.push
        ? toContext.widget
        : fromContext.widget,
  );
}
