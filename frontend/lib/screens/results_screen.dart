import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter/material.dart';
import '../widgets/eci_results_web_view.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CivicPulseTheme.background,
      body: Column(
        children: [
          // Header matching chat screen style
          Container(
            height: 64,
            color: CivicPulseTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/dashboard'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.bar_chart, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Official ECI Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const _StatusBadge(
                  label: 'OFFICIAL LIVE',
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Official ECI Results Web View
          const Expanded(
            child: ECIResultsWebView(),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
