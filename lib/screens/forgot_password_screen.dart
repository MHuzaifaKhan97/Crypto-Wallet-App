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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
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
                          context.go('/login');
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
                  child: _buildForgotHeader(context, theme),
                ),
                Positioned(
                  top: 250,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: _buildForgotCard(
                    context,
                    theme,
                    state,
                    appState,
                    _ctx,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotHeader(BuildContext context, DesignTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Your\nPassword',
            style: AppTextStyles.hexFFFFFF30w800(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return SizedBox(
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
              if ((exprGet(_ctx, <String>['forgotSent']) == false))
                _buildEnterTheEmailOn(context, theme),
              if ((exprGet(_ctx, <String>['forgotSent']) == false))
                _buildForgotEmailInput(context, state),
              if ((exprGet(_ctx, <String>['forgotSent']) == false))
                _buildForgotSubmitButton(context, appState, _ctx),
              if ((exprGet(_ctx, <String>['forgotSent']) == true))
                _buildForgotSuccessState(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterTheEmailOn(BuildContext context, DesignTheme theme) {
    return NodeEntrance(
      effect: NodeEffect.fade,
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Enter the email on your account and we\'ll send you a reset link.',
          style: AppTextStyles.bodyMuted(theme),
        ),
      ),
    );
  }

  Widget _buildForgotEmailInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.forgotEmail,
      onChanged: (v) => _handleInput('forgotEmail', v),
      validators: [
        {'kind': 'required'},
        {'kind': 'email'},
      ],
      label: 'Email',
      placeholder: 'you@example.com',
      inputType: 'Email',
      leadingIcon: 'email',
      primaryColor: AppColors.brandIndigo,
      radius: 12,
      borderColor: AppColors.hairline,
      borderWidth: 1.5,
    );
  }

  Widget _buildForgotSubmitButton(
    BuildContext context,
    AppStateNotifier appState,
    Map<String, dynamic> _ctx,
  ) {
    return PressScale(
      onTap: () {
        if (exprTruthy(exprGet(_ctx, <String>['forgotLoading']))) return;
        if (!(_formKey.currentState?.validate() ?? false)) return;
        appState.forgotSent = true;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Button(
          variant: 'Gradient',
          label: 'SEND RESET LINK',
          primaryColor: AppColors.brandIndigo,
          radius: 999,
          loading: exprTruthy(exprGet(_ctx, <String>['forgotLoading'])),
        ),
      ),
    );
  }

  Widget _buildForgotSuccessState(BuildContext context, DesignTheme theme) {
    return NodeEntrance(
      effect: NodeEffect.scale,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      child: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.gainGreen,
            ),
            const SizedBox(height: 12),
            Text(
              'Reset link sent — check your inbox.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(theme),
            ),
            const SizedBox(height: 12),
            PressScale(
              onTap: () {
                context.go('/login');
              },
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Button(
                    variant: 'Gradient',
                    label: 'BACK TO LOGIN',
                    primaryColor: AppColors.brandIndigo,
                    radius: 999,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
