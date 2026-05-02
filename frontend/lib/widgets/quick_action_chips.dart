import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';

class QuickActionChips extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActionChips({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.how_to_reg_outlined, label: 'Register to Vote'),
      _QuickAction(icon: Icons.location_on_outlined, label: 'Find My Booth'),
      _QuickAction(icon: Icons.ballot_outlined, label: 'EVM Guide'),
      _QuickAction(icon: Icons.quiz_outlined, label: 'Civic Quiz'),
      _QuickAction(icon: Icons.people_outline, label: 'Candidates'),
      _QuickAction(icon: Icons.edit_note_outlined, label: 'Update Info'),
      _QuickAction(icon: Icons.link_outlined, label: 'Official Links'),
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickChip(action: action, onTap: () => onActionSelected(action.label)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
}

class _QuickChip extends StatefulWidget {
  final _QuickAction action;
  final VoidCallback onTap;
  const _QuickChip({required this.action, required this.onTap});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? CivicPulseTheme.primary.withValues(alpha: 0.08)
                : CivicPulseTheme.background,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: _hovered
                  ? CivicPulseTheme.primary.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.action.icon,
                size: 16,
                color: _hovered ? CivicPulseTheme.primary : CivicPulseTheme.outline,
              ),
              const SizedBox(width: 6),
              Text(
                widget.action.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _hovered ? CivicPulseTheme.primary : const Color(0xFF43474F),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
