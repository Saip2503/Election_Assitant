import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../widgets/language_selector.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingData(
        title: ref.tr('onboarding_1_title'),
        description: ref.tr('onboarding_1_desc'),
        icon: Icons.chat_bubble_outline,
        color: CivicPulseTheme.primary,
      ),
      _OnboardingData(
        title: ref.tr('onboarding_2_title'),
        description: ref.tr('onboarding_2_desc'),
        icon: Icons.map_outlined,
        color: CivicPulseTheme.secondary,
      ),
      _OnboardingData(
        title: ref.tr('onboarding_3_title'),
        description: ref.tr('onboarding_3_desc'),
        icon: Icons.analytics_outlined,
        color: const Color(0xFF006D3E),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: LanguageSelector(),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemBuilder: (context, idx) {
                      final page = pages[idx];
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: page.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(page.icon, size: 100, color: page.color),
                            ),
                            const SizedBox(height: 60),
                            Text(
                              page.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: CivicPulseTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: CivicPulseTheme.outline,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(
                          pages.length,
                          (idx) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == idx ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == idx
                                  ? CivicPulseTheme.primary
                                  : CivicPulseTheme.outline.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Button
                      SizedBox(
                        height: 56,
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context.go('/dashboard');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CivicPulseTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentPage == pages.length - 1
                                ? ref.tr('get_started')
                                : ref.tr('next'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
