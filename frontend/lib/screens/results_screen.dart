import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/result_bar_widget.dart';
import '../theme/civic_pulse_theme.dart';
import '../providers/results_provider.dart';
import '../providers/constituency_provider.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider);
    final constituenciesAsync = ref.watch(constituenciesListProvider);
    final selectedConstituency = ref.watch(selectedConstituencyNameProvider);
    final detailsAsync = ref.watch(constituencyDetailsProvider);
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
                  'Election Results Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _StatusBadge(
                  label: 'LIVE',
                  color: CivicPulseTheme.tertiaryContainer,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top summary row
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.how_to_vote,
                              label: 'Total Votes Cast',
                              value: '3,20,680',
                              color: CivicPulseTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.people_outline,
                              label: 'Voter Turnout',
                              value: '68.4%',
                              color: CivicPulseTheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              icon: Icons.location_on_outlined,
                              label: 'Constituency',
                              value: 'New Panvel',
                              color: CivicPulseTheme.tertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Section title
                      Text(
                        'Live Results Summary',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: CivicPulseTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'India Lok Sabha Elections 2024',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CivicPulseTheme.outline,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Constituency selector
                      constituenciesAsync.when(
                        data: (list) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedConstituency,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              hint: const Text(
                                'Search / Select Parliamentary Constituency',
                              ),
                              items: list.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                          .read(
                                            selectedConstituencyNameProvider
                                                .notifier,
                                          )
                                          .state =
                                      val;
                                }
                              },
                            ),
                          ),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) =>
                            Text('Failed to load constituencies: $err'),
                      ),
                      const SizedBox(height: 24),

                      // Detailed Constituency Card
                      if (selectedConstituency != null)
                        detailsAsync.when(
                          data: (details) => details == null
                              ? const SizedBox.shrink()
                              : _buildDetailedConstituencyCard(
                                  context,
                                  details,
                                ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) =>
                              Text('Error loading details: $err'),
                        ),

                      const SizedBox(height: 32),

                      // 1. Party-wise Seat Summary
                      resultsAsync.when(
                        data: (data) => Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Party-wise Seat Counts',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: CivicPulseTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const Spacer(),
                                    const _StatusBadge(
                                      label: 'FINAL 2024',
                                      color: Color(0xFF006D3E),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total Seats: 543',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: CivicPulseTheme.outline,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                ...data.map((res) {
                                  final seats = res['Seats Won'] ?? 0;
                                  final party =
                                      res['Leading Party'] ?? 'Unknown';
                                  final percentage = (seats / 543) * 100;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ResultBarWidget(
                                      candidateName: party,
                                      partyName: party,
                                      votes: seats,
                                      percentage: double.parse(
                                        percentage.toStringAsFixed(1),
                                      ),
                                      isLeading: seats > 200,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error: $err'),
                      ),

                      const SizedBox(height: 32),

                      // 2. Constituency Details Section
                      Text(
                        'Constituency Details',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: CivicPulseTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      constituenciesAsync.when(
                        data: (list) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedConstituency,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              hint: const Text(
                                'Search / Select Parliamentary Constituency',
                              ),
                              items: list.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                          .read(
                                            selectedConstituencyNameProvider
                                                .notifier,
                                          )
                                          .state =
                                      val;
                                }
                              },
                            ),
                          ),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('Failed to load: $err'),
                      ),
                      const SizedBox(height: 24),

                      if (selectedConstituency != null)
                        detailsAsync.when(
                          data: (details) => details == null
                              ? const Text('No details found.')
                              : _buildDetailedConstituencyCard(
                                  context,
                                  details,
                                ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error: $err'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedConstituencyCard(
    BuildContext context,
    Map<String, dynamic> d,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['Constituency'] ?? 'Unknown',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: CivicPulseTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Constituency No: ${d['Const_No']}',
                      style: TextStyle(
                        color: CivicPulseTheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _StatusBadge(
                  label: d['Status'] ?? 'RESULT',
                  color: const Color(0xFF006D3E),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildCandidateRow(
              context,
              label: 'LEADING CANDIDATE',
              name: d['Leading_Candidate'] ?? 'N/A',
              party: d['Leading_Party'] ?? 'N/A',
              isWinner: true,
            ),
            const SizedBox(height: 20),
            _buildCandidateRow(
              context,
              label: 'TRAILING CANDIDATE',
              name: d['Trailing_Candidate'] ?? 'N/A',
              party: d['Trailing_Party'] ?? 'N/A',
              isWinner: false,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CivicPulseTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CivicPulseTheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: CivicPulseTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Winning Margin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${d['Margin'] ?? '0'} Votes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CivicPulseTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateRow(
    BuildContext context, {
    required String label,
    required String name,
    required String party,
    required bool isWinner,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: isWinner
              ? const Color(0xFF006D3E).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          child: Icon(
            Icons.person,
            color: isWinner ? const Color(0xFF006D3E) : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isWinner
                      ? const Color(0xFF006D3E)
                      : CivicPulseTheme.outline,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                party,
                style: TextStyle(color: CivicPulseTheme.outline, fontSize: 13),
              ),
            ],
          ),
        ),
        if (isWinner)
          const Icon(Icons.check_circle, color: Color(0xFF006D3E), size: 20),
      ],
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: CivicPulseTheme.outline),
          ),
        ],
      ),
    );
  }
}
