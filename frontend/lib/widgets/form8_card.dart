import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/civic_pulse_theme.dart';
import 'shared_card_shell.dart';

class Form8Card extends ConsumerWidget {
  const Form8Card({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = [
      _Step(icon: Icons.download_outlined,     title: ref.tr('form8_step1_title'), desc: ref.tr('form8_step1_desc'), isActive: true),
      _Step(icon: Icons.edit_document,         title: ref.tr('form8_step2_title'), desc: ref.tr('form8_step2_desc')),
      _Step(icon: Icons.attach_file_outlined,  title: ref.tr('form8_step3_title'), desc: ref.tr('form8_step3_desc')),
      _Step(icon: Icons.send_outlined,         title: ref.tr('form8_step4_title'), desc: ref.tr('form8_step4_desc'), isLast: true),
    ];
    return CardShell(
      headerIcon: Icons.edit_note_outlined,
      headerLabel: ref.tr('voter_update_header'),
      title: ref.tr('voter_update_title'),
      subtitle: ref.tr('voter_update_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CivicPulseTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, size: 40, color: CivicPulseTheme.secondary.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CivicPulseTheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CivicPulseTheme.secondary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: CivicPulseTheme.secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  ref.tr('form8_info'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CivicPulseTheme.secondary, height: 1.5))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(ref.tr('step_by_step'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CivicPulseTheme.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...steps.map((s) => _StepRow(step: s)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: Text(ref.tr('download_form8')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CivicPulseTheme.secondary,
                    side: const BorderSide(color: CivicPulseTheme.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(ref.tr('submit_online')),
                  style: FilledButton.styleFrom(
                    backgroundColor: CivicPulseTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Help line
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: CivicPulseTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC3C6D1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: CivicPulseTheme.primary),
                const SizedBox(width: 10),
                Text('${ref.tr('voter_helpline')}: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: CivicPulseTheme.outline)),
                Text('1950', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CivicPulseTheme.primary, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('(${ref.tr('toll_free')})', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: CivicPulseTheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _Step step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final activeColor = step.isActive ? CivicPulseTheme.secondary : CivicPulseTheme.primary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isActive ? activeColor : activeColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(step.icon, size: 18,
                    color: step.isActive ? Colors.white : activeColor),
                ),
                if (!step.isLast)
                  Expanded(child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFC3C6D1),
                  )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(step.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isActive ? activeColor : const Color(0xFF191C1D))),
                  const SizedBox(height: 4),
                  Text(step.desc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CivicPulseTheme.outline, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String title;
  final String desc;
  final bool isActive;
  final bool isLast;
  const _Step({
    required this.icon,
    required this.title,
    required this.desc,
    this.isActive = false,
    this.isLast = false,
  });
}
