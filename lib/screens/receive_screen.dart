import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:share_plus/share_plus.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../widgets/typed/qr_code.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
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
                  ? 'Receive ${exprPath(state.selectedCoin, <String>['symbol'])}'
                  : 'Receive'),
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
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Scan the QR code to get the receive address',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted(theme),
                  ),
                ),
                const SizedBox(height: 16),
                QRCode(
                  variant: 'Card',
                  dataProp: state.receiveAddress,
                  size: 200,
                  rawProps: {
                    'caption': ((state.selectedCoin != null)
                        ? 'Your ${exprPath(state.selectedCoin, <String>['symbol'])} Address'
                        : 'Your Address'),
                  },
                  onItemTap: (i) => _handleEvent('n-z25nfk36', 'qa:$i'),
                  onCompositeEvent: (ev, [rowCtx]) =>
                      _handleEvent('n-z25nfk36', ev, rowCtx),
                ),
                const SizedBox(height: 16),
                _buildReceiveAddressChip(context, theme, state),
                const SizedBox(height: 16),
                _buildCopyAddressButton(context, _ctx),
                const SizedBox(height: 16),
                PressScale(
                  onTap: () {
                    Share.share(exprGet(_ctx, <String>['receiveAddress']));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: Button(
                        variant: 'Gradient',
                        label: 'SHARE ADDRESS',
                        primaryColor: AppColors.brandIndigo,
                        radius: 999,
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

  Widget _buildReceiveAddressChip(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          state.receiveAddress,
          textAlign: TextAlign.center,
          style: AppTextStyles.inkMuted13w400(theme),
        ),
      ),
    );
  }

  Widget _buildCopyAddressButton(
    BuildContext context,
    Map<String, dynamic> _ctx,
  ) {
    return PressScale(
      onTap: () {
        Clipboard.setData(
          ClipboardData(text: exprGet(_ctx, <String>['receiveAddress'])),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Address copied')));
      },
      child: SizedBox(
        width: double.infinity,
        child: Button(
          variant: 'Outlined',
          label: 'Copy Address',
          primaryColor: AppColors.brandIndigo,
          radius: 999,
          showIcon: true,
          icon: 'copy',
        ),
      ),
    );
  }
}
