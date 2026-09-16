import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../runtime/registry.dart';
import '../widgets/button.dart';
import '../widgets/page_carousel.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: unused_element_parameter
  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    switch ('$id::$event') {
      default:
        break;
    }
  }

  void _handleInput(String name, dynamic value) {
    ref.read(appStateProvider.notifier).setVar(name, value);
  }

  void _onOnboardingNextButtonPressed() {
    final state = ref.read(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    if ((state.onboardPage >= 2)) {
      appState.onboardingSeen = true;
      context.go('/signup');
    } else {
      appState.onboardPage = (state.onboardPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Builder(
                  builder: (context) {
                    final theme = DesignTheme.of(context);
                    return _buildBody(context, theme, state, appState, _ctx);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return SizedBox(
      width: double.infinity,
      height:
          (MediaQuery.sizeOf(context).height -
          EdgeInsets.fromViewPadding(
            View.of(context).viewPadding,
            View.of(context).devicePixelRatio,
          ).vertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: _buildOnboardingPager(context, theme, state),
          ),
          Expanded(
            flex: 2,
            child: _buildOnboardingActionsZone(context, state, appState, _ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPager(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: PageCarousel(
          pages: <Widget>[
            (MediaQuery.sizeOf(context).width >= 1024
                ? _buildTrackEveryMarket(context, theme)
                : _buildTrackEveryMarket2(context, theme)),
            _buildBuySellInstantly(context, theme),
            _buildEarnAsYouGrow(context, theme),
          ],
          loop: false,
          dotColor: AppColors.hairline,
          activeDotColor: AppColors.brandIndigo,
          overlayDots: true,
          initialPage: carouselPageIndex(state.onboardPage, 3),
          onPageChanged: (index) {
            _handleInput('onboardPage', index);
          },
        ),
      ),
    );
  }

  Widget _buildTrackEveryMarket(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 100, right: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NodeEntrance(
            effect: NodeEffect.scale,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradients['heroIndigoViolet'],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.bar_chart,
                size: 64,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 31),
          NodeEntrance(
            effect: NodeEffect.slideUp,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Track Every Market',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1(theme),
            ),
          ),
          const SizedBox(width: 31),
          NodeEntrance(
            effect: NodeEffect.slideUp,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 380),
            child: Text(
              'Real-time prices for Bitcoin, Ethereum and 100+ coins in one clean dashboard.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackEveryMarket2(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 100, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NodeEntrance(
            effect: NodeEffect.scale,
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradients['heroIndigoViolet'],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.bar_chart,
                size: 64,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(height: 31),
          NodeEntrance(
            effect: NodeEffect.slideUp,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Track Every Market',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading1(theme),
            ),
          ),
          const SizedBox(height: 31),
          NodeEntrance(
            effect: NodeEffect.slideUp,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 380),
            child: Text(
              'Real-time prices for Bitcoin, Ethereum and 100+ coins in one clean dashboard.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellInstantly(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 100, right: 24),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NodeEntrance(
              effect: NodeEffect.scale,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.gradients['heroIndigoViolet'],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  size: 64,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NodeEntrance(
              effect: NodeEffect.slideUp,
              duration: const Duration(milliseconds: 450),
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Buy & Sell Instantly',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1(theme),
              ),
            ),
            const SizedBox(height: 20),
            NodeEntrance(
              effect: NodeEffect.slideUp,
              duration: const Duration(milliseconds: 450),
              delay: const Duration(milliseconds: 380),
              child: Text(
                'Trade crypto in seconds with a simple, secure checkout.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnAsYouGrow(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 100, right: 24),
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NodeEntrance(
              effect: NodeEffect.scale,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.gradients['heroIndigoViolet'],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 64,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NodeEntrance(
              effect: NodeEffect.slideUp,
              duration: const Duration(milliseconds: 450),
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Earn As You Grow',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1(theme),
              ),
            ),
            const SizedBox(height: 20),
            NodeEntrance(
              effect: NodeEffect.slideUp,
              duration: const Duration(milliseconds: 450),
              delay: const Duration(milliseconds: 380),
              child: Text(
                'Referral rewards, spin bonuses and more — trading pays you back.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingActionsZone(
    BuildContext context,
    AppStateView state,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NodeEntrance(
            effect: NodeEffect.slideUp,
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PressScale(
                      onTap: () {
                        appState.onboardingSeen = true;
                        _ctx['state'] = ref.read(appStateProvider);
                        context.go('/login');
                      },
                      child: buildComponent(
                        ComponentModel.fromJson(<String, dynamic>{
                          'id': 'n-1b63li3e',
                          'type': 'Button',
                          'variant': 'Outlined',
                          'props': <String, dynamic>{
                            'label': 'Skip',
                            'primaryColor': 'token:inkMuted',
                            'radius': 24,
                            'fullWidth': false,
                            'flat': true,
                          },
                          'events': <String, dynamic>{'onTap': true},
                        }),
                        onItemTap: (i) => _handleEvent('n-1b63li3e', 'qa:$i'),
                        onCompositeEvent: (ev, [rowCtx]) =>
                            _handleEvent('n-1b63li3e', ev, rowCtx),
                        onSetVar: _handleInput,
                      ),
                    ),
                    PressScale(
                      onTap: _onOnboardingNextButtonPressed,
                      child: Button(
                        variant: 'Gradient',
                        label: strOrNull(
                          ((state.onboardPage >= 2) ? 'Get Started' : 'Next'),
                        ),
                        primaryColor: AppColors.brandIndigo,
                        radius: 24,
                        fullWidth: false,
                        showIcon: true,
                        icon: 'arrow_forward',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
