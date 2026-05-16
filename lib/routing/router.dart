import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_state.dart';

// Placeholder for screens
import '../presentation/screens/landing_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/analysis_screen.dart';
import '../presentation/screens/progress_screen.dart';
import '../presentation/screens/dass21_screen.dart';
import '../presentation/screens/companion_screen.dart';
import '../presentation/screens/consultation_screen.dart';
import '../presentation/screens/business_screen.dart';
import '../presentation/screens/calm_screen.dart';
import '../presentation/screens/safety_screen.dart';
import '../presentation/screens/relaxation_screen.dart';
import '../presentation/screens/community_screen.dart';
import '../presentation/screens/account_screen.dart';
import '../presentation/widgets/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

GoRouter createRouter(AppState appState) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: appState,
  redirect: (context, state) {
    final loggedIn = appState.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';
    final isLanding = state.matchedLocation == '/landing';

    if (!loggedIn && !isLoggingIn && !isLanding) {
      return '/landing';
    }
    if (loggedIn && (isLoggingIn || isLanding)) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/dass21',
          builder: (context, state) => const Dass21Screen(),
        ),
        GoRoute(
          path: '/companion',
          builder: (context, state) => const CompanionScreen(),
        ),
        GoRoute(
          path: '/consultation',
          builder: (context, state) => const ConsultationScreen(),
        ),
        GoRoute(
          path: '/business',
          builder: (context, state) => const BusinessScreen(),
        ),
        GoRoute(path: '/calm', builder: (context, state) => const CalmScreen()),
        GoRoute(
          path: '/safety',
          builder: (context, state) => const SafetyScreen(),
        ),
        GoRoute(
          path: '/relaxation',
          builder: (context, state) => const RelaxationScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
      ],
    ),
  ],
);
