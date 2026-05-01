import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A widget that is invisible to sighted users but readable by screen readers.
/// Used to provide additional context without cluttering the visual UI.
/// Implements the WCAG 2.1 "Visually Hidden" pattern.
class VisuallyHidden extends StatelessWidget {
  final String text;
  const VisuallyHidden(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      excludeSemantics: false,
      child: const SizedBox.shrink(),
    );
  }
}

/// Wraps a widget with a semantic heading role.
/// Use this for section titles to create a proper document outline.
class SemanticHeading extends StatelessWidget {
  final Widget child;
  final String? label;

  const SemanticHeading({super.key, required this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: label,
      child: child,
    );
  }
}

/// Wraps interactive content in a live region so screen readers
/// announce changes automatically (e.g., quiz results, eligibility banners).
class LiveRegion extends StatelessWidget {
  final Widget child;

  const LiveRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }
}

/// A tappable element with a fully described semantic label.
/// Ensures interactive elements are keyboard and screen-reader accessible.
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final String? hint;
  final Widget child;
  final bool isEnabled;

  const AccessibleButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.child,
    this.hint,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: isEnabled,
      onTap: onTap,
      child: child,
    );
  }
}

/// Marks a widget as a navigation landmark.
class NavLandmark extends StatelessWidget {
  final Widget child;
  final String label;

  const NavLandmark({super.key, required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      namesRoute: true,
      label: label,
      child: child,
    );
  }
}
