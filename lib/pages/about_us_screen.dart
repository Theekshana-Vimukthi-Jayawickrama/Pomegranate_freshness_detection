import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Us',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'This application is an AI-powered mobile system developed to detect the freshness of pomegranates.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'It uses deep learning models to analyze fruit images and classify them as fresh or non-fresh.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'The goal is to help farmers, sellers, and buyers make better decisions in the market.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'The application works offline, which makes it useful for rural areas.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
