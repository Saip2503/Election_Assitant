import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/civic_pulse_theme.dart';
import '../services/external_links_service.dart';
import 'shared_card_shell.dart';

class OfficialLinksCard extends ConsumerWidget {
  const OfficialLinksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardShell(
      headerIcon: Icons.link,
      headerLabel: 'Official Directory',
      title: 'Election Resources',
      subtitle: 'Official portals for voter services, laws, and results.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LinkCategory(
            title: 'Voter Services',
            icon: Icons.how_to_reg,
            links: [
              _LinkItem('Voter Service Portal', ExternalLinksService.voterPortal),
              _LinkItem('Search Name in Roll', ExternalLinksService.voterSearch),
              _LinkItem('Download E-EPIC', ExternalLinksService.downloadEepic),
              _LinkItem('PDF Electoral Roll', ExternalLinksService.pdfElectoralRoll),
              _LinkItem('Track Application', ExternalLinksService.trackApplication),
              _LinkItem('Know Your Polling Station', ExternalLinksService.pollingStationSearch),
            ],
          ),
          const Divider(height: 32),
          _LinkCategory(
            title: 'Administration & Laws',
            icon: Icons.gavel,
            links: [
              _LinkItem('Model Code of Conduct', ExternalLinksService.mccInfo),
              _LinkItem('Election Laws', ExternalLinksService.electionLaws),
              _LinkItem('ECI Publications', ExternalLinksService.eciPublications),
              _LinkItem('Judicial References', ExternalLinksService.eciJudicialReferences),
              _LinkItem('Important Instructions', ExternalLinksService.eciImportantInstructions),
            ],
          ),
          const Divider(height: 32),
          _LinkCategory(
            title: 'Maharashtra State Portals',
            icon: Icons.location_city,
            links: [
              _LinkItem('State Election Commission (SEC)', ExternalLinksService.secMaharashtra),
              _LinkItem('Government of Maharashtra', ExternalLinksService.govtMaharashtra),
              _LinkItem('CEO Maharashtra Dashboard', ExternalLinksService.vacancyPosition),
            ],
          ),
          const Divider(height: 32),
          _LinkCategory(
            title: 'Others',
            icon: Icons.more_horiz,
            links: [
              _LinkItem('Candidate Affidavits', ExternalLinksService.candidateAffidavit),
              _LinkItem('Political Party Registration', ExternalLinksService.politicalPartyRegistration),
              _LinkItem('Online Complaint Registration', ExternalLinksService.complaintRegistration),
              _LinkItem('SVEEP Portal (Education)', ExternalLinksService.sveep),
              _LinkItem('EVM/VVPAT Information', ExternalLinksService.evmInfo),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LinkCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_LinkItem> links;

  const _LinkCategory({
    required this.title,
    required this.icon,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: CivicPulseTheme.primary),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CivicPulseTheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: links.map((link) => _LinkChip(link: link)).toList(),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  final _LinkItem link;
  const _LinkChip({required this.link});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ExternalLinksService.launchURL(link.url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CivicPulseTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC3C6D1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              link.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF43474F),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new, size: 12, color: CivicPulseTheme.outline),
          ],
        ),
      ),
    );
  }
}

class _LinkItem {
  final String label;
  final String url;
  _LinkItem(this.label, this.url);
}
