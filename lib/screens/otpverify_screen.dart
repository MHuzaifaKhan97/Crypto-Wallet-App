import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/button.dart';
import '../widgets/typed/otp_input.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class OTPVerifyScreen extends ConsumerStatefulWidget {
  const OTPVerifyScreen({super.key});

  @override
  ConsumerState<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends ConsumerState<OTPVerifyScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  // ignore: unused_element_parameter
  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    final appState = ref.read(appStateProvider.notifier);
    switch ('$id::$event') {
      case 'n-k6aqd6yl::onCompleted':
        if (!(_formKey.currentState?.validate() ?? false)) return;
        appState.authToken = 'demo-token';
        context.go('/home');
        break;
      default:
        break;
    }
  }

  void _handleInput(String name, dynamic value) {
    ref.read(appStateProvider.notifier).setVar(name, value);
  }

  void _onOtpVerifyButtonPressed() {
    final appState = ref.read(appStateProvider.notifier);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    appState.authToken = 'demo-token';
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
    return AppTheme.scope(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Form(
                  key: _formKey,
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
          SizedBox(
            width: double.infinity,
            height:
                (MediaQuery.sizeOf(context).height -
                EdgeInsets.fromViewPadding(
                  View.of(context).viewPadding,
                  View.of(context).devicePixelRatio,
                ).vertical),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradients['heroIndigoViolet'],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 48,
                  left: 20,
                  child: PressScale(
                    onTap: () {
                      {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/signup');
                        }
                      }
                      ;
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                Positioned(
                  top: 96,
                  right: 24,
                  left: 24,
                  child: _buildOtpHeader(context, theme, state),
                ),
                Positioned(
                  top: 250,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: _buildOtpCard(context, theme, state, appState, _ctx),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpHeader(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check Your\nEmail',
              style: AppTextStyles.hexFFFFFF30w800(theme),
            ),
            const SizedBox(height: 6),
            Text(
              'We sent a 6-digit code to ${state.pendingAuthEmail}',
              style: AppTextStyles.hexB3F8FAFC14w400(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return NodeEntrance(
      effect: NodeEffect.fade,
      duration: const Duration(milliseconds: 450),
      delay: const Duration(milliseconds: 150),
      child: Padding(
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.only(
              left: 24,
              top: 32,
              right: 24,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1F000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOtpCodeBoxes(context, state),
                  if (((exprGet(_ctx, <String>['otpError']) != null) &&
                      (exprGet(_ctx, <String>['otpError']) != '')))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        strOrEmpty(exprGet(_ctx, <String>['otpError'])),
                        style: AppTextStyles.caption(theme),
                      ),
                    ),
                  _buildOtpVerifyButton(context, _ctx),
                  _buildOtpResendRow(context, theme, appState, _ctx),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpCodeBoxes(BuildContext context, AppStateView state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: OtpInput(
        variant: 'Boxed',
        length: 6,
        boxSize: 44,
        gap: 8,
        fontSize: 20,
        accentColor: AppColors.brandIndigo,
        borderColor: AppColors.hairline,
        fillColor: AppColors.surfaceAlt,
        textColor: AppColors.ink,
        value: state.otpCode,
        validators: [
          {'kind': 'required'},
          {
            'kind': 'minLength',
            'value': 6,
            'message': 'Enter the full 6-digit code',
          },
        ],
        eventKeys: const <String>{'onCompleted'},
        onChanged: (v) => _handleInput('otpCode', v),
        onItemTap: (i) => _handleEvent('n-k6aqd6yl', 'qa:$i'),
        onCompositeEvent: (ev, [rowCtx]) =>
            _handleEvent('n-k6aqd6yl', ev, rowCtx),
        onSetVar: _handleInput,
      ),
    );
  }

  Widget _buildOtpVerifyButton(
    BuildContext context,
    Map<String, dynamic> _ctx,
  ) {
    return PressScale(
      onTap: () {
        if (exprTruthy(exprGet(_ctx, <String>['otpLoading']))) return;
        _onOtpVerifyButtonPressed();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Button(
          variant: 'Gradient',
          label: 'VERIFY',
          primaryColor: AppColors.brandIndigo,
          radius: 999,
          loading: exprTruthy(exprGet(_ctx, <String>['otpLoading'])),
        ),
      ),
    );
  }

  Widget _buildOtpResendRow(
    BuildContext context,
    DesignTheme theme,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return NodeEntrance(
      effect: NodeEffect.fade,
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 450),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Didn\'t get a code?', style: AppTextStyles.bodyMuted(theme)),
            const SizedBox(width: 4),
            PressScale(
              onTap: () {
                appState.otpResent = true;
                _ctx['state'] = ref.read(appStateProvider);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Code resent')));
              },
              child: Text(
                strOrEmpty(
                  (exprTruthy(exprGet(_ctx, <String>['otpResent']))
                      ? 'Code sent'
                      : 'Resend'),
                ),
                style: AppTextStyles.body(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
