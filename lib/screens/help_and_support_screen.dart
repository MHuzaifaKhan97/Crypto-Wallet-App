import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../runtime/models.dart';
import '../widgets/list_row.dart';
import '../widgets/typed/info_banner.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/press_scale.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

class HelpAndSupportScreen extends ConsumerStatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  ConsumerState<HelpAndSupportScreen> createState() =>
      _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends ConsumerState<HelpAndSupportScreen> {
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
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Help & Support'),
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
              child: Builder(builder: (context) => _buildBody(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNeedHelpFast(context),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('FAQ lands in a future phase')),
              );
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Frequently Asked Questions',
              leadingIcon: 'help',
              iconColor: AppColors.brandIndigo,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactSupportRow(context),
          const SizedBox(height: 16),
          PressScale(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report an issue lands in a future phase'),
                ),
              );
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Report an Issue',
              leadingIcon: 'warning',
              iconColor: AppColors.brandIndigo,
            ),
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () async {
              try {
                await launchUrl(
                  Uri.parse('mailto:support@coinova.example.com'),
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {}
            },
            child: ListRow(
              variant: 'WithIcon',
              title: 'Email Us',
              subtitle: 'support@coinova.example.com',
              leadingIcon: 'email',
              iconColor: AppColors.brandIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpFast(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InfoBanner(
        variant: 'Info',
        title: 'Need help fast?',
        message: 'Our support team typically replies within a few hours.',
        icon: 'chat',
        accentColor: AppColors.brandIndigo,
        onItemTap: (i) => _handleEvent('n-bwkvc38z', 'qa:$i'),
        onCompositeEvent: (ev, [rowCtx]) =>
            _handleEvent('n-bwkvc38z', ev, rowCtx),
      ),
    );
  }

  Widget _buildContactSupportRow(BuildContext context) {
    return PressScale(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Support chat lands in a future phase')),
        );
      },
      child: ListRow(
        variant: 'WithIcon',
        title: 'Contact Support',
        subtitle: 'Chat with our team',
        leadingIcon: 'chat',
        iconColor: AppColors.brandIndigo,
      ),
    );
  }
}
