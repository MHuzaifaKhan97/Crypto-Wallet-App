import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'runtime/url_strategy_stub.dart'
    if (dart.library.js) 'runtime/url_strategy_web.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_client.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otpverify_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/market_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/coin_detail_screen.dart';
import 'screens/buy_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/withdraw_screen.dart';
import 'screens/send_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/search_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/spin_wheel_screen.dart';
import 'screens/history_screen.dart';
import 'screens/bank_details_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/security_screen.dart';
import 'screens/help_and_support_screen.dart';
import 'screens/terms_screen.dart';

final ProviderContainer appContainer = ProviderContainer();

void main() {
  configureUrlStrategy();
  initApiClients(appContainer);
  runApp(
    UncontrolledProviderScope(
      container: appContainer,
      child: const DesignApp(),
    ),
  );
}

const double kStudioXBpMd = 768;
const double kStudioXBpLg = 1024;
// The document's default route transition ('' = the width-tiered pair).
const String kStudioXNavTransition = '';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    if (state.uri.path.endsWith('/index.html')) return '/';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _Shell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  _page(context, state, const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/portfolio',
              pageBuilder: (context, state) =>
                  _page(context, state, const PortfolioScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/market',
              pageBuilder: (context, state) =>
                  _page(context, state, const MarketScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rewards',
              pageBuilder: (context, state) =>
                  _page(context, state, const RewardsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  _page(context, state, const ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _page(context, state, const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _page(context, state, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          _page(context, state, const SignupScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _page(context, state, const LoginScreen()),
    ),
    GoRoute(
      path: '/otp',
      pageBuilder: (context, state) =>
          _page(context, state, const OTPVerifyScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) =>
          _page(context, state, const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/coin-detail',
      pageBuilder: (context, state) =>
          _page(context, state, const CoinDetailScreen()),
    ),
    GoRoute(
      path: '/buy',
      pageBuilder: (context, state) => _page(context, state, const BuyScreen()),
    ),
    GoRoute(
      path: '/sell',
      pageBuilder: (context, state) =>
          _page(context, state, const SellScreen()),
    ),
    GoRoute(
      path: '/deposit',
      pageBuilder: (context, state) =>
          _page(context, state, const DepositScreen()),
    ),
    GoRoute(
      path: '/withdraw',
      pageBuilder: (context, state) =>
          _page(context, state, const WithdrawScreen()),
    ),
    GoRoute(
      path: '/send',
      pageBuilder: (context, state) =>
          _page(context, state, const SendScreen()),
    ),
    GoRoute(
      path: '/receive',
      pageBuilder: (context, state) =>
          _page(context, state, const ReceiveScreen()),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) =>
          _page(context, state, const SearchScreen()),
    ),
    GoRoute(
      path: '/referral',
      pageBuilder: (context, state) =>
          _page(context, state, const ReferralScreen()),
    ),
    GoRoute(
      path: '/spin',
      pageBuilder: (context, state) =>
          _page(context, state, const SpinWheelScreen()),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) =>
          _page(context, state, const HistoryScreen()),
    ),
    GoRoute(
      path: '/bank-details',
      pageBuilder: (context, state) =>
          _page(context, state, const BankDetailsScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _page(context, state, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/security',
      pageBuilder: (context, state) =>
          _page(context, state, const SecurityScreen()),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) =>
          _page(context, state, const HelpAndSupportScreen()),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) =>
          _page(context, state, const TermsScreen()),
    ),
  ],
);

/// The shared page transition for every route in this app.
///
/// The kind is decided per swap: a navigate step that authored its own
/// `transition` passes it through the route's `extra`; otherwise the
/// document's `navTransition` (baked below as [kStudioXNavTransition]);
/// otherwise the width-tiered legacy pair — wide surfaces (>= [kStudioXBpMd])
/// get a short fade, phones a slightly longer fade with a subtle upward
/// slide. Change the document default and every route changes with it.
Page<void> _page(BuildContext context, GoRouterState state, Widget child) {
  final Object? extra = state.extra;
  final String authored = (extra is Map && extra['studioXTransition'] is String)
      ? extra['studioXTransition'] as String
      : kStudioXNavTransition;
  if (authored == 'none') {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  final bool wide = MediaQuery.sizeOf(context).width >= kStudioXBpMd;
  final String kind = authored.isEmpty
      ? (wide ? 'fade' : 'fadeSlide')
      : authored;
  final int ms = kind == 'fade'
      ? 150
      : kind == 'fadeSlide'
      ? 260
      : 300;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: ms),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      switch (kind) {
        case 'fade':
          return FadeTransition(opacity: curved, child: child);
        case 'slide':
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        case 'slideUp':
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        default: // fadeSlide
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
      }
    },
  );
}

class DesignApp extends StatelessWidget {
  const DesignApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    builder: (context, child) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child ?? const SizedBox.shrink(),
    ),
    title: 'Crypto Trading App',
    theme: buildDesignTheme(),
    scrollBehavior: const _AppScrollBehavior(),
    routerConfig: _router,
  );
}

class _Shell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _Shell({required this.navigationShell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Portfolio',
        ),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Market'),
        NavigationDestination(
          icon: Icon(Icons.card_giftcard),
          label: 'Rewards',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
