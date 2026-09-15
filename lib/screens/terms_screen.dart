import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../runtime/models.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Terms and Conditions'),
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
              child: Builder(
                builder: (context) {
                  final theme = DesignTheme.of(context);
                  return _buildBody(context, theme);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DesignTheme theme) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last updated: September 2026',
                  style: AppTextStyles.caption(theme),
                ),
                const SizedBox(height: 16),
                Text(
                  'By using Crypto Trading App you agree to trade digital assets at your own risk. Cryptocurrency prices are volatile and past performance is not indicative of future results.',
                  style: AppTextStyles.body(theme),
                ),
                const SizedBox(height: 16),
                Text(
                  '1. Eligibility\nYou must be at least 18 years old and complete identity verification before trading.',
                  style: AppTextStyles.body(theme),
                ),
                const SizedBox(height: 16),
                Text(
                  '2. Fees\nTrading, deposit and withdrawal fees are disclosed before you confirm any transaction.',
                  style: AppTextStyles.body(theme),
                ),
                const SizedBox(height: 16),
                Text(
                  '3. Custody\nAssets held in your wallet are secured using industry-standard practices, but you are responsible for safeguarding your login credentials.',
                  style: AppTextStyles.body(theme),
                ),
                const SizedBox(height: 16),
                Text(
                  '4. Termination\nWe may suspend or close accounts that violate these terms or applicable law.',
                  style: AppTextStyles.body(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
