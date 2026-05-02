import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/civic_pulse_theme.dart';
import '../services/external_links_service.dart';
import 'shared_card_shell.dart';

class EligibilityCard extends ConsumerStatefulWidget {
  const EligibilityCard({super.key});

  @override
  ConsumerState<EligibilityCard> createState() => _EligibilityCardState();
}

class _EligibilityCardState extends ConsumerState<EligibilityCard> {
  DateTime? _selectedDate;
  String? _result;
  bool _isEligible = false;
  bool _loading = false;

  Future<void> _check() async {
    if (_selectedDate == null) return;
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('/api/eligibility'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'dob': DateFormat('yyyy-MM-dd').format(_selectedDate!)}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['message'];
          _isEligible = data['eligible'] ?? false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Could not connect to server. Please try again.';
        _isEligible = false;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final criteria = [
      _Criterion(
        icon: Icons.flag_outlined,
        title: ref.tr('citizen_title'),
        desc: ref.tr('citizen_desc'),
      ),
      _Criterion(
        icon: Icons.cake_outlined,
        title: ref.tr('age_req_title'),
        desc: ref.tr('age_req_desc'),
      ),
      _Criterion(
        icon: Icons.home_outlined,
        title: ref.tr('resident_title'),
        desc: ref.tr('resident_desc'),
      ),
    ];

    final steps = [
      _RegStep(icon: Icons.login_outlined,       title: ref.tr('step1_title'), desc: ref.tr('step1_desc')),
      _RegStep(icon: Icons.assignment_outlined,  title: ref.tr('step2_title'), desc: ref.tr('step2_desc')),
      _RegStep(icon: Icons.edit_note_outlined,   title: ref.tr('step3_title'), desc: ref.tr('step3_desc')),
      _RegStep(icon: Icons.upload_file_outlined, title: ref.tr('step4_title'), desc: ref.tr('step4_desc')),
      _RegStep(icon: Icons.send_outlined,        title: ref.tr('step5_title'), desc: ref.tr('step5_desc')),
    ];

    return CardShell(
      headerIcon: Icons.how_to_reg,
      headerLabel: ref.tr('eligibility_header'),
      title: ref.tr('eligibility_title'),
      subtitle: ref.tr('eligibility_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eligibility criteria ──
          _SectionTitle(text: ref.tr('basic_reqs')),
          const SizedBox(height: 12),
          ...criteria.map((c) => _CriterionTile(criterion: c)),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Age check ──
          _SectionTitle(text: ref.tr('age_check_title')),
          const SizedBox(height: 12),
          _DatePicker(
            selectedDate: _selectedDate,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(2006, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: CivicPulseTheme.primary),
                  ),
                  child: child!,
                ),
              );
              if (date != null) setState(() { _selectedDate = date; _result = null; });
            },
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (_result != null)
            _ResultBanner(isEligible: _isEligible, message: _result!)
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedDate == null ? null : _check,
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: Text(ref.tr('verify_eligibility')),
                style: FilledButton.styleFrom(
                  backgroundColor: CivicPulseTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
              ),
            ),

          if (_isEligible) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ExternalLinksService.launchURL(ExternalLinksService.voterPortal),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(ref.tr('download_form6')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CivicPulseTheme.primary,
                  side: const BorderSide(color: CivicPulseTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Registration steps ──
          _SectionTitle(text: ref.tr('how_to_reg')),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) => _StepTile(
            step: e.value,
            index: e.key,
            isLast: e.key == steps.length - 1,
          )),
        ],
      ),
    );
  }
}

// ── Supporting data classes ──────────────────────────────────────────────

class _Criterion {
  final IconData icon;
  final String title;
  final String desc;
  const _Criterion({required this.icon, required this.title, required this.desc});
}

class _RegStep {
  final IconData icon;
  final String title;
  final String desc;
  const _RegStep({required this.icon, required this.title, required this.desc});
}

// ── Sub-widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: CivicPulseTheme.primary,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _CriterionTile extends StatelessWidget {
  final _Criterion criterion;
  const _CriterionTile({required this.criterion});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Requirement: ${criterion.title}. ${criterion.desc}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: CivicPulseTheme.tertiaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 16, color: CivicPulseTheme.tertiaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(criterion.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600, color: const Color(0xFF191C1D))),
                  const SizedBox(height: 2),
                  Text(criterion.desc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CivicPulseTheme.outline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends ConsumerWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  const _DatePicker({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: ref.tr('age_check_title'),
      hint: ref.tr('select_dob'),
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: CivicPulseTheme.background,
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20, color: CivicPulseTheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(
                selectedDate == null ? ref.tr('select_dob') : DateFormat('dd MMM yyyy').format(selectedDate!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selectedDate == null ? CivicPulseTheme.outline : const Color(0xFF191C1D)),
              )),
              const Icon(Icons.arrow_drop_down, color: CivicPulseTheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool isEligible;
  final String message;
  const _ResultBanner({required this.isEligible, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = isEligible ? CivicPulseTheme.tertiaryContainer : Theme.of(context).colorScheme.error;
    return Semantics(
      label: 'Eligibility Result: $message',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(isEligible ? Icons.check_circle_outline : Icons.cancel_outlined, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final _RegStep step;
  final int index;
  final bool isLast;
  const _StepTile({required this.step, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    color: CivicPulseTheme.primary, shape: BoxShape.circle),
                  child: Icon(step.icon, color: Colors.white, size: 16),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: const Color(0xFFC3C6D1))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(step.title, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600, color: const Color(0xFF191C1D))),
                  const SizedBox(height: 4),
                  Text(step.desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CivicPulseTheme.outline)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
