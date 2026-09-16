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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _handleInput(String name, dynamic value) {
    ref.read(appStateProvider.notifier).setVar(name, value);
  }

  void _onLoginSubmitButtonPressed() {
    final appState = ref.read(appStateProvider.notifier);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    appState.authToken = 'demo-token';
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
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
                  top: 64,
                  right: 24,
                  left: 24,
                  child: _buildLoginHeader(context, theme),
                ),
                Positioned(
                  top: 236,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: _buildLoginCard(context, theme, state, _ctx),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeader(BuildContext context, DesignTheme theme) {
    return NodeEntrance(
      effect: NodeEffect.slideDown,
      duration: const Duration(milliseconds: 400),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome\nBack',
                style: AppTextStyles.hexFFFFFF34w800(theme),
              ),
              const SizedBox(height: 6),
              Text(
                'Log in to continue trading.',
                style: AppTextStyles.hexB3F8FAFC14w400(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
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
              top: 36,
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
                  _buildLoginForm(context, theme, state, _ctx),
                  NodeEntrance(
                    effect: NodeEffect.fade,
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 450),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New here?',
                            style: AppTextStyles.bodyMuted(theme),
                          ),
                          const SizedBox(width: 4),
                          PressScale(
                            onTap: () {
                              context.go('/signup');
                            },
                            child: Text(
                              'Create an account',
                              style: AppTextStyles.body(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
    Map<String, dynamic> _ctx,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoginEmailInput(context, state),
          const SizedBox(height: 16),
          TextInput(
            variant: 'Outlined',
            value: state.loginPassword,
            onChanged: (v) => _handleInput('loginPassword', v),
            validators: [
              {'kind': 'required'},
            ],
            label: 'Password',
            placeholder: 'Your password',
            inputType: 'Password',
            leadingIcon: 'lock',
            primaryColor: AppColors.brandIndigo,
            radius: 12,
            borderColor: AppColors.hairline,
            borderWidth: 1.5,
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              context.push('/forgot-password');
            },
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Forgot password?',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMuted(theme),
              ),
            ),
          ),
          if (((exprGet(_ctx, <String>['loginError']) != null) &&
              (exprGet(_ctx, <String>['loginError']) != '')))
            const SizedBox(height: 16),
          if (((exprGet(_ctx, <String>['loginError']) != null) &&
              (exprGet(_ctx, <String>['loginError']) != '')))
            Text(
              strOrEmpty(exprGet(_ctx, <String>['loginError'])),
              style: AppTextStyles.caption(theme),
            ),
          const SizedBox(height: 16),
          PressScale(
            onTap: _onLoginSubmitButtonPressed,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Button(
                variant: 'Gradient',
                label: 'SIGN IN',
                primaryColor: AppColors.brandIndigo,
                radius: 999,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginEmailInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.loginEmail,
      onChanged: (v) => _handleInput('loginEmail', v),
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
}
