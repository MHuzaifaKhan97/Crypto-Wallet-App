import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: NumericKeypad — variants [Amount, Pin, Compact], props
/// [keyColor:color, accentColor:color, keyBackground:color,
/// showDecimal:toggle, leadingKey:enum, maxLength:number, keyHeight:number,
/// fontSize:number, gap:number].
///
/// Two-way binding contract (same as catalog/text_input.dart): reads the
/// current string from `component.props['value']` and reports every edit
/// via `onChanged`. A null `onChanged` (design canvas) renders the pad fully
/// but non-interactive — keys carry no tap handler at all.
///
/// Layout note not spelled out verbatim by the manifest: the bottom-left cell
/// is a DECIMAL key ('.') whenever `leadingKey=='none' && showDecimal==true`
/// on a non-Pin variant — i.e. the conventional [. 0 ⌫] amount-pad row. It
/// falls back to a blank, non-tappable cell only when there's no decimal to
/// offer. `Pin` ignores `showDecimal` entirely and always renders the
/// bottom-left cell strictly from `leadingKey` (a PIN pad's bottom-left is
/// never a decimal point, even when `leadingKey=='none'`).
class NumericKeypad extends StatelessWidget {
  final ComponentModel component;
  final ValueChanged<String>? onChanged;
  const NumericKeypad({super.key, required this.component, this.onChanged});

  String get _value {
    final v = component.props['value'];
    return v is String ? v : '';
  }

  bool get _isPin => component.variant == 'Pin';
  bool get _isCompact => component.variant == 'Compact';

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final keyColor = parseHexColor(
      component.colorPropRaw('keyColor'),
      theme.textPrimary,
    );
    final accentColor = parseHexColor(
      component.colorPropRaw('accentColor'),
      theme.primary,
    );
    final keyBackground = parseHexColor(
      component.colorPropRaw('keyBackground'),
      Colors.transparent,
    );
    final showDecimal = component.toggleProp('showDecimal', true);
    final leadingKey = component.props['leadingKey'] is String
        ? component.props['leadingKey'] as String
        : 'none';
    final maxLength = component
        .numberProp('maxLength', 12)
        .toInt()
        .clamp(1, 18);
    final baseKeyHeight = component.numberProp('keyHeight', 64);
    final baseFontSize = component.numberProp('fontSize', 24);
    final gap = component.numberProp('gap', 8);

    // Compact variant: smaller keys/text than the same props would otherwise
    // produce, for use inside a bottom sheet.
    final keyHeight = _isCompact ? baseKeyHeight * 0.75 : baseKeyHeight;
    final fontSize = _isCompact ? baseFontSize * 0.75 : baseFontSize;

    void emit(String next) {
      if (onChanged != null && next != _value) onChanged!(next);
    }

    void tapDigit(String d) {
      final v = _value;
      final dotIndex = v.indexOf('.');
      // Cap to 2dp once a decimal point exists.
      if (dotIndex >= 0 && v.substring(dotIndex + 1).length >= 2) return;
      // maxLength counts digits only — the '.' itself doesn't count.
      final digitCount = v.replaceAll('.', '').length;
      if (digitCount >= maxLength) return;
      emit(v + d);
    }

    void tapDecimal() {
      final v = _value;
      if (v.contains('.')) return;
      // Never emit a leading '.' — tapping it on an empty value yields '0.'.
      emit(v.isEmpty ? '0.' : '$v.');
    }

    void tapBackspace() {
      final v = _value;
      if (v.isEmpty) return;
      emit(v.substring(0, v.length - 1));
    }

    void clearAll() => emit('');

    Widget buildKey({
      required Widget child,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
    }) {
      return Expanded(
        child: SizedBox(
          height: keyHeight,
          child: Material(
            color: keyBackground,
            borderRadius: BorderRadius.circular(theme.radius),
            child: InkWell(
              borderRadius: BorderRadius.circular(theme.radius),
              onTap: onChanged == null ? null : onTap,
              onLongPress: onChanged == null ? null : onLongPress,
              child: Center(child: child),
            ),
          ),
        ),
      );
    }

    Widget keyText(String s) => Text(
      s,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: keyColor,
        fontFamily: theme.fontFamily,
      ),
    );

    Widget buildBottomLeft() {
      switch (leadingKey) {
        case 'biometric':
          return buildKey(
            child: Icon(
              iconFromName('fingerprint'),
              color: keyColor,
              size: fontSize,
            ),
          );
        case 'qr':
          return buildKey(
            child: Icon(iconFromName('qr'), color: keyColor, size: fontSize),
          );
        default:
          if (!_isPin && showDecimal) {
            return buildKey(child: keyText('.'), onTap: tapDecimal);
          }
          return buildKey(child: const SizedBox.shrink());
      }
    }

    Widget row(List<Widget> keys) {
      final children = <Widget>[];
      for (var i = 0; i < keys.length; i++) {
        if (i > 0) children.add(SizedBox(width: gap));
        children.add(keys[i]);
      }
      return Row(children: children);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          buildKey(child: keyText('1'), onTap: () => tapDigit('1')),
          buildKey(child: keyText('2'), onTap: () => tapDigit('2')),
          buildKey(child: keyText('3'), onTap: () => tapDigit('3')),
        ]),
        SizedBox(height: gap),
        row([
          buildKey(child: keyText('4'), onTap: () => tapDigit('4')),
          buildKey(child: keyText('5'), onTap: () => tapDigit('5')),
          buildKey(child: keyText('6'), onTap: () => tapDigit('6')),
        ]),
        SizedBox(height: gap),
        row([
          buildKey(child: keyText('7'), onTap: () => tapDigit('7')),
          buildKey(child: keyText('8'), onTap: () => tapDigit('8')),
          buildKey(child: keyText('9'), onTap: () => tapDigit('9')),
        ]),
        SizedBox(height: gap),
        row([
          buildBottomLeft(),
          buildKey(child: keyText('0'), onTap: () => tapDigit('0')),
          buildKey(
            child: Icon(
              iconFromName('backspace'),
              color: accentColor,
              size: fontSize,
            ),
            onTap: tapBackspace,
            onLongPress: clearAll,
          ),
        ]),
      ],
    );
  }
}
