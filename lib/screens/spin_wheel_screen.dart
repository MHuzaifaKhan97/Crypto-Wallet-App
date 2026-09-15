import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _onSpinButtonPressed() {
    final state = ref.read(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    if ((state.remainingSpins > 0)) {
      appState.couponsWon = (state.couponsWon + 1);
      appState.remainingSpins = (state.remainingSpins - 1);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You won a coupon!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No spins left — come back later')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Spin Wheel'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          backgroundColor: parseHexColor(
            kDesignThemeSurface,
            const Color(0xFFFFFFFF),
          ),
          foregroundColor: parseHexColor(
            kDesignThemeTextPrimary,
            const Color(0xFF111827),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Builder(
                  builder: (context) {
                    final theme = DesignTheme.of(context);
                    return _buildBody(context, theme, state, _ctx);
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
    Map<String, dynamic> _ctx,
  ) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSpinStatsCard(context, theme, state),
          const SizedBox(height: 16),
          _buildSpinWheelVisual(context, theme),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              if ((state.remainingSpins <= 0) ||
                  exprTruthy(exprGet(_ctx, <String>['spinLoading'])))
                return;
              _onSpinButtonPressed();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: SizedBox(
                width: double.infinity,
                child: Button(
                  variant: 'Gradient',
                  label: strOrNull(
                    ((state.remainingSpins > 0)
                        ? 'SPIN THE WHEEL'
                        : 'NO SPINS LEFT'),
                  ),
                  primaryColor: AppColors.brandIndigo,
                  radius: 999,
                  disabled: (state.remainingSpins <= 0),
                  loading: exprTruthy(exprGet(_ctx, <String>['spinLoading'])),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Free tokens are credited instantly when you win. You can spin once per coupon, so come back and try your luck again!',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinStatsCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coupons Won', style: AppTextStyles.caption(theme)),
                    const SizedBox(height: 4),
                    Text(
                      strOrEmpty(exprToFixed(state.couponsWon, 0)),
                      style: AppTextStyles.figureMedium(theme),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spins Remaining',
                      style: AppTextStyles.caption(theme),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strOrEmpty(exprToFixed(state.remainingSpins, 0)),
                      style: AppTextStyles.figureMedium(theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinWheelVisual(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            gradient: AppColors.gradients['heroIndigoViolet'],
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F000000),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.star, size: 40, color: const Color(0xFFFFFFFF)),
              const SizedBox(height: 8),
              Text('SPIN', style: AppTextStyles.hexFFFFFF18w800(theme)),
            ],
          ),
        ),
      ),
    );
  }
}
