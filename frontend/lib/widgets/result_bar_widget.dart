import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';

class ResultBarWidget extends StatelessWidget {
  final String candidateName;
  final String partyName;
  final double percentage;
  final int votes;
  final bool isLeading;

  const ResultBarWidget({
    super.key,
    required this.candidateName,
    required this.partyName,
    required this.percentage,
    required this.votes,
    this.isLeading = false,
  });

  Color _barColor() {
    if (isLeading) return CivicPulseTheme.secondary; // saffron for leader
    return const Color(0xFFC3C6D1); // neutral for others
  }

  @override
  Widget build(BuildContext context) {
    final voteCount = _formatVotes(votes);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLeading ? CivicPulseTheme.secondary.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLeading
              ? CivicPulseTheme.secondary.withValues(alpha: 0.3)
              : const Color(0xFFC3C6D1),
          width: isLeading ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Candidate avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: isLeading
                    ? CivicPulseTheme.secondary.withValues(alpha: 0.15)
                    : const Color(0xFFEDEEEF),
                child: Text(candidateName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isLeading ? CivicPulseTheme.secondary : CivicPulseTheme.outline,
                    fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(candidateName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isLeading ? FontWeight.w700 : FontWeight.w500,
                            color: CivicPulseTheme.primary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CivicPulseTheme.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFC3C6D1)),
                          ),
                          child: Text(partyName,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: CivicPulseTheme.outline, fontWeight: FontWeight.w600)),
                        ),
                        if (isLeading) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: CivicPulseTheme.tertiaryContainer.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(color: CivicPulseTheme.tertiaryContainer.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 10, color: CivicPulseTheme.tertiaryContainer),
                                const SizedBox(width: 3),
                                Text('LEADING',
                                  style: TextStyle(
                                    color: CivicPulseTheme.tertiaryContainer,
                                    fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('$voteCount votes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: CivicPulseTheme.outline)),
                  ],
                ),
              ),
              Text('${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLeading ? CivicPulseTheme.secondary : CivicPulseTheme.primary)),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEEF),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _barColor(),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVotes(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)} L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}
