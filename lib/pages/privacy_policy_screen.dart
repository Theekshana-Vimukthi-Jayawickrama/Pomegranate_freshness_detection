import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Your privacy is important to us.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'This application does not collect personal information without your permission.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'The images used for freshness detection are processed only for prediction purposes.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'We do not share your data with third parties.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'The application works offline without chat option. Therefore, your data stays on your device.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'If future updates require internet services, users will be informed clearly.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'By using this application, you agree to this privacy policy.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
