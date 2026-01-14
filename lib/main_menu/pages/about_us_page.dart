import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsPage extends StatelessWidget {
  AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50.0), bottomRight: Radius.circular(50.0)),
              color: Color(0xFF71A33F)
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/images/back_button.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(Color(0xFFffffff), BlendMode.srcIn),
                  ),
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/willow_logo_white.png',
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
              ]
            ),
          ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/willow_logo.png',
                  width: 150,
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // alignment: ,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFDFFEB9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'About us',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'How well do you really understand your insurance coverage or the coverage options available to you?',
                      style: TextStyle(
                        color: Color(0xFF497844),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 12,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'It can be devastating to suffer a loss and even more so if you thought you had coverage but don\'t for that particular situation. ',
                          ),
                          const TextSpan(
                            text: 'Willow Insurance Corp.',
                            style: TextStyle(
                              color:
                                  Color(0xFF5B973A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' prides itself on helping you understand the coverage you are purchasing with your hard earned money, and will do our best to make sure that your coverage matches your expectations. Our staff participates in ongoing education to ensure we can provide you with the knowledgeable service you deserve.',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFECBF33),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Rose Freeman',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(),
                              child: Text(
                                'Owner/Broker',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Expanded(child: SizedBox(width: 10)),
                        Image.asset(
                          'assets/images/rose.png',
                          width: 175,
                          height: 175,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ],
      ),
          ),
        ],
      ),
    );
  }
}
