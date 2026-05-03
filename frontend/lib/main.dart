import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/results_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/civic_pulse_theme.dart';
import 'providers/auth_provider.dart';

// ── Router provider ─────────────────────────────────────────────────────────
// Routes that anonymous (guest) users may access
const _guestRoutes = {'/chat', '/results', '/quiz', '/login'};

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggedIn = user != null;
      final isAnonymous = user?.isAnonymous ?? false;
      final isOnLogin = path == '/login';

      // Not logged in at all → force to login
      if (!isLoggedIn) {
        return isOnLogin ? null : '/login';
      }

      // Anonymous user trying to reach a restricted route → back to login
      if (isAnonymous && !_guestRoutes.contains(path)) {
        return '/login';
      }

      // Fully authenticated on login page → onboarding
      if (!isAnonymous && isOnLogin) {
        return '/onboarding';
      }

      // Anonymous on login page → send to chat
      if (isAnonymous && isOnLogin) {
        return '/chat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const QuizScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Simple helper to convert Provider notifications into Listenable for GoRouter
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    _subscription = ref.listen(authProvider, (_, __) => notifyListeners());
  }
  late final ProviderSubscription _subscription;
  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: ElectionAssistantApp(),
    ),
  );
}

class ElectionAssistantApp extends ConsumerWidget {
  const ElectionAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Election Dost – Civic Pulse',
      theme: CivicPulseTheme.themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
