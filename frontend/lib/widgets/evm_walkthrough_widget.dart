import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/civic_pulse_theme.dart';
import 'shared_card_shell.dart';

class EVMWalkthroughWidget extends ConsumerStatefulWidget {
  const EVMWalkthroughWidget({super.key});

  @override
  ConsumerState<EVMWalkthroughWidget> createState() => _EVMWalkthroughWidgetState();
}

class _EVMWalkthroughWidgetState extends ConsumerState<EVMWalkthroughWidget> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step(
        icon: Icons.badge_outlined,
        number: '01',
        title: ref.tr('evm_step1_title'),
        description: ref.tr('evm_step1_desc'),
        tag: ref.tr('polling_officer'),
        tagColor: const Color(0xFF003366),
      ),
      _Step(
        icon: Icons.fingerprint,
        number: '02',
        title: ref.tr('evm_step2_title'),
        description: ref.tr('evm_step2_desc'),
        tag: ref.tr('inking_officer'),
        tagColor: const Color(0xFF8F4E00),
      ),
      _Step(
        icon: Icons.touch_app_outlined,
        number: '03',
        title: ref.tr('evm_step3_title'),
        description: ref.tr('evm_step3_desc'),
        tag: ref.tr('voting_booth'),
        tagColor: const Color(0xFF001E40),
      ),
      _Step(
        icon: Icons.receipt_long_outlined,
        number: '04',
        title: ref.tr('evm_step4_title'),
        description: ref.tr('evm_step4_desc'),
        tag: ref.tr('vvpat_machine'),
        tagColor: const Color(0xFF012500),
      ),
    ];

    final step = steps[_currentStep];
    return CardShell(
      headerIcon: Icons.ballot_outlined,
      headerLabel: ref.tr('interactive_guide'),
      title: ref.tr('evm_guide_title'),
      subtitle: ref.tr('evm_guide_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step progress indicators ──
          Row(
            children: List.generate(steps.length, (i) {
              final active = i <= _currentStep;
              final isCurrent = i == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentStep = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: isCurrent ? 6 : 4,
                          decoration: BoxDecoration(
                            color: active ? CivicPulseTheme.primary : const Color(0xFFC3C6D1),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                    if (i < steps.length - 1) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            '${ref.tr('step')} ${_currentStep + 1} ${ref.tr('of')} ${steps.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: CivicPulseTheme.outline),
          ),
          const SizedBox(height: 20),

          // ── Active step card ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey(_currentStep),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CivicPulseTheme.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CivicPulseTheme.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          color: CivicPulseTheme.primary, shape: BoxShape.circle),
                        child: Icon(step.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: step.tagColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(step.tag,
                              style: TextStyle(
                                color: step.tagColor, fontSize: 10,
                                fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(step.number,
                            style: const TextStyle(
                              color: CivicPulseTheme.primary,
                              fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(step.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CivicPulseTheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(step.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF43474F), height: 1.6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Navigation buttons ──
          Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _currentStep--),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(ref.tr('previous')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CivicPulseTheme.primary,
                    side: const BorderSide(color: CivicPulseTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              const Spacer(),
              if (_currentStep < steps.length - 1)
                FilledButton.icon(
                  onPressed: () => setState(() => _currentStep++),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(ref.tr('next_step')),
                  style: FilledButton.styleFrom(
                    backgroundColor: CivicPulseTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () => setState(() => _currentStep = 0),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(ref.tr('got_it')),
                  style: FilledButton.styleFrom(
                    backgroundColor: CivicPulseTheme.tertiaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String number;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  const _Step({
    required this.icon,
    required this.number,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
  });
}
