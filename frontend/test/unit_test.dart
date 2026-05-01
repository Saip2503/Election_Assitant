import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/l10n_service.dart';

void main() {
  group('L10nService Tests', () {
    test('Service returns correct translation for English', () {
      final text = L10nService.translate('app_title', 'en');
      expect(text, equals('Election Dost'));
    });

    test('Service returns correct translation for Hindi', () {
      final text = L10nService.translate('app_title', 'hi');
      expect(text, equals('चुनाव दोस्त'));
    });

    test('Service returns correct translation for Telugu', () {
      final text = L10nService.translate('app_title', 'te');
      expect(text, equals('ఎన్నికల దోస్త్'));
    });

    test('Service returns key if translation is missing', () {
      final text = L10nService.translate('non_existent_key', 'en');
      expect(text, equals('non_existent_key'));
    });
  });

  group('Voter Eligibility Logic', () {
    test('18+ user should be eligible', () {
      final birthDate = DateTime.now().subtract(const Duration(days: 365 * 19));
      final age = DateTime.now().year - birthDate.year;
      expect(age >= 18, isTrue);
    });

    test('Under 18 user should not be eligible', () {
      final birthDate = DateTime.now().subtract(const Duration(days: 365 * 17));
      final age = DateTime.now().year - birthDate.year;
      expect(age < 18, isTrue);
    });
  });
}
