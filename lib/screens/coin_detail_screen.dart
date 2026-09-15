import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../widgets/list_row.dart';
import '../widgets/typed/amount_display.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';
import '../widgets/icons.dart';
import '../overlays/exchange_sheet.dart';

class CoinDetailScreen extends ConsumerStatefulWidget {
  const CoinDetailScreen({super.key});

  @override
  ConsumerState<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends ConsumerState<CoinDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: unused_element_parameter
  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    switch ('$id::$event') {
      case 'n-dluntwnw::onTap':
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        context.push('/send');
        break;
      case 'n-kzw3jokm::onTap':
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        context.push('/receive');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            exprStr(
              ((state.selectedCoin != null)
                  ? exprPath(state.selectedCoin, <String>['name'])
                  : 'Coin'),
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
          actions: [
            IconButton(
              icon: catalogIcon('exchange'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
                      ),
                      child: SingleChildScrollView(
                        child: SafeArea(
                          top: false,
                          child: ExchangeSheet(onEvent: _handleEvent),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
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
          _buildCoinDetailPriceRow(context, theme, state),
          const SizedBox(height: 16),
          _buildChartRangeChips(context, theme),
          const SizedBox(height: 16),
          _buildChartPlaceholder(context, theme),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              context.push('/history');
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Transactions',
              leadingIcon: 'history',
              iconColor: AppColors.brandIndigo,
            ),
          ),
          const SizedBox(height: 16),
          _buildCoinBuySellRow(context),
        ],
      ),
    );
  }

  Widget _buildCoinDetailPriceRow(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  parseGradient(
                        strOrNull(
                          ((state.selectedCoin != null)
                              ? exprPath(state.selectedCoin, <String>['color'])
                              : '#6366F1'),
                        ),
                      ) ==
                      null
                  ? parseHexColor(
                      strOrNull(
                        ((state.selectedCoin != null)
                            ? exprPath(state.selectedCoin, <String>['color'])
                            : '#6366F1'),
                      ),
                      const Color(0x00000000),
                    )
                  : null,
              gradient: parseGradient(
                strOrNull(
                  ((state.selectedCoin != null)
                      ? exprPath(state.selectedCoin, <String>['color'])
                      : '#6366F1'),
                ),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: AppImage.source(
              strOrEmpty(
                ((state.selectedCoin != null)
                    ? exprPath(state.selectedCoin, <String>['icon'])
                    : ''),
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmountDisplay(
              variant: 'Inline',
              currency: '\$',
              align: 'left',
              color: AppColors.ink,
              size: 26,
              rawProps: {
                'value': ((state.selectedCoin != null)
                    ? exprFormatNumber(
                        exprPath(state.selectedCoin, <String>['price']),
                        2,
                      )
                    : '0'),
              },
              onItemTap: (i) => _handleEvent('n-8le9wg74', 'qa:$i'),
              onCompositeEvent: (ev, [rowCtx]) =>
                  _handleEvent('n-8le9wg74', ev, rowCtx),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                catalogIcon(
                  strOrNull(
                    (((state.selectedCoin != null) &&
                            exprPath(state.selectedCoin, <String>['up']))
                        ? 'arrow_up_right'
                        : 'arrow_down_left'),
                  ),
                  size: 14,
                  color: parseHexColor(
                    strOrNull(
                      (((state.selectedCoin != null) &&
                              exprPath(state.selectedCoin, <String>['up']))
                          ? 'token:gainGreen'
                          : 'token:lossRed'),
                    ),
                    theme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  strOrEmpty(
                    ((state.selectedCoin == null)
                        ? ''
                        : (exprTruthy(
                                exprPath(state.selectedCoin, <String>['up']),
                              )
                              ? '+${exprPath(state.selectedCoin, <String>['change'])}%'
                              : '${exprPath(state.selectedCoin, <String>['change'])}%')),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: parseHexColor(
                      strOrNull(
                        (((state.selectedCoin != null) &&
                                exprPath(state.selectedCoin, <String>['up']))
                            ? 'token:gainGreen'
                            : 'token:lossRed'),
                      ),
                      theme.textPrimary,
                    ),
                    fontFamily: theme.fontFamily,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartRangeChips(BuildContext context, DesignTheme theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandIndigo,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('1H', style: AppTextStyles.hexFFFFFF12w600(theme)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('24H', style: AppTextStyles.inkMuted12w600(theme)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('1W', style: AppTextStyles.inkMuted12w600(theme)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('1M', style: AppTextStyles.inkMuted12w600(theme)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('1Y', style: AppTextStyles.inkMuted12w600(theme)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context, DesignTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 40, color: AppColors.brandIndigo),
            const SizedBox(height: 8),
            Text(
              'Live price chart lands in a future phase',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBuySellRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PressScale(
              onTap: () {
                context.push('/buy');
              },
              child: Button(
                variant: 'Filled',
                label: 'BUY',
                primaryColor: AppColors.gainGreen,
                radius: 999,
              ),
            ),
            const SizedBox(width: 12),
            PressScale(
              onTap: () {
                context.push('/sell');
              },
              child: Button(
                variant: 'Filled',
                label: 'SELL',
                primaryColor: AppColors.lossRed,
                radius: 999,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
