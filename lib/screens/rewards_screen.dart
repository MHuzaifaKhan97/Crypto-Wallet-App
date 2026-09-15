import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
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

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
          Text('Rewards', style: AppTextStyles.display(theme)),
          const SizedBox(height: 16),
          _buildRewardsStatsCard(context, theme, state),
          const SizedBox(height: 16),
          _buildReferAndEarnBanner(context, theme, state, _ctx),
          const SizedBox(height: 16),
          _buildSpinAndWinBanner(context, theme),
        ],
      ),
    );
  }

  Widget _buildRewardsStatsCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return SizedBox(
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
            Expanded(child: _buildReferrals(context, theme, state)),
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
                  Text('Spins Left', style: AppTextStyles.caption(theme)),
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
    );
  }

  Widget _buildReferrals(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Referrals', style: AppTextStyles.caption(theme)),
        const SizedBox(height: 4),
        Text(
          strOrEmpty(exprToFixed(state.referralCount, 0)),
          style: AppTextStyles.figureMedium(theme),
        ),
      ],
    );
  }

  Widget _buildReferAndEarnBanner(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    Map<String, dynamic> _ctx,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradients['heroIndigoViolet'],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.card_giftcard, size: 28, color: const Color(0xFFFFFFFF)),
            const SizedBox(height: 8),
            Text('Refer & Earn', style: AppTextStyles.hexFFFFFF18w700(theme)),
            const SizedBox(height: 8),
            Text(
              'Invite friends and earn free crypto for every signup.',
              style: AppTextStyles.hexCCFFFFFF13w400(theme),
            ),
            const SizedBox(height: 8),
            _buildReferralCodeChip(context, theme, state, _ctx),
            const SizedBox(height: 8),
            PressScale(
              onTap: () {
                context.push('/referral');
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Button(
                  variant: 'Filled',
                  label: 'Refer Now',
                  primaryColor: const Color(0xFFFFFFFF),
                  labelColor: AppColors.brandIndigo,
                  radius: 999,
                  fullWidth: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeChip(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    Map<String, dynamic> _ctx,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.referralCode,
                style: AppTextStyles.hexFFFFFF14w700(theme),
              ),
              PressScale(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: exprGet(_ctx, <String>['referralCode']),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Referral code copied')),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: const Color(0xFFFFFFFF),
                    ),
                    const SizedBox(width: 4),
                    Text('Copy', style: AppTextStyles.hexFFFFFF13w600(theme)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinAndWinBanner(BuildContext context, DesignTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accentAmber,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.star, size: 28, color: AppColors.accentStrong),
            const SizedBox(height: 8),
            Text('Spin & Win', style: AppTextStyles.accentStrong18w700(theme)),
            const SizedBox(height: 8),
            Text(
              'Spin the wheel for a chance to win free tokens.',
              style: AppTextStyles.accentStrong13w400(theme),
            ),
            const SizedBox(height: 8),
            PressScale(
              onTap: () {
                context.push('/spin');
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Button(
                  variant: 'Filled',
                  label: 'Spin Now',
                  primaryColor: const Color(0xFFFFFFFF),
                  labelColor: AppColors.accentAmber,
                  radius: 999,
                  fullWidth: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
