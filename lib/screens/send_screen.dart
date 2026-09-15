import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../widgets/text_input.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            exprStr(
              ((state.selectedCoin != null)
                  ? 'Send ${exprPath(state.selectedCoin, <String>['symbol'])}'
                  : 'Send'),
            ),
          ),
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
                child: Form(
                  key: _formKey,
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
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSendAddressInput(context, state),
                const SizedBox(height: 16),
                _buildSendAmountInput(context, state),
                const SizedBox(height: 16),
                TextInput(
                  variant: 'Outlined',
                  value: state.sendNote,
                  onChanged: (v) => _handleInput('sendNote', v),
                  label: 'Note (optional)',
                  placeholder: 'What\'s this for?',
                  radius: 12,
                  borderColor: AppColors.hairline,
                  primaryColor: AppColors.brandIndigo,
                ),
                const SizedBox(height: 16),
                Text(
                  'Network fee: 0.0006 • Block time is calculated after broadcast',
                  style: AppTextStyles.caption(theme),
                ),
                const SizedBox(height: 16),
                PressScale(
                  onTap: () {
                    if (exprTruthy(exprGet(_ctx, <String>['sendLoading'])))
                      return;
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaction broadcast')),
                    );
                    context.go('/portfolio');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Button(
                      variant: 'Gradient',
                      label: 'SEND',
                      primaryColor: AppColors.brandIndigo,
                      radius: 999,
                      loading: exprTruthy(
                        exprGet(_ctx, <String>['sendLoading']),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendAddressInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.sendAddress,
      onChanged: (v) => _handleInput('sendAddress', v),
      validators: [
        {'kind': 'required'},
      ],
      label: 'Enter Address',
      placeholder: 'Wallet address',
      trailingIcon: 'qr',
      radius: 12,
      borderColor: AppColors.hairline,
      primaryColor: AppColors.brandIndigo,
    );
  }

  Widget _buildSendAmountInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.sendCryptoAmount,
      onChanged: (v) => _handleInput('sendCryptoAmount', v),
      validators: [
        {'kind': 'required'},
      ],
      label: 'Amount',
      placeholder: '0.00',
      inputType: 'Decimal',
      radius: 12,
      borderColor: AppColors.hairline,
      primaryColor: AppColors.brandIndigo,
      suffixText: strOrNull(
        ((state.selectedCoin != null)
            ? exprPath(state.selectedCoin, <String>['symbol'])
            : ''),
      ),
    );
  }
}
