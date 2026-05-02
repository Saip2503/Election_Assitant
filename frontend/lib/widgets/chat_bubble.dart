import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../theme/civic_pulse_theme.dart';
import 'eligibility_card.dart';
import 'evm_walkthrough_widget.dart';
import 'quiz_widget.dart';
import 'form8_card.dart';
import 'booth_finder_card.dart';
import 'candidate_card.dart';
import 'official_links_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Message from ${message.isUser ? 'You' : 'Election Dost'}',
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble
            MergeSemantics(
              child: Row(
                mainAxisAlignment:
                    message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser) ...[
                    // Avatar for assistant
                    ExcludeSemantics(
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 8, top: 2),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/assistant_avatar.webp'),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? CivicPulseTheme.primary
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                          bottomRight: Radius.circular(message.isUser ? 4 : 16),
                        ),
                        border: message.isUser
                            ? null
                            : Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.6),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: CivicPulseTheme.primary.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: message.isUser ? Colors.white : const Color(0xFF191C1D),
                              height: 1.5,
                            ),
                      ),
                    ),
                  ),
                  if (message.isUser) ...[
                    // Avatar for user
                    ExcludeSemantics(
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(left: 8, top: 2),
                        decoration: BoxDecoration(
                          color: CivicPulseTheme.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline,
                            color: CivicPulseTheme.primary, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Interactive widget
            if (message.intent != null) ...[
              const SizedBox(height: 12),
              _buildInteractiveWidget(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveWidget(BuildContext context) {
    switch (message.intent) {
      case 'eligibility_check':
      case 'form6':
        return EligibilityCard();
      case 'form8':
        return Form8Card();
      case 'evm_walkthrough':
        return EVMWalkthroughWidget();
      case 'booth_finder':
        return BoothFinderCard();
      case 'candidates':
        if (message.payload != null && message.payload!['candidates'] != null) {
          return CandidateCard(candidates: message.payload!['candidates']);
        }
        return const SizedBox.shrink();
      case 'quiz':
        if (message.payload != null && message.payload!['questions'] != null) {
          return QuizWidget(questions: message.payload!['questions']);
        }
        return const SizedBox.shrink();
      case 'official_links':
        return const OfficialLinksCard();
      default:
        return const SizedBox.shrink();
    }
  }
}
