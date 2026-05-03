import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/civic_pulse_theme.dart';
import '../services/l10n_service.dart';
import '../widgets/language_selector.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final bool showUpgradeBanner = user?.isAnonymous ?? false;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ──
          ExcludeSemantics(
            child: Image.asset(
              'assets/images/hero_bg.webp',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // ── Scrollable centred content ──
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language selector row at the top
                  Padding(
                    padding: const EdgeInsets.only(top: 24, right: 24),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: const LanguageSelector(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Main card ──
                  Center(
                    child: Container(
                      width: 450,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Semantics(
                            label: 'Election Dost logo',
                            image: true,
                            child: Image.asset(
                              'assets/images/logo.webp',
                              height: 80,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          Text(
                            ref.tr('app_title'),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: CivicPulseTheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ref.tr('login_subtitle'),
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: CivicPulseTheme.outline,
                                    ),
                          ),
                          const SizedBox(height: 32),

                          // ── Upgrade banner (guest redirected from protected route) ──
                          if (showUpgradeBanner) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFFFB300)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_outline,
                                      color: Color(0xFFE65100), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Sign in with Google to access voter registration, booth finder & personal updates.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color:
                                                  const Color(0xFFBF360C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Google Sign-In ──
                          Semantics(
                            button: true,
                            label: ref.tr('login_google_full'),
                            hint:
                                'Authenticate with your Google account to unlock all features',
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => ref
                                    .read(authProvider.notifier)
                                    .signIn(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: Color(0xFFE0E0E0)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Native Google 'G' — no SVG/network image needed
                                    const _GoogleGIcon(),
                                    const SizedBox(width: 12),
                                    Text(
                                      ref.tr('login_google_full'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ── OR divider ──
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                        color: CivicPulseTheme.outline,
                                        fontSize: 13),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),

                          // ── Continue as Guest ──
                          Semantics(
                            button: true,
                            label: 'Continue as Guest',
                            hint:
                                'Access Civic Chat, Election Results and Quiz without signing in.',
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () => ref
                                    .read(authProvider.notifier)
                                    .signInAnonymously(),
                                icon: const Icon(Icons.person_outline),
                                label: const Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: CivicPulseTheme.primary,
                                  side: BorderSide(
                                      color: CivicPulseTheme.primary
                                          .withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Feature legend ──
                          const SizedBox(height: 16),
                          const _GuestFeatureList(),

                          const SizedBox(height: 20),
                          Text(
                            ref.tr('secure_managed'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: CivicPulseTheme.outline
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest feature legend ──────────────────────────────────────────────────────

class _GuestFeatureList extends StatelessWidget {
  const _GuestFeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      _Feature('Civic Chat (Ask questions)', true),
      _Feature('Election Results', true),
      _Feature('Civic Knowledge Quiz', true),
      _Feature('Voter Registration (Form 6/8)', false),
      _Feature('Find My Polling Booth', false),
      _Feature('Candidate Profiles & Updates', false),
    ];

    return Semantics(
      label: 'Guest vs signed-in feature comparison',
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CivicPulseTheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest access includes:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CivicPulseTheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...features.map((f) => _FeatureRow(feature: f)),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final String label;
  final bool available;
  const _Feature(this.label, this.available);
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${feature.label}: ${feature.available ? 'available' : 'requires sign-in'}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              feature.available
                  ? Icons.check_circle_outline
                  : Icons.lock_outline,
              size: 16,
              color: feature.available
                  ? const Color(0xFF2E7D32)
                  : CivicPulseTheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              feature.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: feature.available
                        ? const Color(0xFF1B5E20)
                        : CivicPulseTheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Native Google 'G' icon ────────────────────────────────────────────────────
// Drawn entirely with Flutter widgets — no SVG or network image required.
class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Colours per Google brand guidelines
    const blue   = Color(0xFF4285F4);
    const red    = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green  = Color(0xFF34A853);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;

    // Blue — top (right side)
    paint.color = blue;
    canvas.drawArc(rect, -0.52, 1.57, false, paint);

    // Red — top-left
    paint.color = red;
    canvas.drawArc(rect, 1.05, 1.6, false, paint);

    // Yellow — bottom-left
    paint.color = yellow;
    canvas.drawArc(rect, 2.65, 0.8, false, paint);

    // Green — bottom-right
    paint.color = green;
    canvas.drawArc(rect, 3.45, 0.9, false, paint);

    // Horizontal bar of the G (blue)
    paint
      ..color = blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.09,
          r * 0.85, size.height * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
