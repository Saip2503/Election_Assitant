import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import 'shared_card_shell.dart';

class CandidateCard extends ConsumerWidget {
  final List<dynamic> candidates;
  const CandidateCard({super.key, required this.candidates});

  // Default mock candidates matching Stitch "Candidate Profiles" screen
  static const _mockCandidates = [
    _CandidateData(
      name: 'Arjun Patil',
      party: 'Vikas Party',
      color: CivicPulseTheme.primary,
      agenda: [
        'Upgrading local public hospital infrastructure',
        '24/7 clean water supply for Panvel West',
        'Setting up a specialised youth skill centre',
      ],
    ),
    _CandidateData(
      name: 'Priya Deshmukh',
      party: 'Navbharat Party',
      color: Color(0xFF8F4E00),
      agenda: [
        "Women's safety initiatives & faster grievance redressal",
        'Expanding local green spaces and parks',
        'Subsidised legal aid for marginalised communities',
      ],
    ),
    _CandidateData(
      name: 'Ramesh Rao',
      party: 'Independent',
      color: Color(0xFF43474F),
      agenda: [
        'Tax breaks for local street vendors',
        'Repairing pothole-ridden inner roads',
        'Direct citizen-audit of municipal spending',
      ],
    ),
  ];

  List<_CandidateData> _buildList() {
    if (candidates.isEmpty) return _mockCandidates;
    return candidates.map((c) {
      final name = c['name'] ?? 'Unknown';
      final party = c['party'] ?? 'Independent';
      return _CandidateData(
        name: name, party: party,
        color: CivicPulseTheme.primary,
        agenda: List<String>.from(c['agenda'] ?? []),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = _buildList();
    return CardShell(
      headerIcon: Icons.people_outline,
      headerLabel: ref.tr('candidate_profiles'),
      title: ref.tr('candidates_in_panvel'),
      subtitle: ref.tr('candidate_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list.asMap().entries.map((e) {
          final c = e.value;
          final isLast = e.key == list.length - 1;
          return Column(
            children: [
              _CandidateTile(candidate: c, ref: ref),
              if (!isLast) const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CandidateTile extends StatefulWidget {
  final _CandidateData candidate;
  final WidgetRef ref;
  const _CandidateTile({required this.candidate, required this.ref});

  @override
  State<_CandidateTile> createState() => _CandidateTileState();
}

class _CandidateTileState extends State<_CandidateTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: c.color.withValues(alpha: 0.12),
              radius: 24,
              backgroundImage: const AssetImage('assets/images/candidate_placeholder.png'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CivicPulseTheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(c.party,
                      style: TextStyle(color: c.color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                foregroundColor: CivicPulseTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_expanded ? widget.ref.tr('less') : widget.ref.tr('more')),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
                ],
              ),
            ),
          ],
        ),
        if (_expanded && c.agenda.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CivicPulseTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC3C6D1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_outlined, size: 16, color: CivicPulseTheme.secondary),
                    const SizedBox(width: 6),
                    Text(widget.ref.tr('key_agenda'), style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700, color: CivicPulseTheme.secondary)),
                  ],
                ),
                const SizedBox(height: 10),
                ...c.agenda.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6, height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                      ),
                      Expanded(child: Text(item,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF43474F), height: 1.5))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CandidateData {
  final String name;
  final String party;
  final Color color;
  final List<String> agenda;
  const _CandidateData({
    required this.name,
    required this.party,
    required this.color,
    required this.agenda,
  });
}
