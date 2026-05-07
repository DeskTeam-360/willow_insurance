import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const Color _greenHeader = Color(0xFF71A33F);
  static const Color _meetStaffBg = Color(0xFF5B973A);
  static const Color _staffCardBg = Color(0xFF497844);
  static const Color _nameBadgeYellow = Color(0xFFECBF33);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 60, 30, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
              color: _greenHeader,
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
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Opacity(
                    opacity: 0.35,
                    child: SvgPicture.asset(
                      'assets/images/willow_splashscreen.svg',
                      width: MediaQuery.of(context).size.width * 6,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
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
                                          color: Color(0xFF5B973A),
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
                              ],
                            ),
                          ),
                          SizedBox(height: 28),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _nameBadgeYellow,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Rose Freeman',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF222222),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Owner/ Broker',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF555555),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Builder(
                                  builder: (context) {
                                    final d = MediaQuery.sizeOf(context).width * 0.5;
                                    final inset = d * 0.04;
                                    return SizedBox(
                                      width: d,
                                      height: d,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(inset),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/rose.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 28),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MeetOurStaffSection(),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.paddingOf(context).bottom,
                        child: const ColoredBox(color: Color(0xFF508738)),
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
}

class _MeetOurStaffSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AboutUsPage._meetStaffBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  child: Opacity(
                    opacity: 0.3,
                    child: SvgPicture.asset(
                      'assets/images/willow_splashscreen.svg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Meet Our Staff',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dedicated professionals ready to assist you with all your insurance needs across Saskatchewan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _StaffCard(
                            name: 'Rose Freeman',
                            detailLine: 'C.A.I.B | Shell Lake',
                            roleLine: 'Founder & CEO',
                            imageAsset: 'assets/images/au_rose.png',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StaffCard(
                            name: 'Kristen Harmon',
                            detailLine: 'Remote',
                            roleLine: 'Commercial Broker',
                            imageAsset: 'assets/images/au_kristen.png',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _StaffCard(
                            name: 'Natalie Martin',
                            detailLine: 'Shell Lake',
                            roleLine: 'Personal Line Broker',
                            imageAsset: 'assets/images/au_natalie.png',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StaffCard(
                            name: 'Jason Bucknell',
                            detailLine: 'C.A.I.B | Debden',
                            roleLine: 'Assistant Branch Manager',
                            imageAsset: 'assets/images/au_jason.png',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.name,
    required this.detailLine,
    required this.roleLine,
    this.imageAsset,
  });

  final String name;
  final String detailLine;
  final String roleLine;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AboutUsPage._staffCardBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Color(0xFF3D6B38),
                      child: Icon(
                        Icons.person,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  detailLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  roleLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD6F6B0),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
