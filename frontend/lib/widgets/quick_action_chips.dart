import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/civic_pulse_theme.dart';

class QuickActionChips extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActionChips({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.how_to_reg_outlined, label: 'Register to Vote',
          hint: 'Open voter registration guide'),
      _QuickAction(icon: Icons.location_on_outlined, label: 'Find My Booth',
          hint: 'Locate your assigned polling booth'),
      _QuickAction(icon: Icons.ballot_outlined, label: 'EVM Guide',
          hint: 'Learn how Electronic Voting Machines work'),
      _QuickAction(icon: Icons.quiz_outlined, label: 'Civic Quiz',
          hint: 'Test your civic knowledge'),
      _QuickAction(icon: Icons.people_outline, label: 'Candidates',
          hint: 'View candidate profiles for your constituency'),
      _QuickAction(icon: Icons.edit_note_outlined, label: 'Update Info',
          hint: 'Update your voter registration details'),
      _QuickAction(icon: Icons.link_outlined, label: 'Official Links',
          hint: 'Access official Election Commission portals'),
    ];

    return Semantics(
      label: 'Quick action shortcuts',
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _QuickChip(
                  action: action,
                  onTap: () => onActionSelected(action.label),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String hint;
  const _QuickAction({required this.icon, required this.label, required this.hint});
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.action.label,
      hint: widget.action.hint,
      onTap: widget.onTap,
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: (_hovered || _focused)
                    ? CivicPulseTheme.primary.withValues(alpha: 0.08)
                    : CivicPulseTheme.background,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: (_hovered || _focused)
                      ? CivicPulseTheme.primary.withValues(alpha: 0.4)
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: _focused ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      widget.action.icon,
                      size: 16,
                      color: (_hovered || _focused)
                          ? CivicPulseTheme.primary
                          : CivicPulseTheme.outline,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.action.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: (_hovered || _focused)
                              ? CivicPulseTheme.primary
                              : const Color(0xFF43474F),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
