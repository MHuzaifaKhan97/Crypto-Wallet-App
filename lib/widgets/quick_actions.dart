import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// KSA re-skin: maps ksa_demo_app's SendAndAddOptionWidget pattern to
/// Studio X catalog. Each action = Material icon in a soft primary-tinted
/// rounded square, label in textSecondary below, actions spread evenly.
/// Catalog NAMES, not Icons.* constants: a tile's icon is resolved at the
/// render sites with catalogIcon, so an authored tile can also carry an
/// uploaded image ref. 'send'/'request'/'transfer' resolve to the same
/// north_east/south_west/swap_horiz glyphs these defaults always drew.
const _kActions = [
  ('send', 'Send'),
  ('request', 'Request'),
  ('transfer', 'Transfer'),
  ('add', 'Top up'),
];

/// Design Mode v2 (Pillar 2/3): a QuickActions node may carry its tiles at
/// `props.items` — a List of maps `{ id, icon, label, onTap }` — so the tiles
/// are data-driven per-project rather than the hardcoded KSA demo set. When
/// `items` is absent/empty (older documents, or the widget dropped on a blank
/// canvas), the original `_kActions` defaults are used so nothing regresses.
List<(String?, String)> _resolveActions(ComponentModel component) {
  final raw = component.props['items'];
  if (raw is List && raw.isNotEmpty) {
    return raw.map((e) {
      final map = (e as Map).cast<String, dynamic>();
      return (map['icon'] as String?, (map['label'] as String?) ?? '');
    }).toList();
  }
  return _kActions;
}

/// Manifest: QuickActions — variants [Classic, Horizontal, Minimal],
/// props [primaryColor:color, radius:number, items:list].
class QuickActions extends StatelessWidget {
  final ComponentModel component;

  /// Fires with the tapped tile's index. The host does not interpret the
  /// tile's `onTap` action data itself — it only dispatches (see node_view.dart
  /// buildNode → onEvent(node.id, 'qa:$i', ...)); the generated screen's event
  /// handler is what actually runs the action steps.
  final ValueChanged<int>? onItemTap;
  const QuickActions({super.key, required this.component, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    // P12 (global theme): same override-wins-over-theme pattern as BalanceCard.
    final theme = DesignTheme.of(context);
    final color = parseHexColor(
      component.colorPropRaw('primaryColor'),
      theme.primary,
    );
    final radius = component.numberPropRaw('radius') ?? theme.radius;
    final actions = _resolveActions(component);

    switch (component.variant) {
      case 'Horizontal':
        // Horizontal scrolling pill chips — brand-tinted background, icon + label inline.
        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final (icon, label) = actions[i];
              return Material(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(radius),
                child: InkWell(
                  onTap: onItemTap == null ? null : () => onItemTap!(i),
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        catalogIcon(icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );

      case 'Minimal':
        // Minimal: bare icon + label, no container — understated utility row,
        // still brand-colored icons so it reads as premium rather than muted.
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(actions.length, (i) {
            final (icon, label) = actions[i];
            // Flexible (loose) + ellipsis: tiles keep their natural width
            // while they fit; an authored label wider than its share of the
            // row shrinks and ellipsizes instead of overflowing.
            return Flexible(
              child: InkWell(
                onTap: onItemTap == null ? null : () => onItemTap!(i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      catalogIcon(icon, size: 22, color: color),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );

      default: // Classic — premium surface card of brand-tinted rounded-square tiles.
        // Card radius / tile radius follow the shared design language (22 / 16
        // at the default theme radius of 16) while staying driven by the
        // `radius` prop, matching how BalanceCard/OffersBanner stay prop-scaled.
        final tileRadius = radius;
        final cardRadius = radius + 6;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x141B2A4A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(actions.length, (i) {
              final (icon, label) = actions[i];
              // Same graceful-degradation contract as Minimal above.
              return Flexible(
                child: InkWell(
                  onTap: onItemTap == null ? null : () => onItemTap!(i),
                  borderRadius: BorderRadius.circular(tileRadius + 8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(tileRadius),
                          ),
                          child: catalogIcon(icon, color: color, size: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
    }
  }
}
