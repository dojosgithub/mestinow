import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
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
            Text(
              l10n.aboutTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.aboutOverview,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.aboutOverviewText),
            const SizedBox(height: 24),
            Text(
              l10n.aboutFeatures,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _FeatureItem(
              title: l10n.aboutFeatureMedication,
              description: l10n.aboutFeatureMedicationDesc,
            ),
            _FeatureItem(
              title: l10n.aboutFeatureSymptom,
              description: l10n.aboutFeatureSymptomDesc,
            ),
            _FeatureItem(
              title: l10n.aboutFeatureHistory,
              description: l10n.aboutFeatureHistoryDesc,
            ),
            _FeatureItem(
              title: l10n.aboutFeatureAccessibility,
              description: l10n.aboutFeatureAccessibilityDesc,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutPrivacy,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.aboutPrivacyText),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://github.com/dojosgithub/mestinow/wiki/Privacy-Policy',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Text(l10n.aboutPrivacyPolicy),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutDisclaimer,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDisclaimerText,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutSupport,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.aboutSupportText),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://github.com/dojosgithub/mestinow',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text('https://github.com/dojosgithub/mestinow'),
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

  const _FeatureItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}
