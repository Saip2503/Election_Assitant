import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/l10n_service.dart';

void main() {
  // ── L10nService Tests ─────────────────────────────────────────────────────
  group('L10nService – Translation Keys', () {
    test('English: app_title', () => expect(L10nService.translate('app_title', 'en'), 'Election Dost'));
    test('Hindi:   app_title', () => expect(L10nService.translate('app_title', 'hi'), 'चुनाव दोस्त'));
    test('Telugu:  app_title', () => expect(L10nService.translate('app_title', 'te'), 'ఎన్నికల దోస్త్'));

    test('English: logout', () => expect(L10nService.translate('logout', 'en'), isNotEmpty));
    test('Hindi:   logout', () => expect(L10nService.translate('logout', 'hi'), isNotEmpty));
    test('Telugu:  logout', () => expect(L10nService.translate('logout', 'te'), isNotEmpty));

    test('English: booth_finder', () => expect(L10nService.translate('booth_finder', 'en'), isNotEmpty));
    test('English: results',      () => expect(L10nService.translate('results', 'en'), isNotEmpty));
    test('English: quiz',         () => expect(L10nService.translate('quiz', 'en'), isNotEmpty));

    test('Missing key returns key name', () {
      expect(L10nService.translate('no_such_key_xyz', 'en'), 'no_such_key_xyz');
    });

    test('Unsupported language code falls back gracefully', () {
      // Should not throw; returns key or any non-null value
      expect(() => L10nService.translate('app_title', 'fr'), returnsNormally);
    });
  });

  // ── Voter Eligibility Logic ───────────────────────────────────────────────
  group('Voter Eligibility – Age Boundary Logic', () {
    // Replicates WorkflowService.check_eligibility cutoff: April 1, 2026
    const cutoffYear = 2026;
    const cutoffMonth = 4;
    const cutoffDay = 1;

    int ageOn(DateTime dob) {
      final cutoff = DateTime(cutoffYear, cutoffMonth, cutoffDay);
      int age = cutoff.year - dob.year;
      if (cutoff.month < dob.month ||
          (cutoff.month == dob.month && cutoff.day < dob.day)) {
        age--;
      }
      return age;
    }

    test('Born 19 years ago → eligible', () {
      final dob = DateTime(cutoffYear - 19, cutoffMonth, cutoffDay);
      expect(ageOn(dob) >= 18, isTrue);
    });

    test('Born exactly 18 years ago on cutoff → eligible (boundary)', () {
      final dob = DateTime(cutoffYear - 18, cutoffMonth, cutoffDay);
      expect(ageOn(dob) >= 18, isTrue);
    });

    test('Born 17 years 364 days ago → not eligible (day before threshold)', () {
      final dob = DateTime(cutoffYear - 18, cutoffMonth, cutoffDay + 1);
      expect(ageOn(dob) < 18, isTrue);
    });

    test('Born 10 years ago → not eligible', () {
      final dob = DateTime(cutoffYear - 10, cutoffMonth, cutoffDay);
      expect(ageOn(dob) < 18, isTrue);
    });
  });
}
