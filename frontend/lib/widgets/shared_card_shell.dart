import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';

/// Shared card shell used by all interactive assistant widgets.
/// Provides a consistent Deep Blue header strip + title block + divider layout.
/// Implements WCAG 2.1 accessible landmark and heading semantics.
class CardShell extends StatelessWidget {
  final IconData headerIcon;
  final String headerLabel;
  final String title;
  final String subtitle;
  final Widget child;

  const CardShell({
    super.key,
    required this.headerIcon,
    required this.headerLabel,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$headerLabel: $title',
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC3C6D1)),
          boxShadow: [
            BoxShadow(
              color: CivicPulseTheme.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Coloured header strip ──
            Semantics(
              header: true,
              label: headerLabel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: CivicPulseTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(child: Icon(headerIcon, color: Colors.white, size: 18)),
                    const SizedBox(width: 8),
                    Text(
                      headerLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Title + subtitle ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: CivicPulseTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CivicPulseTheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(indent: 20, endIndent: 20),
            // ── Body ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
