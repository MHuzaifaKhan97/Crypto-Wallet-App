import 'package:flutter/material.dart';
import '../runtime/models.dart';

/// Manifest: SegmentedTabs — variants [Pill, Underline, Compact],
/// props [labels:text, selectedIndex:number, accentColor:color,
/// indicatorColor:color, trackColor:color, selectedTextColor:color,
/// textColor:color, radius:number, height:number, fontSize:number].
///
/// Two-way binding contract (same shape as NumericKeypad/TextInput, but the
/// bound value is a SELECTED INDEX rather than a string): the current index
/// is read from `component.props['value']` when present — accepting either
/// an int or a numeric String, since state-codegen may hand either shape
/// through — falling back to the `selectedIndex` prop, then to 0. It is
/// always clamped into range. Tapping segment `i` reports `onChanged(
/// i.toString())`; a null `onChanged` (design canvas) still renders every
/// segment, just non-tappable.
///
/// Tapping a segment ALSO fires `onCompositeEvent('onTabChanged', {'index':
/// i, 'label': labels[i]})`, after the `onChanged` write-back so a step's
/// expression already sees the new bound value. `index` is a real `int` here
/// even though the bound value stays a String — the payload is a fresh
/// channel with no existing documents to keep compatible, and node_view.dart
/// spreads it into the action-step expression scope, so steps read `index`
/// and `label` as bare top-level names (same contract as DataTable's
/// `onRowTap`). A segment is tappable when EITHER callback is present, so a
/// tab-changed action works on a node with no `bindValue` at all.
///
/// `labels` is a comma-separated string (PropSpec has no list type — see the
/// manifest's own comment) split on ',' and trimmed, dropping empty entries.
/// Fewer than 2 labels still renders without crashing: a lone segment, or an
/// empty shell (just a sized box) for an empty string.
///
/// Segments share the row equally (Expanded) and ellipsize their label
/// rather than overflow, so four longish labels still fit at a 375px width.
///
/// Pill: a `trackColor` rounded track (radius from `radius`), the selected
/// segment drawn as an `indicatorColor` filled pill inset a few px from the
/// track's edge. Underline: no track fill; the selected segment gets a thin
/// `indicatorColor` bar underneath instead, and its label is tinted
/// `indicatorColor` (not `selectedTextColor`, which only applies to the Pill
/// look where the label sits on a filled chip). Compact renders like Pill at
/// ~0.75x `height`/`fontSize`. `accentColor` is the fallback for
/// `indicatorColor` when that prop is absent, per the manifest.
class SegmentedTabs extends StatelessWidget {
  final ComponentModel component;
  final ValueChanged<String>? onChanged;
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;
  const SegmentedTabs({
    super.key,
    required this.component,
    this.onChanged,
    this.onCompositeEvent,
  });

  List<String> get _labels {
    final raw = component.props['labels'] is String
        ? component.props['labels'] as String
        : 'One, Two';
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  int _selectedIndex(List<String> labels) {
    if (labels.isEmpty) return 0;
    final raw = component.props['value'] ?? component.props['selectedIndex'];
    int idx;
    if (raw is int) {
      idx = raw;
    } else if (raw is num) {
      idx = raw.toInt();
    } else if (raw is String) {
      idx = int.tryParse(raw) ?? 0;
    } else {
      idx = 0;
    }
    return idx.clamp(0, labels.length - 1);
  }

  bool get _isUnderline => component.variant == 'Underline';
  bool get _isCompact => component.variant == 'Compact';

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final labels = _labels;
    final selectedIndex = _selectedIndex(labels);

    final accentColor = parseHexColor(
      component.colorPropRaw('accentColor'),
      theme.primary,
    );
    final indicatorColor = parseHexColor(
      component.colorPropRaw('indicatorColor'),
      accentColor,
    );
    final trackColor = parseHexColor(
      component.colorPropRaw('trackColor'),
      theme.surface,
    );
    final selectedTextColor = parseHexColor(
      component.colorPropRaw('selectedTextColor'),
      Colors.white,
    );
    final textColor = parseHexColor(
      component.colorPropRaw('textColor'),
      theme.textSecondary,
    );
    final radius = component.numberProp('radius', 24);
    final baseHeight = component.numberProp('height', 44);
    final baseFontSize = component.numberProp('fontSize', 14);

    // Compact variant: smaller track/text than the same props would
    // otherwise produce, for use in a denser layout.
    final height = _isCompact ? baseHeight * 0.75 : baseHeight;
    final fontSize = _isCompact ? baseFontSize * 0.75 : baseFontSize;

    if (labels.isEmpty) {
      // Empty shell — nothing to render, but don't crash or collapse to zero
      // height (keeps the slot visible/selectable on the design canvas).
      return SizedBox(height: height);
    }

    Widget buildSegment(int i) {
      final selected = i == selectedIndex;
      final label = labels[i];
      final labelColor = selected
          ? (_isUnderline ? indicatorColor : selectedTextColor)
          : textColor;

      final text = Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: labelColor,
          fontFamily: theme.fontFamily,
        ),
      );

      Widget segment;
      if (_isUnderline) {
        segment = Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: Center(child: text)),
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: selected ? indicatorColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      } else {
        segment = Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? indicatorColor : Colors.transparent,
            borderRadius: BorderRadius.circular((radius - 3).clamp(0, radius)),
          ),
          child: text,
        );
      }

      final interactive = onChanged != null || onCompositeEvent != null;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !interactive
              ? null
              : () {
                  onChanged?.call(i.toString());
                  onCompositeEvent?.call('onTabChanged', {
                    'index': i,
                    'label': label,
                  });
                },
          child: SizedBox(height: height, child: segment),
        ),
      );
    }

    final row = Row(
      children: [for (var i = 0; i < labels.length; i++) buildSegment(i)],
    );

    if (_isUnderline) {
      // No track fill for Underline.
      return SizedBox(height: height, child: row);
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: row,
    );
  }
}
