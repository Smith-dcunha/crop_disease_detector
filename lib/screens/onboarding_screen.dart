import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.camera_alt_rounded,
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Subtitle,
      color: AppColors.primary,
    ),
    OnboardingData(
      icon: Icons.offline_bolt_rounded,
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Subtitle,
      color: AppColors.secondary,
    ),
    OnboardingData(
      icon: Icons.local_hospital_rounded,
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Subtitle,
      color: AppColors.primaryLight,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstTime, false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page Indicator
            _buildPageIndicator(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingXLarge,
                vertical: AppConstants.paddingLarge,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeightLarge,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? AppStrings.getStarted
                        : AppStrings.next,
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppConstants.animationSlow,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: data.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        size: 80,
                        color: data.color,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.paddingXLarge * 2),

          // Title
          Text(
            data.title,
            style: AppTextStyles.h2.copyWith(color: data.color),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Description
          Text(
            data.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
            (index) => AnimatedContainer(
          duration: AppConstants.animationNormal,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _pages[_currentPage].color
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}