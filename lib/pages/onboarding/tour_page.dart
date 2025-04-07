import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../widgets/brand_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourPage extends StatefulWidget {
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _neverShowAgain = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const BrandText(),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildFirstPage(l10n, screenWidth, screenHeight),
                  _buildSecondPage(l10n, screenWidth, screenHeight),
                  _buildThirdPage(l10n, screenWidth, screenHeight),
                  _buildFourthPage(l10n, screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(currentPage) {
    // Page Indicators
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentPage == index
                    ? AppColors.darkPrimary
                    : AppColors.darkPrimary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  // First page implementation from previous code
  Widget _buildFirstPage(l10n, screenWidth, screenHeight) {
    // Implementation from the previous welcome page
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo/Icon
          Container(
            width: screenHeight * 0.3,
            height: screenHeight * 0.3,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/welcome_illustration.webp',
                width: screenHeight * 0.28,
                height: screenHeight * 0.28,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.05),

          Text(
            l10n.tour1_title,
            style: TextStyle(
              fontSize: min(screenWidth * 0.06, screenHeight * 0.03),
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
            ),
          ),
          SizedBox(height: screenWidth * 0.05),

          Text(
            l10n.tour1_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.04, screenHeight * 0.02),
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenWidth * 0.1),

          // Skip Tour Button
          TextButton(
            onPressed: () {
              // Navigate to main app
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text(
              'Skip Tour',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ); // Add the previous page implementation here
  }

  Widget _buildSecondPage(l10n, screenWidth, screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: screenHeight * 0.3,
            height: screenHeight * 0.3,
            child: Image.asset(
              'assets/images/medication_illustration.webp',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.05),

          // Title
          Text(
            l10n.tour2_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.06, screenHeight * 0.03),
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            l10n.tour2_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.04, screenHeight * 0.02),
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenWidth * 0.1),

          // Skip Tour Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(
              'Skip Tour',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPage(l10n, screenWidth, screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: screenHeight * 0.3,
            height: screenHeight * 0.3,
            child: Image.asset(
              'assets/images/security_illustration.webp',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.05),

          // Title
          Text(
            l10n.tour3_title,
            style: TextStyle(
              fontSize: min(screenWidth * 0.06, screenHeight * 0.03),
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            l10n.tour3_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.04, screenHeight * 0.02),
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),

          SizedBox(height: screenWidth * 0.01),
          // Skip Tour Button
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(
              'Skip Tour',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourthPage(l10n, screenWidth, screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: screenHeight * 0.3,
            height: screenHeight * 0.3,
            child: Image.asset(
              'assets/images/open_pill.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.05),

          // Title
          Text(
            l10n.tour4_title,
            style: TextStyle(
              fontSize: min(screenWidth * 0.06, screenHeight * 0.03),
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            l10n.tour4_text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: min(screenWidth * 0.04, screenHeight * 0.02),
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),

          // Don't show again checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _neverShowAgain,
                activeColor: AppColors.primary,
                onChanged: (bool? value) {
                  setState(() {
                    _neverShowAgain = value ?? false;
                  });
                },
              ),
              Text(
                'Don\'t show tour again',
                style: TextStyle(color: AppColors.primary, fontSize: 14),
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.01),
          // Skip Tour Button
          TextButton(
            onPressed: () {
              // Navigate to main app
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('showTour', !_neverShowAgain);
              });
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(
              'End Tour',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
