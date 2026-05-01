import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/civic_pulse_theme.dart';
import '../widgets/upcoming_elections_card.dart';
import '../widgets/booth_finder_card.dart';
import '../widgets/candidate_card.dart';
import '../widgets/quiz_widget.dart';
import '../providers/auth_provider.dart';

import '../services/l10n_service.dart';
import '../widgets/language_selector.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: CivicPulseTheme.background,
      body: Column(
        children: [
          _buildTopNav(context, ref),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildNavRail(context, ref),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroSection(context, ref),
                              const SizedBox(height: 32),
                              if (isDesktop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          const UpcomingElectionsCard(),
                                          const SizedBox(height: 24),
                                          const BoothFinderCard(
                                            location: 'New Panvel, Maharashtra',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          const CandidateCard(candidates: []),
                                          const SizedBox(height: 24),
                                          const QuizWidget(
                                            questions: [
                                              {
                                                'question':
                                                    'What is the minimum age to vote in India?',
                                                'options': [
                                                  '16',
                                                  '18',
                                                  '21',
                                                  '25',
                                                ],
                                                'answer_index': 1,
                                                'explanation':
                                                    'The voting age was lowered from 21 to 18 by the 61st Amendment Act of 1988.',
                                              },
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildQuizBanner(context, ref),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    const UpcomingElectionsCard(),
                                    const SizedBox(height: 24),
                                    const BoothFinderCard(
                                      location: 'New Panvel, Maharashtra',
                                    ),
                                    const SizedBox(height: 24),
                                    const CandidateCard(candidates: []),
                                    const SizedBox(height: 24),
                                    const QuizWidget(
                                      questions: [
                                        {
                                          'question':
                                              'What is the minimum age to vote in India?',
                                          'options': ['16', '18', '21', '25'],
                                          'answer_index': 1,
                                          'explanation':
                                              'The voting age was lowered from 21 to 18 by the 61st Amendment Act of 1988.',
                                        },
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildQuizBanner(context, ref),
                                  ],
                                ),
                              const SizedBox(height: 48),
                              _buildFooter(context, ref),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Container(
      height: 64,
      color: CivicPulseTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 40),
          const SizedBox(width: 12),
          Text(
            ref.tr('civic_pulse'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const LanguageSelector(),
          const SizedBox(width: 16),
          if (user == null)
            ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signIn(),
              icon: const Icon(Icons.login, size: 18),
              label: Text(ref.tr('login_google')),
              style: ElevatedButton.styleFrom(
                backgroundColor: CivicPulseTheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            Row(
              children: [
                if (user.photoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl!),
                    radius: 16,
                  )
                else
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                const SizedBox(width: 12),
                Text(
                  user.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  tooltip: 'Logout',
                ),
              ],
            ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () => context.go('/chat'),
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              ref.tr('ask_dost'),
              style: const TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.go('/results'),
            icon: const Icon(Icons.bar_chart, color: Colors.white, size: 18),
            label: Text(ref.tr('results'), style: const TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail(BuildContext context, WidgetRef ref) {
    return Container(
      width: 72,
      color: const Color(0xFF001B38),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _NavRailIcon(
            icon: Icons.dashboard_outlined,
            label: ref.tr('home'),
            isActive: true,
            onTap: () => context.go('/dashboard'),
          ),
          _NavRailIcon(
            icon: Icons.chat_bubble_outline,
            label: ref.tr('chat'),
            onTap: () => context.go('/chat'),
          ),
          _NavRailIcon(
            icon: Icons.quiz_outlined,
            label: ref.tr('quiz'),
            onTap: () => context.go('/quiz'),
          ),
          _NavRailIcon(
            icon: Icons.bar_chart,
            label: ref.tr('results'),
            onTap: () => context.go('/results'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/hero_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
        gradient: LinearGradient(
          colors: [CivicPulseTheme.primary, const Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CivicPulseTheme.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CivicPulseTheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: CivicPulseTheme.secondary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: CivicPulseTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ref.tr('india_lok_sabha'),
                        style: const TextStyle(
                          color: CivicPulseTheme.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ref.tr('hero_title'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 44,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ref.tr('hero_subtitle'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/chat'),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(ref.tr('ask_dost')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CivicPulseTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/quiz'),
                      icon: const Icon(Icons.quiz_outlined),
                      label: Text(ref.tr('take_civic_quiz')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 700) ...[
            const SizedBox(width: 40),
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                size: 140,
                color: Colors.white24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizBanner(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.go('/quiz'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9933), Color(0xFFFFB347)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('take_full_quiz'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ref.tr('quiz_desc'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CivicPulseTheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(
                label: 'Voter Portal (voters.eci.gov.in)',
                url: 'https://voters.eci.gov.in/Homepage',
                context: context,
              ),
              const SizedBox(width: 24),
              _FooterLink(
                label: 'ECI Official (eci.gov.in)',
                url: 'https://eci.gov.in',
                context: context,
              ),
              const SizedBox(width: 24),
              _FooterLink(
                label: ref.tr('voter_helpline'),
                url: 'tel:1950',
                context: context,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ref.tr('footer_text'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: CivicPulseTheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _NavRailIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavRailIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    right: BorderSide(
                      color: CivicPulseTheme.secondary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String url;
  final BuildContext context;

  const _FooterLink({
    required this.label,
    required this.url,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return InkWell(
      onTap: () {}, // open url_launcher in production
      child: Text(
        label,
        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: CivicPulseTheme.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
