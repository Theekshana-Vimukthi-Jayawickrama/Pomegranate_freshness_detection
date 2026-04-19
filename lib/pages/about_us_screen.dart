import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  static const _deepRed = Color(0xFF8B0000);
  static const _primaryRed = Color(0xFFC0392B);
  static const _lightRedBg = Color(0xFFFFF5F5);
  static const _lightRedBorder = Color(0xFFF7C1C1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B0000), Color(0xFFC0392B), Color(0xFFE74C3C)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'About Us',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _PomegranateIcon(),
                const SizedBox(height: 14),
                const Text(
                  'PomeScan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Freshness Detection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'This application is an AI-powered mobile system developed to detect the freshness of pomegranates using deep learning models.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          _FeatureCard(
            icon: Icons.search_rounded,
            title: 'Smart detection',
            description:
                'Analyzes fruit images and classifies them as fresh or non-fresh instantly.',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.people_alt_rounded,
            title: 'For everyone',
            description:
                'Helps farmers, sellers, and buyers make better market decisions.',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.map_rounded,
            title: 'Works offline without chat option',
            description:
                'Perfect for rural areas — no internet connection required.',
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF7C1C1), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB41E1E).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFC0392B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF7C1C1), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFC0392B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7B1F1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    height: 1.5,
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

class _PomegranateIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(88, 88),
      painter: _PomegranatePainter(),
    );
  }
}

class _PomegranatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.64;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 64, height: 56),
      Paint()..color = const Color(0xFF7B1F1F),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 56, height: 48),
      Paint()..color = const Color(0xFFA52A2A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 38),
      Paint()..color = const Color(0xFFC0392B),
    );

    final seedPaint = Paint()..color = const Color(0xFFE8A0A0).withOpacity(0.5);
    for (final s in [
      [cx - 9, cy - 6, 3.0],
      [cx + 6, cy + 2, 2.5],
      [cx - 2, cy + 8, 2.0],
      [cx + 12, cy - 6, 2.0],
      [cx - 6, cy + 6, 1.5],
    ]) {
      canvas.drawCircle(Offset(s[0], s[1]), s[2], seedPaint);
    }

    final stemPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..style = PaintingStyle.fill;

    final stemPath = Path()
      ..moveTo(cx, cy - 28)
      ..quadraticBezierTo(cx, cy - 36, cx - 4, cy - 41)
      ..quadraticBezierTo(cx + 1, cy - 38, cx + 4, cy - 43)
      ..quadraticBezierTo(cx + 6, cy - 37, cx, cy - 28);

    canvas.drawPath(stemPath, stemPaint);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 27), width: 10, height: 8),
      Paint()..color = const Color(0xFF5C2A00),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 28), width: 8, height: 6),
      Paint()..color = const Color(0xFF7B3F00),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}