import 'package:flutter/material.dart';
import '../runtime/models.dart';

/// Manifest: OtpInput — variants [Boxed, Underlined, Dots], props
/// [value:text, length:number, obscure:toggle, boxSize:number,
/// gap:number, fontSize:number, accentColor:color, borderColor:color,
/// fillColor:color, textColor:color, hasError:toggle, errorColor:color].
///
/// Two entry paths, both writing the SAME bound state variable:
///
///   * the device keyboard (default) — an invisible, focus-owning TextField
///     sits over the cells, so tapping them raises the numeric keyboard and
///     every keystroke calls `onChanged`. `autofillHints: oneTimeCode` lets
///     the platform offer an SMS code. Turn this off with `keyboard: false`
///     on a screen that supplies its own NumericKeypad, or the system
///     keyboard would fight the on-screen pad for the same variable.
///   * a NumericKeypad bound to the same variable — the pad writes state,
///     this repaints. Unchanged, and still the right pairing for a passcode
///     screen.
///
/// This was DISPLAY ONLY and took no `onChanged` at all, which made an
/// OtpInput on a screen with no keypad completely dead: six cells no one can
/// fill (iris-digital-banking's OTP screen shipped exactly that).
///
/// `onCompleted` fires once, whichever path filled the last cell, AFTER the
/// bound value is written — so its action steps read the complete code. It
/// re-arms only when the code drops below `length` again, so a backspace and
/// retype fires it a second time but a rebuild does not.
///
/// `value` may arrive as a String, a number (some binding paths hand a
/// numeric type through), or null — all coerced to a String here. Characters
/// beyond `length` are ignored rather than overflowing the cell row.
///
/// The FIRST empty cell (index == the current code's length, while that's <
/// `length`) is the "active" cell awaiting the next character — its
/// border/underline is drawn in `accentColor` and slightly thicker than an
/// inert cell's. Once the code is complete (code.length >= length) there is
/// no active cell. `hasError` overrides all of that: every cell's
/// border/underline becomes `errorColor` and the active-cell accent is
/// suppressed entirely.
///
/// Boxed: a rounded-rect cell per slot, `fillColor` background, a
/// `borderColor` (or accent/error) border. Underlined: no fill or box at
/// all — just a bottom rule per cell. Dots: no box either, a filled/hollow
/// circle per slot sized off `boxSize`, meant for passcode entry — `obscure`
/// is treated as always-on for this variant regardless of the prop's value.
///
/// Row sizing is computed in a LayoutBuilder: cells start at `boxSize` but
/// shrink (never grow) so `length` cells at `gap` spacing always fit the
/// available width without overflowing — covers the 375px / `length`=8
/// worst case from the default boxSize. Font size shrinks along with the
/// cell so digits never spill past a shrunk cell's edge.
class OtpInput extends StatelessWidget {
  final ComponentModel component;

  /// Non-null only when the node declares a `bindValue` (node_view.dart wires
  /// it for every composite). Null on the design canvas and for an unbound
  /// node, which is what keeps this a plain, non-interactive painting there.
  final ValueChanged<String>? onChanged;

  /// Fires `onCompleted` — see the class doc. Same signature every other
  /// event-dispatching composite uses (text_input.dart's onChange).
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;

  const OtpInput({
    super.key,
    required this.component,
    this.onChanged,
    this.onCompositeEvent,
  });

  int get _length => component.numberProp('length', 6).toInt().clamp(3, 8);

  String get _rawValue {
    final v = component.props['value'];
    if (v == null) return '';
    if (v is String) return v;
    if (v is int) return v.toString();
    if (v is double) {
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }
    return v.toString();
  }

  String get _code {
    final raw = _rawValue;
    final length = _length;
    return raw.length > length ? raw.substring(0, length) : raw;
  }

  @override
  Widget build(BuildContext context) {
    if (onChanged == null)
      return _OtpCells(component: component, code: _code, length: _length);
    return _OtpInteractive(
      component: component,
      length: _length,
      value: _code,
      onChanged: onChanged!,
      onCompositeEvent: onCompositeEvent,
    );
  }
}

/// The cells themselves — pure painting, no input. Split out of [OtpInput] so
/// both the static and the interactive path draw pixel-identical cells from
/// one body; [code] is passed in rather than read off the component because
/// the interactive path paints the CONTROLLER's text (this frame's keystroke)
/// while the component's own `value` prop is still one state write behind.
class _OtpCells extends StatelessWidget {
  final ComponentModel component;
  final String code;
  final int length;
  const _OtpCells({
    required this.component,
    required this.code,
    required this.length,
  });

  bool get _isUnderlined => component.variant == 'Underlined';
  bool get _isDots => component.variant == 'Dots';

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    // Dots is always obscured, regardless of the `obscure` prop — it's the
    // passcode-entry look.
    final obscure = component.toggleProp('obscure', false) || _isDots;
    final baseBoxSize = component.numberProp('boxSize', 52);
    final gap = component.numberProp('gap', 10);
    final baseFontSize = component.numberProp('fontSize', 22);
    final accentColor = parseHexColor(
      component.colorPropRaw('accentColor'),
      theme.primary,
    );
    final borderColor = parseHexColor(
      component.colorPropRaw('borderColor'),
      const Color(0xFFEDEEF0),
    );
    final fillColor = parseHexColor(
      component.colorPropRaw('fillColor'),
      const Color(0xFFF5F6F7),
    );
    final textColor = parseHexColor(
      component.colorPropRaw('textColor'),
      theme.textPrimary,
    );
    final hasError = component.toggleProp('hasError', false);
    final errorColor = parseHexColor(
      component.colorPropRaw('errorColor'),
      const Color(0xFFFF4D4F),
    );

    // No active cell once the code is complete.
    final activeIndex = code.length < length ? code.length : -1;
    final cornerRadius = (theme.radius * 0.5).clamp(6.0, 16.0);

    Widget buildCell(int i, double boxSize, double fontSize) {
      final isActive = !hasError && i == activeIndex;
      final filled = i < code.length;
      final char = filled ? code[i] : '';
      final display = filled && obscure ? '•' : char;
      final lineColor = hasError
          ? errorColor
          : (isActive ? accentColor : borderColor);

      if (_isDots) {
        final borderWidth = isActive ? 2.5 : 1.5;
        final dotSize = (boxSize * 0.4).clamp(6.0, boxSize);
        return SizedBox(
          width: boxSize,
          height: boxSize,
          child: Center(
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? lineColor : Colors.transparent,
                border: Border.all(color: lineColor, width: borderWidth),
              ),
            ),
          ),
        );
      }

      final text = Text(
        display,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: theme.fontFamily,
        ),
      );

      if (_isUnderlined) {
        final underlineThickness = isActive ? 3.0 : 2.0;
        return SizedBox(
          width: boxSize,
          height: boxSize,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: Center(child: text)),
              Container(height: underlineThickness, color: lineColor),
            ],
          ),
        );
      }

      // Boxed.
      final borderWidth = isActive ? 2.5 : 1.5;
      return Container(
        width: boxSize,
        height: boxSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: lineColor, width: borderWidth),
        ),
        child: text,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = gap * (length - 1);
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : baseBoxSize * length + totalGap;
        final fitBoxSize = ((maxWidth - totalGap) / length);
        final boxSize = fitBoxSize < baseBoxSize
            ? fitBoxSize.clamp(16.0, baseBoxSize)
            : baseBoxSize;
        final fontSize = baseFontSize * (boxSize / baseBoxSize);

        final children = <Widget>[];
        for (var i = 0; i < length; i++) {
          if (i > 0) children.add(SizedBox(width: gap));
          children.add(buildCell(i, boxSize, fontSize));
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      },
    );
  }
}

/// Keyboard entry + completion detection around [_OtpCells].
///
/// The cells are painted by the same body as the static path; on top of them
/// sits a fully transparent, focus-owning TextField. Tapping anywhere on the
/// row focuses it and raises the platform's numeric keyboard. The field is
/// invisible rather than absent because Flutter has no way to receive text
/// without one, and invisible-but-hit-testable is what makes the whole row a
/// single tap target.
///
/// The bound variable stays the single source of truth: [value] flows in from
/// state on every rebuild, and a change that did NOT come from this keyboard
/// (a NumericKeypad on the same variable, or an action step clearing the code
/// after a failed verify) is pushed into the controller in didUpdateWidget.
class _OtpInteractive extends StatefulWidget {
  final ComponentModel component;
  final int length;
  final String value;
  final ValueChanged<String> onChanged;
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;

  const _OtpInteractive({
    required this.component,
    required this.length,
    required this.value,
    required this.onChanged,
    this.onCompositeEvent,
  });

  @override
  State<_OtpInteractive> createState() => _OtpInteractiveState();
}

class _OtpInteractiveState extends State<_OtpInteractive> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focus = FocusNode();

  /// The code `onCompleted` last fired for. Cleared the moment the code drops
  /// below full length, so the event re-arms for a retype but never repeats on
  /// a plain rebuild.
  String _completedFor = '';

  @override
  void didUpdateWidget(covariant _OtpInteractive old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      // An external write (keypad, clear-on-error) can complete the code too.
      _maybeComplete(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _maybeComplete(String code) {
    if (code.length < widget.length) {
      _completedFor = '';
      return;
    }
    if (_completedFor == code) return;
    _completedFor = code;
    final cb = widget.onCompositeEvent;
    if (cb == null) return;
    // Deferred: this can run from didUpdateWidget, and an action step that
    // writes state (every OTP flow's does) must not run during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) cb('onCompleted');
    });
  }

  void _handleChanged(String raw) {
    // Digits only, capped at `length`: the platform keyboard can paste, and a
    // numeric keyboard still offers punctuation on some locales.
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    if (code != raw) {
      _controller.value = TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      );
    }
    setState(() {}); // repaint the cells from the controller
    widget.onChanged(code); // write the bound variable FIRST …
    _maybeComplete(code); // … so onCompleted's steps read the full code
  }

  @override
  Widget build(BuildContext context) {
    final cells = _OtpCells(
      component: widget.component,
      code: _controller.text,
      length: widget.length,
    );
    // A screen with its own NumericKeypad turns this off — two keyboards
    // competing for one variable is worse than either alone.
    if (!widget.component.toggleProp('keyboard', true)) return cells;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          cells,
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                maxLength: widget.length,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: _handleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
