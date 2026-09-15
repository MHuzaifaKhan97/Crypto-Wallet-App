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

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            exprStr(
              ((state.selectedCoin != null)
                  ? 'Sell ${exprPath(state.selectedCoin, <String>['symbol'])}'
                  : 'Sell'),
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
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSellAmountDisplay(context, theme, state, _ctx),
          const SizedBox(height: 16),
          _buildSellPercentChips(context, theme, state, appState),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: NumericKeypad(
              variant: 'Amount',
              accentColor: AppColors.lossRed,
              keyColor: AppColors.ink,
              value: state.sellAmount,
              onChanged: (v) => _handleInput('sellAmount', v),
              onItemTap: (i) => _handleEvent('n-oiag5b4k', 'qa:$i'),
              onCompositeEvent: (ev, [rowCtx]) =>
                  _handleEvent('n-oiag5b4k', ev, rowCtx),
              onSetVar: _handleInput,
            ),
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              if (exprTruthy(exprGet(_ctx, <String>['sellLoading']))) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Sell order placed')));
              context.go('/portfolio');
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Button(
                variant: 'Gradient',
                label: 'PREVIEW SELL',
                primaryColor: AppColors.lossRed,
                radius: 999,
                loading: exprTruthy(exprGet(_ctx, <String>['sellLoading'])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellAmountDisplay(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    Map<String, dynamic> _ctx,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Text(
            strOrEmpty(
              ((state.selectedCoin != null)
                  ? 'Enter Amount in ${exprPath(state.selectedCoin, <String>['symbol'])}'
                  : 'Enter Amount'),
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(theme),
          ),
          const SizedBox(height: 8),
          AmountDisplay(
            variant: 'Hero',
            currency: '',
            currencyPosition: 'none',
            align: 'center',
            color: AppColors.ink,
            size: 40,
            rawProps: {
              'value': exprGet(_ctx, <String>['sellAmount']),
            },
            onItemTap: (i) => _handleEvent('n-gtmj9upd', 'qa:$i'),
            onCompositeEvent: (ev, [rowCtx]) =>
                _handleEvent('n-gtmj9upd', ev, rowCtx),
            onSetVar: _handleInput,
          ),
          const SizedBox(height: 8),
          Text(
            strOrEmpty(
              ((state.selectedCoin != null)
                  ? 'Available ${exprPath(state.selectedCoin, <String>['qty'])} ${exprPath(state.selectedCoin, <String>['symbol'])}'
                  : ''),
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSellPercentChips(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSell25PctChip(context, theme, state, appState),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSell50PctChip(context, theme, state, appState),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PressScale(
                onTap: () {
                  appState.sellAmount = exprToFixed(
                    (exprNum(exprPath(state.selectedCoin, <String>['qty'])) *
                        0.75),
                    0,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '75%',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.inkMuted12w600(theme),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PressScale(
                onTap: () {
                  appState.sellAmount = exprToFixed(
                    exprNum(exprPath(state.selectedCoin, <String>['qty'])),
                    0,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '100%',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.inkMuted12w600(theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSell25PctChip(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
  ) {
    return PressScale(
      onTap: () {
        appState.sellAmount = exprToFixed(
          (exprNum(exprPath(state.selectedCoin, <String>['qty'])) * 0.25),
          0,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '25%',
          textAlign: TextAlign.center,
          style: AppTextStyles.inkMuted12w600(theme),
        ),
      ),
    );
  }

  Widget _buildSell50PctChip(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
  ) {
    return PressScale(
      onTap: () {
        appState.sellAmount = exprToFixed(
          (exprNum(exprPath(state.selectedCoin, <String>['qty'])) * 0.5),
          0,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '50%',
          textAlign: TextAlign.center,
          style: AppTextStyles.inkMuted12w600(theme),
        ),
      ),
    );
  }
}
