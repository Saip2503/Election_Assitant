import 'package:flutter/material.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import 'shared_card_shell.dart';

class QuizWidget extends ConsumerStatefulWidget {
  final List<dynamic> questions;
  const QuizWidget({super.key, required this.questions});

  @override
  ConsumerState<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends ConsumerState<QuizWidget> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _score = 0;
  final int _streak = 3; // demo value

  void _submit() {
    if (_selectedAnswer == null) return;
    final correctIndex = widget.questions[_currentIndex]['answer_index'];
    if (_selectedAnswer == correctIndex) _score++;
    setState(() => _showExplanation = true);
  }

  void _next() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: CivicPulseTheme.secondary, size: 56),
                const SizedBox(height: 16),
                Text(ref.tr('quiz_complete'),
                  style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                    color: CivicPulseTheme.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(ref.tr('quiz_score', args: {'score': '$_score', 'total': '${widget.questions.length}'}),
                  style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(color: CivicPulseTheme.outline),
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () { Navigator.pop(ctx); },
                  style: FilledButton.styleFrom(
                    backgroundColor: CivicPulseTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: Text(ref.tr('close')),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();

    final question = widget.questions[_currentIndex];
    final options = List<String>.from(question['options']);
    final progress = _currentIndex / widget.questions.length;

    return CardShell(
      headerIcon: Icons.quiz_outlined,
      headerLabel: ref.tr('quiz_header'),
      title: ref.tr('quiz_module'),
      subtitle: ref.tr('quiz_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score & streak row ──
          Row(
            children: [
              _ScoreTile(icon: Icons.star_outline, label: ref.tr('current_score'), value: '${_score * 250}'),
              const SizedBox(width: 12),
              _ScoreTile(icon: Icons.local_fire_department_outlined, label: ref.tr('daily_streak'), value: ref.tr('days_streak', args: {'days': '$_streak'})),
            ],
          ),
          const SizedBox(height: 20),

          // ── Progress bar ──
          Row(
            children: [
              Text(ref.tr('question_count', args: {'current': '${_currentIndex + 1}', 'total': '${widget.questions.length}'}),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: CivicPulseTheme.outline)),
              const Spacer(),
              Semantics(
                liveRegion: true,
                label: 'Current score: $_score correct',
                child: Text('Score: $_score ✓',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CivicPulseTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFC3C6D1),
              valueColor: const AlwaysStoppedAnimation<Color>(CivicPulseTheme.secondary),
            ),
          ),
          const SizedBox(height: 24),

          // ── Question ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CivicPulseTheme.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CivicPulseTheme.primary.withValues(alpha: 0.12)),
            ),
            child: Text(
              question['question'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CivicPulseTheme.primary, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // ── Options ──
          ...List.generate(options.length, (i) {
            final isSelected = _selectedAnswer == i;
            final isCorrect = i == question['answer_index'];

            Color? bgColor;
            Color borderColor = const Color(0xFFC3C6D1);
            Color? textColor;
            Widget? trailingIcon;

            if (_showExplanation) {
              if (isCorrect) {
                bgColor = CivicPulseTheme.tertiaryContainer.withValues(alpha: 0.1);
                borderColor = CivicPulseTheme.tertiaryContainer;
                textColor = CivicPulseTheme.tertiaryContainer;
                trailingIcon = const Icon(Icons.check_circle, color: CivicPulseTheme.tertiaryContainer, size: 20);
              } else if (isSelected) {
                bgColor = Theme.of(context).colorScheme.error.withValues(alpha: 0.08);
                borderColor = Theme.of(context).colorScheme.error;
                textColor = Theme.of(context).colorScheme.error;
                trailingIcon = Icon(Icons.cancel, color: Theme.of(context).colorScheme.error, size: 20);
              }
            } else if (isSelected) {
              bgColor = CivicPulseTheme.primary.withValues(alpha: 0.06);
              borderColor = CivicPulseTheme.primary;
              textColor = CivicPulseTheme.primary;
            }

            return Semantics(
              button: !_showExplanation,
              selected: isSelected,
              label: 'Option ${String.fromCharCode(65 + i)}: ${options[i]}'
                  '${_showExplanation && isCorrect ? ". Correct answer" : ""}'
                  '${_showExplanation && isSelected && !isCorrect ? ". Your answer – incorrect" : ""}',
              child: GestureDetector(
                onTap: _showExplanation ? null : () => setState(() => _selectedAnswer = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: isSelected || (_showExplanation && isCorrect) ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      // Option letter
                      ExcludeSemantics(
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected && !_showExplanation ? CivicPulseTheme.primary : Colors.transparent,
                            border: Border.all(
                              color: isSelected || (_showExplanation && isCorrect) ? Colors.transparent : const Color(0xFFC3C6D1),
                            ),
                          ),
                          child: Center(child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: isSelected && !_showExplanation ? Colors.white : (textColor ?? CivicPulseTheme.outline)),
                          )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(options[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: textColor ?? const Color(0xFF191C1D),
                          height: 1.4))),
                      if (trailingIcon != null) ExcludeSemantics(child: trailingIcon!),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Explanation ──
          if (_showExplanation) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E3FF).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: CivicPulseTheme.primary, width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: CivicPulseTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(question['explanation'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF43474F), height: 1.5))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Submit / Next button ──
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedAnswer == null ? null : (_showExplanation ? _next : _submit),
              style: FilledButton.styleFrom(
                backgroundColor: _showExplanation ? CivicPulseTheme.secondary : CivicPulseTheme.primary,
                disabledBackgroundColor: const Color(0xFFC3C6D1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _showExplanation
                  ? (_currentIndex == widget.questions.length - 1 ? ref.tr('show_results') : ref.tr('next_question'))
                  : ref.tr('submit_answer'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ScoreTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CivicPulseTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC3C6D1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: CivicPulseTheme.secondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CivicPulseTheme.primary, fontWeight: FontWeight.w700)),
                  Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
