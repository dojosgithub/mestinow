import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About mestiNow'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/icon/mestinow.png',
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'mestiNow - Your Personal Mestinon® & MG Symptom Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'mestiNow is a mobile application specifically designed to help individuals with Myasthenia Gravis (MG) manage their Mestinon® (Pyridostigmine Bromide) medication intake and track their symptoms effectively. This app was created out of a personal need for a more flexible and accurate way to schedule and log medication doses, taking into account the immediate and time-sensitive nature of the medication\'s effects.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const _FeatureItem(
              title: 'Intelligent Medication Tracking',
              description: 'Dynamically calculates and displays time since last dose and time until next recommended dose. Features visual countdown timer and customizable reminders.',
            ),
            const _FeatureItem(
              title: 'Comprehensive Symptom Tracking',
              description: 'Easy-to-use interface for logging key MG symptoms including muscle strength, eye drooping, fatigue level, and more.',
            ),
            const _FeatureItem(
              title: 'Detailed History and Insights',
              description: 'Calendar view for medication and symptom history, with summary charts and data export capabilities.',
            ),
            const _FeatureItem(
              title: 'Enhanced Accessibility',
              description: 'Font scaling, high-contrast visuals, and clear indicators for medication timing.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Privacy and Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your privacy is our priority. All data is stored locally on your device with encryption. We do not collect or transmit your personal data to any external servers.',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse('https://github.com/dojosgithub/mestinow/wiki/Privacy-Policy');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text('View Privacy Policy'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Disclaimer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mestinon® is a registered trademark of Bausch Health Companies Inc. mestiNow is not affiliated with, endorsed, sponsored, or supported by Bausch Health Companies Inc. This application is provided solely for the convenience of patients.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For additional support or questions about the app\'s functionality, please refer to the settings page within the app or contact the app developer through the provided channels.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
} 