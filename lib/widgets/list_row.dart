import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: ListRow — variants [WithIcon, NoIcon, Compact], props
/// [title:text, subtitle:text, leadingIcon:enum, iconColor:color,
/// trailingText:text, showChevron:toggle].
///
/// Ported from ksa_demo_app `lib/widgets/option_widget/option_widget.dart`
/// (a settings/menu list row with leading icon, title, and trailing chevron).
/// All AppTheme/SizeConfig/SVG/asset dependencies removed; icon resolved via
/// iconFromName() from catalog/icons.dart.
class ListRow extends StatelessWidget {
  final ComponentModel component;

  /// Readable-codegen entry (typed constructors, plan P4): named typed props
  /// → the same ComponentModel the registry path builds from JSON, so the
  /// internals below read `component.props` identically either way.
  ListRow({
    super.key,
    String variant = 'Classic',
    String? title,
    String? subtitle,
    String? leadingIcon,
    Color? iconColor,
    String? trailingText,
    bool? showChevron,
  }) : component = ComponentModel(
         id: '',
         type: 'ListRow',
         variant: variant,
         props: typedProps({
           'title': title,
           'subtitle': subtitle,
           'leadingIcon': leadingIcon,
           'iconColor': iconColor,
           'trailingText': trailingText,
           'showChevron': showChevron,
         }),
         bindings: const {},
       );

  /// Registry / interpreter entry — the node's parsed model as-is.
  const ListRow.fromModel({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final iconColor = parseHexColor(
      component.colorPropRaw('iconColor'),
      theme.primary,
    );
    final title = component.props['title'] is String
        ? component.props['title'] as String
        : 'Account settings';
    final subtitle = component.props['subtitle'] is String
        ? component.props['subtitle'] as String
        : '';
    final leadingIconName = component.props['leadingIcon'] is String
        ? component.props['leadingIcon'] as String
        : 'wallet';
    final trailingText = component.props['trailingText'] is String
        ? component.props['trailingText'] as String
        : '';
    final showChevron = component.toggleProp('showChevron', true);

    final isCompact = component.variant == 'Compact';
    final showIcon = component.variant != 'NoIcon';

    final double verticalPadding = isCompact ? 8.0 : 14.0;
    final double horizontalPadding = isCompact ? 12.0 : 16.0;
    final double iconBoxSize = isCompact ? 32.0 : 40.0;
    final double iconSize = isCompact ? 16.0 : 20.0;
    final double titleFontSize = isCompact ? 13.0 : 15.0;
    final double subtitleFontSize = isCompact ? 11.0 : 13.0;
    final double trailingFontSize = isCompact ? 12.0 : 14.0;
    final bool hasTrailingText = trailingText.isNotEmpty;
    final double radius = theme.radius.clamp(6.0, 20.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            if (showIcon) ...[
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(iconBoxSize / 2),
                ),
                child: Center(
                  child: catalogIcon(
                    leadingIconName,
                    color: iconColor,
                    size: iconSize,
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 10.0 : 12.0),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    // Capped ONLY when a value shares the row: two elastic
                    // columns of wrapping text read as a ragged block, and the
                    // value is the half a settings row is scanned for. With no
                    // value the title keeps its original free wrap, so no
                    // existing row (and no golden) moves a pixel.
                    maxLines: hasTrailingText ? 1 : null,
                    overflow: hasTrailingText ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (subtitle.isNotEmpty && !isCompact) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasTrailingText) ...[
              // Same pair of gaps the leading icon uses, so the React twin's
              // single flex `gap` covers both sides without a correction.
              SizedBox(width: isCompact ? 10.0 : 12.0),
              // Flexible, not Expanded: a short value ('GBP') takes only the
              // width it needs and stays glued to the chevron, while a long
              // one is capped at its flex share of the row and ellipsizes
              // there — an unconstrained Text next to the Expanded title is
              // the Row-overflow class this catalog keeps re-learning.
              Flexible(
                child: Text(
                  trailingText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // `end`, not `right`: the Row already mirrors under an RTL
                  // Directionality (setLocale), and a hard right would strand
                  // the value away from the chevron it belongs to.
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: trailingFontSize,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              // Tighter than the title gap above: the value and the chevron
              // are one affordance ("English ›"), not two columns.
              if (showChevron) const SizedBox(width: 4),
            ],
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B7280),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
