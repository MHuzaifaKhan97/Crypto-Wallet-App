import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class BankDetailsScreen extends ConsumerStatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bank Details'),
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
                    return _buildBody(context, theme, state);
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
  ) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBankAccountCard(context, theme, state),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add bank account lands in a future phase'),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: Button(
                  variant: 'Outlined',
                  label: 'Add Bank Account',
                  primaryColor: AppColors.brandIndigo,
                  radius: 999,
                  showIcon: true,
                  icon: 'add',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brandIndigo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
                  size: 20,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.bankAccountName,
                      style: AppTextStyles.body(theme),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Primary account',
                      style: AppTextStyles.caption(theme),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.check, size: 20, color: AppColors.gainGreen),
            ],
          ),
        ),
      ),
    );
  }
}
