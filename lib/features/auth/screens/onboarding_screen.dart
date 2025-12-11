import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      // Skip Button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => _navigateToLogin(),
                          child: const Text('Skip'),
                        ),
                      ),
                      
                      // Page View
                      SizedBox(
                        height: constraints.maxHeight * 0.58,
                        child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: AppConstants.onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = AppConstants.onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration
                          Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForPage(index),
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Title
                          Text(
                            data['title']!,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            data['description']!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
                      
                      // Page Indicator
                      SmoothPageIndicator(
                controller: _pageController,
                count: AppConstants.onboardingData.length,
                effect: WormEffect(
                  dotColor: theme.colorScheme.primary.withOpacity(0.3),
                  activeDotColor: theme.colorScheme.primary,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              
                      const SizedBox(height: 32),
                      
                      // Next/Get Started Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: CustomButton(
                          text: _currentPage == AppConstants.onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: () {
                            if (_currentPage == AppConstants.onboardingData.length - 1) {
                              _navigateToLogin();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.delete_outline;
      case 1:
        return Icons.track_changes;
      case 2:
        return Icons.eco;
      default:
        return Icons.delete_outline;
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}