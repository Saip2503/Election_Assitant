import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/civic_pulse_theme.dart';
import '../widgets/quiz_widget.dart';
import '../services/api_service.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final _quizQuestionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ApiService.fetchQuizQuestions();
});

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(_quizQuestionsProvider);

    return Scaffold(
      backgroundColor: CivicPulseTheme.background,
      appBar: AppBar(
        backgroundColor: CivicPulseTheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.quiz_outlined, size: 22),
            SizedBox(width: 10),
            Text('Election Literacy Challenge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
            label: const Text('Ask Dost', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: quizAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: CivicPulseTheme.secondary),
              SizedBox(height: 16),
              Text('Loading Quiz…', style: TextStyle(color: CivicPulseTheme.outline)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: CivicPulseTheme.outline),
              const SizedBox(height: 16),
              Text('Could not load quiz: $e',
                  style: const TextStyle(color: CivicPulseTheme.outline)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(_quizQuestionsProvider),
                style: FilledButton.styleFrom(backgroundColor: CivicPulseTheme.primary),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (questions) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CivicPulseTheme.primary.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CivicPulseTheme.secondary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events,
                              color: CivicPulseTheme.secondary, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text('Civic Literacy Quiz',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: CivicPulseTheme.primary,
                                  fontWeight: FontWeight.w800,
                                )),
                        const SizedBox(height: 8),
                        Text(
                          '${questions.length} Questions • Indian Elections & Democracy',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CivicPulseTheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  QuizWidget(questions: questions),
                  const SizedBox(height: 32),
                  // Footer
                  Text(
                    'Questions sourced from ECI official guidelines.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CivicPulseTheme.outline,
                          fontStyle: FontStyle.italic,
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
