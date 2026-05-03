import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/civic_pulse_theme.dart';

/// The ECI results page sends X-Frame-Options: DENY so it cannot be embedded
/// in any iframe regardless of client CSP.
/// This widget shows a rich portal with a direct external link instead.
class ECIResultsWebView extends StatelessWidget {
  const ECIResultsWebView({super.key});

  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Notice ──────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB300)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFF57F17), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Official ECI Results Portal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFE65100),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The Election Commission of India restricts embedding their portal in third-party apps (X-Frame-Options: DENY). Open the direct link below to view live results.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFBF360C),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Primary CTA ─────────────────────────────────────────────────────
          Semantics(
            button: true,
            label: 'Open official ECI election results in a new tab',
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _openUrl('https://results.eci.gov.in/'),
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Open Official ECI Results',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CivicPulseTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Links grid ──────────────────────────────────────────────────────
          Text(
            'Official ECI Portals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CivicPulseTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _LinksGrid(onOpen: _openUrl),
        ],
      ),
    );
  }
}

// ── Links grid ───────────────────────────────────────────────────────────────

class _LinksGrid extends StatelessWidget {
  final void Function(String url) onOpen;

  const _LinksGrid({required this.onOpen});

  static const _links = [
    _ECILink('Live Election Results',  Icons.bar_chart,           'https://results.eci.gov.in/'),
    _ECILink('Voter Registration',      Icons.how_to_reg_outlined, 'https://voters.eci.gov.in/'),
    _ECILink('Voter Helpline 1950',     Icons.phone_outlined,      'tel:1950'),
    _ECILink('ECI Official Site',       Icons.account_balance,     'https://eci.gov.in/'),
    _ECILink('NVSP Portal',             Icons.person_outline,      'https://www.nvsp.in/'),
    _ECILink('CEO Maharashtra',         Icons.location_city,       'https://ceo.maharashtra.gov.in/'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 100,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _links.length,
      itemBuilder: (ctx, i) =>
          _LinkCard(link: _links[i], onOpen: onOpen),
    );
  }
}

class _ECILink {
  final String label;
  final IconData icon;
  final String url;
  const _ECILink(this.label, this.icon, this.url);
}

class _LinkCard extends StatefulWidget {
  final _ECILink link;
  final void Function(String url) onOpen;
  const _LinkCard({required this.link, required this.onOpen});

  @override
  State<_LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<_LinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open ${widget.link.label}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => widget.onOpen(widget.link.url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hovered
                  ? CivicPulseTheme.primary.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered
                    ? CivicPulseTheme.primary.withValues(alpha: 0.4)
                    : const Color(0xFFC3C6D1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.link.icon,
                  color: _hovered
                      ? CivicPulseTheme.primary
                      : CivicPulseTheme.outline,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.link.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _hovered
                            ? CivicPulseTheme.primary
                            : const Color(0xFF43474F),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
