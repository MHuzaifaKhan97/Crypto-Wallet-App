import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: AmountDisplay — variants [Hero, Balance, Inline], props
/// [value:text, currency:text, currencyPosition:enum, color:color,
/// size:number, align:enum, caption:text, sign:enum, hideable:toggle,
/// hidden:toggle, showCaret:toggle, showDecimals:toggle].
///
/// `onChanged` is NOT a general two-way binding like TextInput/NumericKeypad
/// — this widget doesn't edit `value` itself. It's used ONLY by the
/// `hideable` eye toggle (Balance variant): tapping the eye emits the new
/// `hidden` state as the string 'true'/'false' (state-codegen binds it the
/// same way any other bound toggle prop would be bound). Null `onChanged`
/// (design canvas) still shows the eye, just non-tappable.
///
/// `sign` deliberately tints only the +/- glyph, not the whole figure — the
/// figure itself always renders in `color`. (An alternative reading tints
/// the whole amount, like catalog/recent_transactions.dart's list rows; the
/// manifest spec for this component explicitly scopes the tint to "the
/// prefix", so that's what's implemented here.)
class AmountDisplay extends StatelessWidget {
  final ComponentModel component;
  final ValueChanged<String>? onChanged;
  const AmountDisplay({super.key, required this.component, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final rawValue = component.props['value'] is String
        ? component.props['value'] as String
        : '0';
    final currency = component.props['currency'] is String
        ? component.props['currency'] as String
        : 'PKR';
    final currencyPosition = component.props['currencyPosition'] is String
        ? component.props['currencyPosition'] as String
        : 'prefix';
    final color = parseHexColor(
      component.colorPropRaw('color'),
      theme.textPrimary,
    );
    final size = component.numberProp('size', 44);
    final align = component.props['align'] is String
        ? component.props['align'] as String
        : 'center';
    final caption = component.props['caption'] is String
        ? component.props['caption'] as String
        : '';
    final sign = component.props['sign'] is String
        ? component.props['sign'] as String
        : 'none';
    final hideable = component.toggleProp('hideable', false);
    final hidden = component.toggleProp('hidden', false);
    final showCaret = component.toggleProp('showCaret', false);
    final showDecimals = component.toggleProp('showDecimals', true);

    final isBalance = component.variant == 'Balance';
    final isInline = component.variant == 'Inline';
    final fontWeight = isInline ? FontWeight.w600 : FontWeight.w700;

    final figureText = hidden && isBalance
        ? '••••••'
        : _formatFigure(rawValue, showDecimals);

    final currencyStyle = TextStyle(
      fontSize: size * 0.55,
      fontWeight: fontWeight,
      color: theme.textSecondary,
      fontFamily: theme.fontFamily,
    );
    final figureStyle = TextStyle(
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      fontFamily: theme.fontFamily,
      height: 1.0,
    );

    Widget? signWidget;
    if (sign == 'credit') {
      signWidget = Text(
        '+',
        style: figureStyle.copyWith(color: _kSuccessGreen),
      );
    } else if (sign == 'debit') {
      signWidget = Text('-', style: figureStyle.copyWith(color: color));
    }

    // Flexible + ellipsis on the currency/figure text: an authored `value` or
    // `currency` far longer than a real money figure (the generator's
    // long-text/RTL prop-matrix coverage exercises exactly this) degrades
    // gracefully instead of overflowing the Row — the mainAxisSize:min Row
    // below has no other way to shrink a non-flex child that's wider than
    // the ambient max width.
    final rowChildren = <Widget>[
      ?signWidget,
      if (currencyPosition == 'prefix') ...[
        Flexible(
          child: Text(
            currency,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: currencyStyle,
          ),
        ),
        SizedBox(width: size * 0.12),
      ],
      Flexible(
        child: Text(
          figureText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: figureStyle,
        ),
      ),
      if (currencyPosition == 'suffix') ...[
        SizedBox(width: size * 0.12),
        Flexible(
          child: Text(
            currency,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: currencyStyle,
          ),
        ),
      ],
      // Static caret — deliberately not animated so golden tests stay
      // deterministic. Inline ignores it regardless of showCaret.
      if (showCaret && !isInline) ...[
        SizedBox(width: size * 0.1),
        Container(width: size * 0.04, height: size * 0.75, color: color),
      ],
      if (isBalance && hideable) ...[
        SizedBox(width: size * 0.18),
        _EyeToggle(
          hidden: hidden,
          size: size * 0.5,
          color: theme.textSecondary,
          onTap: onChanged == null
              ? null
              : () => onChanged!(hidden ? 'false' : 'true'),
        ),
      ],
    ];

    final figureRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: rowChildren,
    );

    final crossAlign = _crossAxisFor(align);

    if (caption.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlign,
        children: [figureRow],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        figureRow,
        SizedBox(height: size * 0.14),
        Text(
          caption,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            fontFamily: theme.fontFamily,
          ),
        ),
      ],
    );
  }
}

const Color _kSuccessGreen = Color(0xFF10B981);

CrossAxisAlignment _crossAxisFor(String align) {
  switch (align) {
    case 'left':
      return CrossAxisAlignment.start;
    case 'right':
      return CrossAxisAlignment.end;
    default:
      return CrossAxisAlignment.center;
  }
}

/// Formats a raw, possibly-partial numeric string into the figure text:
/// strips anything but digits and '.', groups the integer part with
/// thousands separators, and — when [showDecimals] — renders a fixed 2dp
/// tail EXCEPT while the string is mid-edit (ends in '.' or has exactly 1
/// decimal digit), in which case whatever the user typed is preserved
/// verbatim so a live entry field doesn't fight the user's cursor.
String _formatFigure(String raw, bool showDecimals) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  final dotIndex = cleaned.indexOf('.');
  String intPart;
  String decPart;
  if (dotIndex >= 0) {
    intPart = cleaned.substring(0, dotIndex);
    // Guard against a malformed value with multiple dots.
    decPart = cleaned.substring(dotIndex + 1).replaceAll('.', '');
  } else {
    intPart = cleaned;
    decPart = '';
  }
  if (intPart.isEmpty) intPart = '0';
  final groupedInt = _groupThousands(intPart);

  if (!showDecimals) return groupedInt;
  if (dotIndex < 0) return '$groupedInt.00';
  if (decPart.isEmpty) return '$groupedInt.';
  if (decPart.length == 1) return '$groupedInt.$decPart';
  return '$groupedInt.${decPart.substring(0, 2)}';
}

/// Tiny local thousands-grouping formatter (no intl/NumberFormat dependency —
/// pubspec.yaml has none and this task must not add one).
String _groupThousands(String digits) {
  final n = digits.length;
  final buffer = StringBuffer();
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _EyeToggle extends StatelessWidget {
  final bool hidden;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  const _EyeToggle({
    required this.hidden,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(
        iconFromName(hidden ? 'eye_off' : 'eye'),
        size: size,
        color: color,
      ),
    );
  }
}
