import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../widgets/brand_text.dart';

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
                  _buildFirstPage(screenWidth),
                  _buildSecondPage(screenWidth),
                  _buildThirdPage(screenWidth),
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
        3,
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
  Widget _buildFirstPage(screenWidth) {
    // Implementation from the previous welcome page
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo/Icon
          Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.7,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/welcome_illustration.webp',
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.1),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.1),

          // Title
          Text(
            'Never miss a dose',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'Track your Pyridostigmine precisely and keep an eye on your symptoms effortlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
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

  Widget _buildSecondPage(screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.5,
            child: Image.asset(
              'assets/images/medication_illustration.webp',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenWidth * 0.1),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.1),

          // Title
          Text(
            'Taking medication\non time should always be free',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'mestiNow is free and open-source software, and it will always remain free—for the benefit of Myasthenia Gravis patients and anyone else who finds it helpful.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
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

  Widget _buildThirdPage(screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: screenWidth * 0.7,
            height: screenWidth * 0.7,
            child: Image.asset(
              'assets/images/open_pill.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenWidth * 0.1),
          _buildPageIndicator(_currentPage),
          SizedBox(height: screenWidth * 0.1),

          // Title
          Text(
            'Your data stays with you',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'mestiNow respects your privacy. All your medical information and tracking data is stored locally on your device and never shared with external servers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
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
