import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../runtime/registry.dart';
import '../widgets/text_input.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void _onSignupSubmitButtonPressed() {
    final appState = ref.read(appStateProvider.notifier);
    Map<String, dynamic> _ctx = <String, dynamic>{
      'state': ref.read(appStateProvider),
    };
    if (!(_formKey.currentState?.validate() ?? false)) return;
    appState.pendingAuthEmail = exprGet(_ctx, <String>['signupEmail']);
    _ctx['state'] = ref.read(appStateProvider);
    context.push('/otp');
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
                  top: 56,
                  right: 24,
                  left: 24,
                  child: _buildSignupHeader(context, theme),
                ),
                Positioned(
                  top: 210,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: _buildSignupCard(context, theme, state, _ctx),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupHeader(BuildContext context, DesignTheme theme) {
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
                'Create Your\nAccount',
                style: AppTextStyles.hexFFFFFF30w800(theme),
              ),
              const SizedBox(height: 6),
              Text(
                'Start trading crypto in minutes.',
                style: AppTextStyles.hexB3F8FAFC14w400(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(
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
                  _buildSignupForm(context, theme, state, _ctx),
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
                            'Already have an account?',
                            style: AppTextStyles.bodyMuted(theme),
                          ),
                          const SizedBox(width: 4),
                          PressScale(
                            onTap: () {
                              context.go('/login');
                            },
                            child: Text(
                              'Log in',
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

  Widget _buildSignupForm(
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
          _buildSignupNameInput(context, state),
          const SizedBox(height: 16),
          _buildSignupEmailInput(context, state),
          const SizedBox(height: 16),
          _buildSignupPhoneInput(context, state),
          const SizedBox(height: 16),
          _buildSignupPasswordInput(context, state),
          const SizedBox(height: 16),
          _buildSignupConfirmPasswordInput(context, state),
          const SizedBox(height: 16),
          _buildSignupTermsCheckbox(context, theme, state),
          if (((exprGet(_ctx, <String>['signupError']) != null) &&
              (exprGet(_ctx, <String>['signupError']) != '')))
            const SizedBox(height: 16),
          if (((exprGet(_ctx, <String>['signupError']) != null) &&
              (exprGet(_ctx, <String>['signupError']) != '')))
            Text(
              strOrEmpty(exprGet(_ctx, <String>['signupError'])),
              style: AppTextStyles.caption(theme),
            ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              if ((exprGet(_ctx, <String>['signupAgreeTerms']) == false) ||
                  exprTruthy(exprGet(_ctx, <String>['signupLoading'])))
                return;
              _onSignupSubmitButtonPressed();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: buildComponent(
                ComponentModel.fromJson(<String, dynamic>{
                  'id': 'n-fthgomi2',
                  'type': 'Button',
                  'variant': 'Gradient',
                  'props': <String, dynamic>{
                    'label': 'SIGN UP',
                    'primaryColor': 'token:brandIndigo',
                    'radius': 999,
                    'disabled':
                        (exprGet(_ctx, <String>['signupAgreeTerms']) == false),
                    'loading': exprGet(_ctx, <String>['signupLoading']),
                    'value': state.signupLoading,
                  },
                  'events': <String, dynamic>{'onTap': true},
                }),
                onChanged: (v) => _handleInput('signupLoading', v),
                onItemTap: (i) => _handleEvent('n-fthgomi2', 'qa:$i'),
                onCompositeEvent: (ev, [rowCtx]) =>
                    _handleEvent('n-fthgomi2', ev, rowCtx),
                onSetVar: _handleInput,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupNameInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.signupName,
      onChanged: (v) => _handleInput('signupName', v),
      validators: [
        {'kind': 'required'},
      ],
      label: 'Full name',
      placeholder: 'Jane Doe',
      leadingIcon: 'person',
      primaryColor: AppColors.brandIndigo,
      radius: 12,
      borderColor: AppColors.hairline,
      borderWidth: 1.5,
    );
  }

  Widget _buildSignupEmailInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.signupEmail,
      onChanged: (v) => _handleInput('signupEmail', v),
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

  Widget _buildSignupPhoneInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.signupPhone,
      onChanged: (v) => _handleInput('signupPhone', v),
      validators: [
        {'kind': 'required'},
      ],
      label: 'Phone',
      placeholder: '+1 555 000 0000',
      inputType: 'Phone',
      leadingIcon: 'phone',
      primaryColor: AppColors.brandIndigo,
      radius: 12,
      borderColor: AppColors.hairline,
      borderWidth: 1.5,
    );
  }

  Widget _buildSignupPasswordInput(BuildContext context, AppStateView state) {
    return TextInput(
      variant: 'Outlined',
      value: state.signupPassword,
      onChanged: (v) => _handleInput('signupPassword', v),
      validators: [
        {'kind': 'required'},
        {'kind': 'minLength', 'value': 8},
      ],
      label: 'Password',
      placeholder: 'At least 8 characters',
      inputType: 'Password',
      leadingIcon: 'lock',
      primaryColor: AppColors.brandIndigo,
      radius: 12,
      borderColor: AppColors.hairline,
      borderWidth: 1.5,
    );
  }

  Widget _buildSignupConfirmPasswordInput(
    BuildContext context,
    AppStateView state,
  ) {
    return TextInput(
      variant: 'Outlined',
      value: state.signupConfirmPassword,
      onChanged: (v) => _handleInput('signupConfirmPassword', v),
      validators: [
        {'kind': 'required'},
        {
          'kind': 'match',
          'value': 'signupPassword',
          'message': 'Passwords do not match',
        },
      ],
      label: 'Confirm password',
      placeholder: 'Re-enter your password',
      inputType: 'Password',
      leadingIcon: 'lock',
      primaryColor: AppColors.brandIndigo,
      radius: 12,
      borderColor: AppColors.hairline,
      borderWidth: 1.5,
    );
  }

  Widget _buildSignupTermsCheckbox(
    BuildContext context,
    DesignTheme theme,
    AppStateView state,
  ) {
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final v = !(state.signupAgreeTerms);
          _handleInput('signupAgreeTerms', v);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Transform.scale(
                scale: 20 / 18,
                child: Checkbox(
                  value: state.signupAgreeTerms,
                  onChanged: (_) {
                    final v = !(state.signupAgreeTerms);
                    _handleInput('signupAgreeTerms', v);
                  },
                  fillColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? AppColors.brandIndigo
                        : Colors.transparent,
                  ),
                  checkColor: const Color(0xFFFFFFFF),
                  side: BorderSide(color: theme.textSecondary, width: 2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'I agree to the Terms & Privacy Policy',
                style: AppTextStyles.inkMuted14w400(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
