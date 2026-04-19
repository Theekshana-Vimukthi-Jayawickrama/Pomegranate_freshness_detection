import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  static const _primaryRed = Color(0xFFC0392B);
  static const _deepRed = Color(0xFF7B1F1F);
  static const _lightRedBg = Color(0xFFFFF5F5);
  static const _lightRedBorder = Color(0xFFF7C1C1);

  static const _policies = [
    _PolicyItem(
      icon: Icons.no_accounts_outlined,
      title: 'No account required',
      description:
          'You can use PomeScan without creating an account or providing personal registration details.',
    ),
    _PolicyItem(
      icon: Icons.camera_alt_outlined,
      title: 'Camera and image access',
      description:
          'The app uses camera access only to capture or select fruit images for pomegranate detection and freshness analysis.',
    ),
    _PolicyItem(
      icon: Icons.analytics_outlined,
      title: 'Prediction purpose only',
      description:
          'Captured images are used only to check whether a pomegranate is present, whether it is close enough, and whether it is fresh or non-fresh.',
    ),
    _PolicyItem(
      icon: Icons.phone_android_outlined,
      title: 'Processed on device',
      description:
          'Core prediction features work on your device. The app is designed so image analysis can run locally without storing your personal data.',
    ),
    _PolicyItem(
      icon: Icons.cloud_off_outlined,
      title: 'No unnecessary sharing',
      description:
          'We do not sell, rent, or share your personal data with third parties for advertising or marketing purposes.',
    ),
    _PolicyItem(
      icon: Icons.chat_outlined,
      title: 'AI chat feature',
      description:
          'If you use the in-app AI chat or online assistance feature, only the information needed for that feature may be processed to generate a response.',
    ),
    _PolicyItem(
      icon: Icons.security_outlined,
      title: 'Security and updates',
      description:
          'We aim to protect user information and will clearly inform users if future versions introduce new internet-based or data-processing features.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(),
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
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
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
                        'Privacy Policy',
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
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your privacy matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'PomeScan is designed to support safe and responsible AI-based pomegranate freshness checking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._policies.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PolicyCard(item: item),
            ),
          ),
          _buildAgreementBanner(),
          const SizedBox(height: 12),
          const Text(
            'PomeScan · AI-Powered Pomegranate Freshness',
            style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAgreementBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _deepRed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, color: Colors.white70, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'By using PomeScan, you agree to this privacy policy. Please use the application responsibly and review future updates for any policy changes.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xD9FFFFFF),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyItem {
  final IconData icon;
  final String title;
  final String description;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _PolicyCard extends StatelessWidget {
  final _PolicyItem item;

  const _PolicyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7C1C1), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFC0392B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7B1F1F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
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