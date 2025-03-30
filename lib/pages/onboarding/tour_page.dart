import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'mestiNow',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF016367),
                  ),
                ),
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
                  _buildFirstPage(),
                  _buildSecondPage(),
                  _buildThirdPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/images/medication_illustration.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 48),

          // Page Indicators
          _buildPageIndicator(_currentPage),
          const SizedBox(height: 48),

          // Title
          Text(
            'Taking medication\non time should always be free',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'mestiNow is free and open-source software, and it will always remain free—for the benefit of Myasthenia Gravis patients and anyone else who finds it helpful.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

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
                    ? Color(0xFF016367)
                    : Color(0xFF016367).withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  // First page implementation from previous code
  Widget _buildFirstPage() {
    // Implementation from the previous welcome page
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo/Icon
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/welcome_illustration.webp',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 48),

          _buildPageIndicator(_currentPage),
          const SizedBox(height: 48),

          // Title
          const Text(
            'Never miss a dose',
            style: TextStyle(
              fontSize: 24,
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
              fontSize: 16,
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

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

  Widget _buildThirdPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/images/open_pill.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 48),

          // Page Indicators
          _buildPageIndicator(_currentPage),
          const SizedBox(height: 48),

          // Title
          Text(
            'Your data stays with you',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'mestiNow respects your privacy. All your medical information and tracking data is stored locally on your device and never shared with external servers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

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

          const SizedBox(height: 24),
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
