import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(appStateProvider);
      if (((state.authToken != null) && (state.authToken != ''))) {
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) context.go('/home');
        });
      } else {
        if ((state.onboardingSeen == true)) {
          Future.delayed(const Duration(milliseconds: 1600), () {
            if (mounted) context.go('/login');
          });
        } else {
          Future.delayed(const Duration(milliseconds: 1600), () {
            if (mounted) context.go('/onboarding');
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.scope(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Builder(
                builder: (context) {
                  final theme = DesignTheme.of(context);
                  return _buildBody(context, theme);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DesignTheme theme) {
    return SizedBox(
      width: double.infinity,
      height:
          (MediaQuery.sizeOf(context).height -
          MediaQuery.viewPaddingOf(context).vertical),
      child: Stack(
        children: [
          _buildBrandMark(context, theme),
          Positioned(
            right: 0,
            bottom: 56,
            left: 0,
            child: NodeEntrance(
              effect: NodeEffect.fade,
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 450),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: const Color(0x00000000),
                  child: Text(
                    'Trade Smarter, Anytime, Anywhere',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(theme),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandMark(BuildContext context, DesignTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NodeEntrance(
              effect: NodeEffect.scale,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.gradients['heroIndigoViolet'],
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1F000000),
                      blurRadius: 24,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bar_chart,
                  size: 40,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NodeEntrance(
              effect: NodeEffect.slideUp,
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 200),
              child: Text(
                'CRYPTO TRADING APP',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
