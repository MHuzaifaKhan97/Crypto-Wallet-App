import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/list_row.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleInput(String name, dynamic value) {
    ref.read(appStateProvider.notifier).setVar(name, value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Security'),
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
          PressScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Change password lands in a future phase'),
                ),
              );
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Change Password',
              leadingIcon: 'lock',
              iconColor: AppColors.brandIndigo,
            ),
          ),
          const SizedBox(height: 16),
          _buildBiometricRow(context, theme, state),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: AppColors.brandIndigo,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Two-Factor Authentication',
                        style: AppTextStyles.body(theme),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.twoFactorEnabled,
                  activeThumbColor: AppColors.brandIndigo,
                  onChanged: (v) {
                    _handleInput('twoFactorEnabled', v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login activity lands in a future phase'),
                ),
              );
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Login Activity',
              leadingIcon: 'history',
              iconColor: AppColors.brandIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricRow(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fingerprint, size: 20, color: AppColors.brandIndigo),
                const SizedBox(width: 12),
                Text('Biometric Login', style: AppTextStyles.body(theme)),
              ],
            ),
          ),
          Switch(
            value: state.biometricEnabled,
            activeThumbColor: AppColors.brandIndigo,
            onChanged: (v) {
              _handleInput('biometricEnabled', v);
            },
          ),
        ],
      ),
    );
  }
}
