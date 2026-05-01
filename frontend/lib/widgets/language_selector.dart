import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../theme/civic_pulse_theme.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLang,
          dropdownColor: CivicPulseTheme.primary,
          icon: const Icon(Icons.language, color: Colors.white, size: 18),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
            DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
          ],
          onChanged: (val) {
            if (val != null) {
              ref.read(languageProvider.notifier).state = val;
            }
          },
        ),
      ),
    );
  }
}
