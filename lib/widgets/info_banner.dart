import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: InfoBanner — variants [Info, Success, Warning], props
/// [title:text, message:text, icon:enum, accentColor:color].
///
/// Ported from ksa_demo_app
/// `lib/modules/personal_finance_manager/widget/info_card.dart`.
/// All AppTheme/SizeConfig dependencies removed; icon resolved via
/// iconFromName() from catalog/icons.dart; accent color falls back to
/// DesignTheme.primary when unset (Info variant only).
class InfoBanner extends StatelessWidget {
  final ComponentModel component;
  const InfoBanner({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);

    final title = component.props['title'] is String
        ? component.props['title'] as String
        : 'Heads up';
    final message = component.props['message'] is String
        ? component.props['message'] as String
        : 'Your statement is ready to view.';
    final iconName = component.props['icon'] is String
        ? component.props['icon'] as String
        : 'notifications';

    // Variant drives the accent color unless overridden by accentColor prop.
    final Color accentColor;
    switch (component.variant) {
      case 'Success':
        accentColor = const Color(0xFF10B981);
        break;
      case 'Warning':
        accentColor = const Color(0xFFF59E0B);
        break;
      default: // Info
        accentColor = parseHexColor(
          component.colorPropRaw('accentColor'),
          theme.primary,
        );
    }

    final bgColor = accentColor.withValues(alpha: 0.12);
    final double radius = theme.radius.clamp(8.0, 20.0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          catalogIcon(iconName, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                if (title.isNotEmpty && message.isNotEmpty)
                  const SizedBox(height: 4),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
