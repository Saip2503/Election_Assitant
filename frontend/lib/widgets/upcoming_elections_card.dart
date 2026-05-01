import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import 'shared_card_shell.dart';

class UpcomingElectionsCard extends ConsumerWidget {
  const UpcomingElectionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardShell(
      headerIcon: Icons.calendar_today_rounded,
      headerLabel: ref.tr('upcoming_polls'),
      title: ref.tr('gen_election_2026'),
      subtitle: ref.tr('poll_subtitle'),
      child: Column(
        children: [
          _buildElectionItem(
            ref.tr('lok_sabha'),
            ref.tr('phase_1'),
            ref.tr('days_left'),
            CivicPulseTheme.secondary,
          ),
          const SizedBox(height: 12),
          _buildElectionItem(
            ref.tr('state_polls'),
            ref.tr('maharashtra_date'),
            ref.tr('scheduled'),
            CivicPulseTheme.primaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildElectionItem(String name, String date, String status, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CivicPulseTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CivicPulseTheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                date,
                style: const TextStyle(color: CivicPulseTheme.outline, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
