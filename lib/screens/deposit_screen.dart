import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../widgets/typed/numeric_keypad.dart';
import '../widgets/typed/amount_display.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
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

  void _onDepositSubmitButtonPressed() {
    final state = ref.read(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    appState.portfolioAvailable =
        (state.portfolioAvailable +
        exprNum(exprGet(_ctx, <String>['depositAmount'])));
    _ctx['state'] = ref.read(appStateProvider);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deposit successful')));
    context.go('/portfolio');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Deposit INR'),
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
          _buildDepositAmountDisplay(context, theme, _ctx),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: NumericKeypad(
              variant: 'Amount',
              accentColor: AppColors.brandIndigo,
              keyColor: AppColors.ink,
              value: state.depositAmount,
              onChanged: (v) => _handleInput('depositAmount', v),
              onItemTap: (i) => _handleEvent('n-6fqxp4av', 'qa:$i'),
              onCompositeEvent: (ev, [rowCtx]) =>
                  _handleEvent('n-6fqxp4av', ev, rowCtx),
              onSetVar: _handleInput,
            ),
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              if (exprTruthy(exprGet(_ctx, <String>['depositLoading']))) return;
              _onDepositSubmitButtonPressed();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Button(
                variant: 'Gradient',
                label: 'DEPOSIT',
                primaryColor: AppColors.brandIndigo,
                radius: 999,
                loading: exprTruthy(exprGet(_ctx, <String>['depositLoading'])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositAmountDisplay(
    BuildContext context,
    DesignTheme theme,
    Map<String, dynamic> _ctx,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            'Enter Amount in USD',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(theme),
          ),
          const SizedBox(height: 8),
          AmountDisplay(
            variant: 'Hero',
            currency: '\$',
            align: 'center',
            color: AppColors.ink,
            size: 40,
            rawProps: {
              'value': exprGet(_ctx, <String>['depositAmount']),
            },
            onItemTap: (i) => _handleEvent('n-p01yt96g', 'qa:$i'),
            onCompositeEvent: (ev, [rowCtx]) =>
                _handleEvent('n-p01yt96g', ev, rowCtx),
            onSetVar: _handleInput,
          ),
          const SizedBox(height: 8),
          Text(
            'Min \$10 • Max \$10,000',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(theme),
          ),
        ],
      ),
    );
  }
}
