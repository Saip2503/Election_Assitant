import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_action_chips.dart';
import '../theme/civic_pulse_theme.dart';
import '../services/l10n_service.dart';
import '../widgets/language_selector.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Assistant', index: 0, l10nKey: 'chat'),
    _NavItem(icon: Icons.how_to_reg_outlined, label: 'Eligibility', index: 1, l10nKey: 'booth_finder'),
    _NavItem(icon: Icons.ballot_outlined, label: 'EVM Guide', index: 2, l10nKey: 'india_lok_sabha'),
    _NavItem(icon: Icons.edit_note_outlined, label: 'Updates', index: 3, l10nKey: 'results'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings', index: 4, l10nKey: 'language'),
    _NavItem(icon: Icons.feedback_outlined, label: 'Feedback', index: 5, l10nKey: 'footer_text'),
  ];

  void _sendMessage([String? predefinedText]) {
    final text = predefinedText ?? _controller.text;
    if (text.trim().isEmpty) return;

    final lang = ref.read(languageProvider);
    ref.read(chatProvider.notifier).sendMessage(text, lang);

    if (predefinedText == null) {
      _controller.clear();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final selectedLang = ref.watch(languageProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: CivicPulseTheme.background,
      body: Column(
        children: [
          // Top Header Bar
          _buildHeader(context, selectedLang),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      _buildSidebar(context),
                      _buildMainContent(context, messages, selectedLang),
                    ],
                  )
                : _buildMainContent(context, messages, selectedLang),
          ),
        ],
      ),
      // Bottom nav for mobile
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (i) {
                setState(() => _selectedNavIndex = i);
                if (i == 3) context.go('/results');
              },
              destinations: [
                NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), label: ref.tr('chat')),
                NavigationDestination(icon: const Icon(Icons.how_to_reg_outlined), label: ref.tr('booth_finder')),
                NavigationDestination(icon: const Icon(Icons.ballot_outlined), label: ref.tr('india_lok_sabha')),
                NavigationDestination(icon: const Icon(Icons.bar_chart), label: ref.tr('results')),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, String selectedLang) {
    return Container(
      height: 64,
      color: CivicPulseTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo/Brand
          Image.asset('assets/images/logo.webp', height: 40),
          const SizedBox(width: 12),
          Text(
            ref.tr('app_title'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            '  |  ${ref.tr('civic_pulse')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
          const Spacer(),
          const LanguageSelector(),
          const SizedBox(width: 16),
          // Dashboard button
          TextButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.dashboard_outlined, color: Colors.white, size: 18),
            label: Text(ref.tr('home'), style: const TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          const LanguageSelector(),
          const SizedBox(width: 16),
          // Results button
          TextButton.icon(
            onPressed: () => context.go('/results'),
            icon: const Icon(Icons.bar_chart, color: Colors.white, size: 18),
            label: Text(ref.tr('results'), style: const TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF001B38), // Deep navy sidebar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ..._navItems.map((item) => _SidebarNavItem(
                item: item,
                isSelected: _selectedNavIndex == item.index,
                onTap: () {
                  setState(() => _selectedNavIndex = item.index);
                  if (item.index == 3) context.go('/results');
                  if (item.index == 4) context.go('/dashboard'); // Settings redirect to home for now
                },
              )),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, messages, String selectedLang) {
    return Expanded(
      child: Column(
        children: [
          // Welcome / context bar
          if (messages.isEmpty) _buildWelcomeBanner(context, selectedLang),
          // Quick action chips
          QuickActionChips(onActionSelected: _sendMessage),
          // Chat messages
          Expanded(
            child: Semantics(
              label: 'Chat messages',
              liveRegion: true,
              child: messages.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: messages[index]);
                      },
                    ),
            ),
          ),
          // Input area
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String selectedLang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFFEBF0F8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CivicPulseTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline, color: CivicPulseTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedLang == 'hi' 
                  ? 'नमस्ते! मैं चुनाव दोस्त हूँ, आपका आधिकारिक नागरिक सहायक। आज चुनाव की तैयारी में मैं आपकी कैसे मदद कर सकता हूँ?'
                  : selectedLang == 'te'
                      ? 'నమస్తే! నేను ఎన్నికల దోస్త్, మీ అధికారిక సివిక్ అసిస్టెంట్. ఈ రోజు ఎన్నికలకు సిద్ధం కావడానికి నేను మీకు ఎలా సహాయం చేయగలను?'
                      : 'Namaste! I am Election Dost, your official civic assistant. How can I help you prepare for the upcoming elections today?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CivicPulseTheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.how_to_vote_outlined,
              size: 64, color: CivicPulseTheme.primary.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(
            ref.tr('chat_placeholder'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CivicPulseTheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try the quick actions above or type your question',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CivicPulseTheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              textField: true,
              label: 'Ask Election Dost a question',
              hint: ref.tr('chat_placeholder'),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: ref.tr('chat_placeholder'),
                  hintStyle: TextStyle(color: CivicPulseTheme.outline),
                  filled: true,
                  fillColor: CivicPulseTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: const BorderSide(color: CivicPulseTheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Send message',
            child: FilledButton(
              onPressed: () => _sendMessage(),
              style: FilledButton.styleFrom(
                backgroundColor: CivicPulseTheme.primary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                elevation: 0,
              ),
              child: const Icon(Icons.send, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  final String l10nKey;
  const _NavItem({required this.icon, required this.label, required this.index, required this.l10nKey});
}

class _SidebarNavItem extends ConsumerWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: ref.tr(item.l10nKey),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border(left: BorderSide(color: CivicPulseTheme.secondaryContainer, width: 3))
                : null,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  item.icon,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                ref.tr(item.l10nKey),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
