import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:share_plus/share_plus.dart';
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

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
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
        appBar: AppBar(
          title: Text('Refer and Earn'),
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
          _buildReferralStatsCard(context, theme, state),
          const SizedBox(height: 16),
          _buildReferralHeroCard(context, theme),
          const SizedBox(height: 16),
          _buildReferralLinkSection(context, theme, state, _ctx),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              Share.share(
                'https://cryptotradingapp.example.com/r/${exprGet(_ctx, <String>['referralCode'])}',
                subject: 'Join me on Crypto Trading App',
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: Button(
                  variant: 'Gradient',
                  label: 'SHARE NOW',
                  primaryColor: AppColors.brandIndigo,
                  radius: 999,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Terms and Conditions Applied',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStatsCard(
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
                    Text(
                      'Total Referrals',
                      style: AppTextStyles.caption(theme),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strOrEmpty(exprToFixed(state.referralCount, 0)),
                      style: AppTextStyles.figureMedium(theme),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qualified', style: AppTextStyles.caption(theme)),
                    const SizedBox(height: 4),
                    Text(
                      strOrEmpty(exprToFixed(state.referralQualified, 0)),
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

  Widget _buildReferralHeroCard(BuildContext context, DesignTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            gradient: AppColors.gradients['heroIndigoViolet'],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.card_giftcard,
                size: 28,
                color: const Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8),
              Text(
                'Refer and Earn Free Crypto',
                style: AppTextStyles.hexFFFFFF20w700(theme),
              ),
              const SizedBox(height: 8),
              Text(
                'Introducing Referral 2.0 — earn up to 100% of our fee from your referral\'s trades. Refer, share and earn.',
                style: AppTextStyles.hexCCFFFFFF13w400(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralLinkSection(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    Map<String, dynamic> _ctx,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Referral Link', style: AppTextStyles.heading2(theme)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.only(
                left: 16,
                top: 12,
                right: 12,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'https://coinova.example.com/r/${state.referralCode}',
                      style: AppTextStyles.caption(theme),
                    ),
                  ),
                  PressScale(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              'https://cryptotradingapp.example.com/r/${exprGet(_ctx, <String>['referralCode'])}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Referral link copied')),
                      );
                    },
                    child: Button(
                      variant: 'Filled',
                      label: 'Copy Code',
                      primaryColor: AppColors.brandIndigo,
                      radius: 999,
                      fullWidth: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
