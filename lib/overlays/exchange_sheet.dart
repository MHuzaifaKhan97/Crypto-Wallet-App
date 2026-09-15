import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../widgets/list_row.dart';
import '../theme/theme.dart';
import '../runtime/press_scale.dart';

/// The "Exchange Sheet" screen, shown as a bottom sheet.
class ExchangeSheet extends StatelessWidget {
  const ExchangeSheet({super.key, required this.onEvent});

  /// The host screen's `_handleEvent`: this overlay's own node events
  /// stay in that switch, compiled alongside the host's own.
  final void Function(String, String, [Map<String, dynamic>?]) onEvent;

  void _handleEvent(
    String nodeId,
    String event, [
    Map<String, dynamic>? item,
  ]) => onEvent(nodeId, event, item);

  @override
  Widget build(BuildContext context) {
    return AppTheme.scope(
      child: Builder(
        builder: (context) {
          final theme = DesignTheme.of(context);
          return _buildBody(context, theme);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DesignTheme theme) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 12, right: 20, bottom: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.hairline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Exchange', style: AppTextStyles.heading1(theme)),
          const SizedBox(height: 16),
          PressScale(
            onTap: () => _handleEvent('n-dluntwnw', 'onTap'),
            child: ListRow(
              variant: 'WithIcon',
              title: 'Send Crypto',
              subtitle: 'Send crypto from your wallet to another wallet',
              leadingIcon: 'arrow_up_right',
              iconColor: AppColors.brandIndigo,
            ),
          ),
          const SizedBox(height: 16),
          PressScale(
            onTap: () => _handleEvent('n-kzw3jokm', 'onTap'),
            child: ListRow(
              variant: 'WithIcon',
              title: 'Receive Crypto',
              subtitle: 'Receive crypto from another wallet to yours',
              leadingIcon: 'arrow_down_left',
              iconColor: AppColors.brandIndigo,
            ),
          ),
        ],
      ),
    );
  }
}
