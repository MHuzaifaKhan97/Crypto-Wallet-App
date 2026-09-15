import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../runtime/models.dart';
import '../state/state_scope.dart';
import '../runtime/validators.dart';
import 'icons.dart';

/// Manifest: TextInput — variants [Outlined, Filled, Underlined].
///
/// KSA-port primitive for login/form screens. Two renderings share one prop
/// resolver ([_TiStyle]) so the design canvas and the generated app never
/// drift:
///   * static  (onChanged == null) — a NON-interactive styled Container that
///     LOOKS like the field, used on the Design Mode canvas (no keyboard/focus).
///   * interactive (onChanged != null) — a real, validating TextField wrapped
///     in a FormField, used in the generated app (two-way binding).
class TextInput extends StatelessWidget {
  final ComponentModel component;

  /// Pillar 3: when supplied (generated app, two-way binding), the field
  /// becomes a REAL, editable TextField that reports every change. Null on the
  /// design canvas → the original static placeholder look (no focus/keyboard).
  final ValueChanged<String>? onChanged;

  /// Fires the node's `events.onChange` action chain (if any) on each edit,
  /// AFTER `onChanged` has written the bound value — so the action chain reads
  /// the just-updated state var. Mirrors Switch's onChange contract. Null on
  /// the static design canvas (no interaction), same as [onChanged].
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;

  /// Readable-codegen entry (typed constructors, plan P4): every manifest
  /// prop as a named typed parameter, plus the bound [value], the
  /// [validators] the FormField runs, and [hasOnChange] (the node declares an
  /// onChange chain → fires [onCompositeEvent]('onChange') after each edit,
  /// exactly as the registry path gates on eventKeys). Builds the same
  /// ComponentModel the JSON path does, so the internals are shared.
  TextInput({
    super.key,
    String variant = 'Classic',
    String? value,
    String? label,
    String? placeholder,
    String? inputType,
    bool? obscure,
    double? maxLines,
    double? maxLength,
    String? helperText,
    String? prefixText,
    String? suffixText,
    String? leadingIcon,
    String? trailingIcon,
    String? textAlign,
    bool? enabled,
    bool? readOnly,
    bool? clearButton,
    bool? autofocus,
    bool? dense,
    double? fontSize,
    double? borderWidth,
    Color? primaryColor,
    Color? fillColor,
    Color? textColor,
    Color? hintColor,
    Color? labelColor,
    Color? iconColor,
    Color? borderColor,
    double? radius,
    List<Map<String, dynamic>> validators = const [],
    bool hasOnChange = false,
    this.onChanged,
    this.onCompositeEvent,
  }) : component = ComponentModel(
         id: '',
         type: 'TextInput',
         variant: variant,
         props: typedProps({
           'value': value,
           'label': label,
           'placeholder': placeholder,
           'inputType': inputType,
           'obscure': obscure,
           'maxLines': maxLines,
           'maxLength': maxLength,
           'helperText': helperText,
           'prefixText': prefixText,
           'suffixText': suffixText,
           'leadingIcon': leadingIcon,
           'trailingIcon': trailingIcon,
           'textAlign': textAlign,
           'enabled': enabled,
           'readOnly': readOnly,
           'clearButton': clearButton,
           'autofocus': autofocus,
           'dense': dense,
           'fontSize': fontSize,
           'borderWidth': borderWidth,
           'primaryColor': primaryColor,
           'fillColor': fillColor,
           'textColor': textColor,
           'hintColor': hintColor,
           'labelColor': labelColor,
           'iconColor': iconColor,
           'borderColor': borderColor,
           'radius': radius,
         }),
         bindings: const {},
         validators: validators,
         eventKeys: hasOnChange ? const {'onChange'} : const {},
       );

  /// Registry / interpreter entry — the node's parsed model as-is.
  const TextInput.fromModel({
    super.key,
    required this.component,
    this.onChanged,
    this.onCompositeEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (onChanged != null) {
      return _InteractiveTextInput(
        component: component,
        onChanged: onChanged!,
        onCompositeEvent: onCompositeEvent,
      );
    }

    final s = _TiStyle.of(component, DesignTheme.of(context));

    // Static (canvas) inner row — mirrors the interactive layout without a
    // real TextField.
    final displayText = s.effObscure ? '••••••••' : s.placeholder;
    final row = Row(
      crossAxisAlignment: s.isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (s.leadingIcon != null) ...[
          catalogIcon(s.leadingIcon, size: 20, color: s.iconColor),
          const SizedBox(width: 10),
        ],
        if (s.prefixText.isNotEmpty) ...[
          // Flexible + ellipsis: an authored prefix longer than the field has
          // room for degrades gracefully instead of overflowing the Row.
          Flexible(
            child: Text(
              s.prefixText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: s.fontSize, color: s.hintColor),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            displayText,
            textAlign: s.textAlign,
            style: TextStyle(
              fontSize: s.fontSize,
              color: s.hintColor,
              fontWeight: FontWeight.w400,
              letterSpacing: s.effObscure ? 3.0 : 0.0,
            ),
            maxLines: s.isMultiline ? s.maxLines : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (s.suffixText.isNotEmpty) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              s.suffixText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: s.fontSize, color: s.hintColor),
            ),
          ),
        ],
        if (s.trailingIcon != null) ...[
          const SizedBox(width: 8),
          catalogIcon(s.trailingIcon, size: 20, color: s.iconColor),
        ],
        if (s.effObscure) ...[
          const SizedBox(width: 8),
          Icon(Icons.visibility_outlined, size: 20, color: s.iconColor),
        ],
      ],
    );

    final field = s.box(borderColor: s.baseBorderColor, child: row);
    return s.wrap(
      context,
      field: field,
      hasError: false,
      errorText: null,
      currentLength: 0,
    );
  }
}

const Color _kErrorRed = Color(0xFFEF4444);

/// Resolves every TextInput prop into concrete render values once, so the
/// static and interactive branches read the same source of truth. Also owns
/// the two pieces of layout shared by both branches: [box] (the field frame,
/// variant-aware) and [wrap] (label above + helper/error/counter below).
class _TiStyle {
  final ComponentModel c;
  final DesignTheme theme;

  final String label;
  final String placeholder;
  final String helperText;
  final String prefixText;
  final String suffixText;
  final String
  inputType; // Text | Email | Number | Phone | URL | Multiline | Password
  final bool effObscure; // Password type OR the legacy `obscure` toggle
  final bool isMultiline;
  final int maxLines;
  final int? maxLength; // null when 0 (no cap)
  final bool enabled;
  final bool readOnly;
  final bool clearButton;
  final bool autofocus;
  final bool dense;
  final double fontSize;
  final double borderWidth;
  final double radius;
  final double height; // 0 when multiline (grow to fit)
  final TextAlign textAlign;
  final String? leadingIcon;
  final String? trailingIcon;

  final String variant; // Outlined | Filled | Underlined
  final bool isFilled;
  final bool isUnderlined;
  final Color primaryColor;
  final Color baseFill;
  final Color baseBorderColor;
  final Color textColor;
  final Color hintColor;
  final Color labelColor;
  final Color iconColor;

  _TiStyle._({
    required this.c,
    required this.theme,
    required this.label,
    required this.placeholder,
    required this.helperText,
    required this.prefixText,
    required this.suffixText,
    required this.inputType,
    required this.effObscure,
    required this.isMultiline,
    required this.maxLines,
    required this.maxLength,
    required this.enabled,
    required this.readOnly,
    required this.clearButton,
    required this.autofocus,
    required this.dense,
    required this.fontSize,
    required this.borderWidth,
    required this.radius,
    required this.height,
    required this.textAlign,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.variant,
    required this.isFilled,
    required this.isUnderlined,
    required this.primaryColor,
    required this.baseFill,
    required this.baseBorderColor,
    required this.textColor,
    required this.hintColor,
    required this.labelColor,
    required this.iconColor,
  });

  static _TiStyle of(ComponentModel c, DesignTheme theme) {
    String textProp(String k, String fallback) =>
        c.props[k] is String ? c.props[k] as String : fallback;
    // Null (no icon) when the prop is absent, empty, or 'none'. The RAW
    // value is kept (not resolved to IconData here) so an image ref — an
    // uploaded glyph picked from the Assets tab — survives to catalogIcon at
    // the render sites below.
    String? iconProp(String k) {
      final raw = c.props[k] is String ? c.props[k] as String : null;
      if (raw == null || raw.isEmpty || raw == 'none') return null;
      return raw;
    }

    final inputType = textProp('inputType', 'Text');
    final legacyObscure = c.toggleProp('obscure', false);
    final effObscure = inputType == 'Password' || legacyObscure;
    final isMultiline = inputType == 'Multiline' && !effObscure;

    final maxLinesRaw = (c.numberPropRaw('maxLines') ?? 1).toInt();
    final maxLines = isMultiline ? (maxLinesRaw < 1 ? 1 : maxLinesRaw) : 1;
    final maxLenRaw = (c.numberPropRaw('maxLength') ?? 0).toInt();

    final dense = c.toggleProp('dense', false);
    final variant = c.variant; // 'Outlined' (default) | 'Filled' | 'Underlined'
    final isFilled = variant == 'Filled';
    final isUnderlined = variant == 'Underlined';

    final primaryColor = parseHexColor(
      c.colorPropRaw('primaryColor'),
      theme.primary,
    );
    final overrideFill = parseHexColorNullable(c.colorPropRaw('fillColor'));
    final overrideText = parseHexColorNullable(c.colorPropRaw('textColor'));
    final overrideHint = parseHexColorNullable(c.colorPropRaw('hintColor'));
    final overrideLabel = parseHexColorNullable(c.colorPropRaw('labelColor'));
    final overrideIcon = parseHexColorNullable(c.colorPropRaw('iconColor'));
    final overrideBorder = parseHexColorNullable(c.colorPropRaw('borderColor'));

    final enabled = c.toggleProp('enabled', true);

    final align = textProp('textAlign', 'Left');
    final textAlign = align == 'Center'
        ? TextAlign.center
        : (align == 'Right' ? TextAlign.right : TextAlign.left);

    // Disabled fields render dimmed regardless of overrides.
    Color dim(Color x) => enabled
        ? x
        : Color.alphaBlend(theme.surface.withValues(alpha: 0.55), x);

    return _TiStyle._(
      c: c,
      theme: theme,
      label: textProp('label', '').trim(),
      placeholder: textProp('placeholder', 'Enter text'),
      helperText: textProp('helperText', ''),
      prefixText: textProp('prefixText', ''),
      suffixText: textProp('suffixText', ''),
      inputType: inputType,
      effObscure: effObscure,
      isMultiline: isMultiline,
      maxLines: maxLines,
      maxLength: maxLenRaw > 0 ? maxLenRaw : null,
      enabled: enabled,
      readOnly: c.toggleProp('readOnly', false),
      clearButton: c.toggleProp('clearButton', false),
      autofocus: c.toggleProp('autofocus', false),
      dense: dense,
      fontSize: c.numberPropRaw('fontSize') ?? 15,
      borderWidth: c.numberPropRaw('borderWidth') ?? 1.5,
      radius: c.numberPropRaw('radius') ?? theme.radius,
      // An authored `height` prop wins over the two stock cuts; 0/absent keeps
      // them, so every field authored before the prop existed is unchanged.
      // Ignored for multiline, which grows to fit.
      height: isMultiline
          ? 0
          : ((c.numberPropRaw('height') ?? 0) > 0
                ? c.numberPropRaw('height')!
                : (dense ? 44 : 52)),
      textAlign: textAlign,
      // No fallback: an absent leadingIcon means NO icon (matches the original
      // widget). The manifest default of 'lock' only pre-selects the dropdown;
      // it is not materialized into props, so absence must stay iconless.
      leadingIcon: iconProp('leadingIcon'),
      trailingIcon: iconProp('trailingIcon'),
      variant: variant,
      isFilled: isFilled,
      isUnderlined: isUnderlined,
      primaryColor: primaryColor,
      baseFill: dim(
        overrideFill ?? (isFilled ? theme.surface : Colors.transparent),
      ),
      baseBorderColor: dim(
        overrideBorder ?? (isFilled ? Colors.transparent : primaryColor),
      ),
      textColor: dim(overrideText ?? theme.textPrimary),
      hintColor: dim(overrideHint ?? theme.textSecondary),
      labelColor: dim(overrideLabel ?? theme.textSecondary),
      iconColor: dim(overrideIcon ?? theme.textSecondary),
    );
  }

  EdgeInsets get pad => EdgeInsets.symmetric(
    horizontal: isUnderlined ? 2 : 14,
    vertical: isMultiline ? (dense ? 8 : 12) : 0,
  );

  /// The field frame. Underlined → a single bottom border, no radius/fill;
  /// otherwise a full rounded box.
  Widget box({required Color borderColor, required Widget child}) {
    final decoration = isUnderlined
        ? BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: borderWidth),
            ),
          )
        : BoxDecoration(
            color: baseFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: borderWidth),
          );
    return Container(
      height: height == 0 ? null : height,
      constraints: isMultiline ? const BoxConstraints(minHeight: 52) : null,
      decoration: decoration,
      padding: pad,
      child: child,
    );
  }

  /// Label above (with a red * when a `required` validator is present) and the
  /// helper/error/counter caption below.
  Widget wrap(
    BuildContext context, {
    required Widget field,
    required bool hasError,
    required String? errorText,
    required int currentLength,
  }) {
    final required = _isRequired(c);
    final labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: labelColor,
      fontFamily: theme.fontFamily,
    );

    final captionParts = <Widget>[];
    final captionText = hasError
        ? errorText
        : (helperText.isEmpty ? null : helperText);
    if (captionText != null) {
      captionParts.add(
        Expanded(
          child: Text(
            captionText,
            style: TextStyle(
              fontSize: 11.5,
              color: hasError ? _kErrorRed : hintColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      captionParts.add(const Spacer());
    }
    if (maxLength != null) {
      captionParts.add(
        Text(
          '$currentLength/$maxLength',
          style: TextStyle(fontSize: 11.5, color: hintColor),
        ),
      );
    }
    final showCaption = captionText != null || maxLength != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: labelStyle,
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: _kErrorRed),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
        ],
        field,
        if (showCaption)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(children: captionParts),
          ),
      ],
    );
  }
}

/// True when the node declares a `required` validator (or the legacy
/// `props.required` toggle) — drives the red `*` on the label.
bool _isRequired(ComponentModel c) {
  if (c.toggleProp('required', false)) return true;
  return c.validators.any((v) => v['kind'] == 'required');
}

/// Maps the `inputType` prop to a Flutter keyboard type + input formatters.
TextInputType _keyboardType(String inputType, bool multiline) {
  switch (inputType) {
    case 'Email':
      return TextInputType.emailAddress;
    case 'Number':
      return const TextInputType.numberWithOptions(decimal: false);
    case 'Decimal':
      return const TextInputType.numberWithOptions(decimal: true);
    case 'Phone':
      return TextInputType.phone;
    case 'URL':
      return TextInputType.url;
    case 'Multiline':
      return TextInputType.multiline;
    case 'Password':
      return TextInputType.visiblePassword;
    default:
      return multiline ? TextInputType.multiline : TextInputType.text;
  }
}

List<TextInputFormatter> _formatters(String inputType) {
  switch (inputType) {
    case 'Number':
    case 'Phone':
      return [FilteringTextInputFormatter.digitsOnly];
    case 'Decimal':
      // Digits and at most one decimal point (money entry).
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    default:
      return const [];
  }
}

/// The real, editable field used in the generated app: owns a controller seeded
/// from the bound state value, wraps itself in a [FormField] so it registers
/// with any ancestor [Form], and shows a red border + inline error once it
/// fails validation. Kept private + stateful so the controller survives
/// rebuilds and tracks focus.
class _InteractiveTextInput extends StatefulWidget {
  final ComponentModel component;
  final ValueChanged<String> onChanged;
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;
  const _InteractiveTextInput({
    required this.component,
    required this.onChanged,
    this.onCompositeEvent,
  });

  @override
  State<_InteractiveTextInput> createState() => _InteractiveTextInputState();
}

class _InteractiveTextInputState extends State<_InteractiveTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    // Password/obscure fields start obscured; the eye icon toggles this.
    final it = widget.component.props['inputType'];
    _obscure =
        (it == 'Password') || widget.component.toggleProp('obscure', false);
    _controller.text = widget.component.props['value'] is String
        ? widget.component.props['value'] as String
        : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _TiStyle.of(widget.component, DesignTheme.of(context));
    final canObscure = s.effObscure; // password-family field → show eye toggle
    final required = _isRequired(widget.component);
    // Reading StateScope here (in build) registers a dependency, so this field
    // re-validates when the field it must `match` changes. Null on the canvas
    // (no StateScope) → cross-field match no-ops. See state_scope.dart.
    final scope = StateScope.maybeOf(context);

    return FormField<String>(
      initialValue: _controller.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => runFieldValidators(
        widget.component.validators,
        required,
        _controller.text,
        readField: scope == null ? null : (f) => scope.read(f),
      ),
      builder: (field) {
        final hasError = field.errorText != null;
        final borderColor = hasError ? _kErrorRed : s.baseBorderColor;

        final row = Row(
          crossAxisAlignment: s.isMultiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (s.leadingIcon != null) ...[
              catalogIcon(
                s.leadingIcon,
                size: 20,
                color: hasError ? _kErrorRed : s.iconColor,
              ),
              const SizedBox(width: 10),
            ],
            if (s.prefixText.isNotEmpty) ...[
              // Flexible + ellipsis: an authored prefix longer than the field
              // has room for degrades gracefully instead of overflowing the Row.
              Flexible(
                child: Text(
                  s.prefixText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: s.fontSize,
                    color: s.hintColor,
                    fontFamily: s.theme.fontFamily,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: s.enabled,
                readOnly: s.readOnly,
                autofocus: s.autofocus,
                obscureText: canObscure && _obscure,
                textAlign: s.textAlign,
                keyboardType: _keyboardType(s.inputType, s.isMultiline),
                inputFormatters: _formatters(s.inputType),
                maxLines: canObscure ? 1 : s.maxLines,
                minLines: s.isMultiline ? s.maxLines : 1,
                maxLength: s.maxLength,
                // The default counter would break the fixed-height frame; we
                // render our own in the caption row instead.
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                onChanged: (v) {
                  widget.onChanged(v);
                  field.didChange(v);
                  setState(() {}); // refresh clear-button + counter
                  // Fire the node's events.onChange chain AFTER the bound value
                  // write above, so the action reads the fresh state. Gated on
                  // the node actually declaring onChange (like Switch) so most
                  // bound fields don't dispatch a dead event on every keystroke.
                  if (widget.component.eventKeys.contains('onChange')) {
                    widget.onCompositeEvent?.call('onChange');
                  }
                },
                style: TextStyle(
                  fontSize: s.fontSize,
                  color: s.textColor,
                  fontFamily: s.theme.fontFamily,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: s.placeholder,
                  hintStyle: TextStyle(
                    fontSize: s.fontSize,
                    color: s.hintColor,
                    fontFamily: s.theme.fontFamily,
                  ),
                ),
              ),
            ),
            if (s.suffixText.isNotEmpty) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  s.suffixText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: s.fontSize,
                    color: s.hintColor,
                    fontFamily: s.theme.fontFamily,
                  ),
                ),
              ),
            ],
            if (s.clearButton &&
                _controller.text.isNotEmpty &&
                s.enabled &&
                !s.readOnly) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                  field.didChange('');
                  setState(() {});
                  if (widget.component.eventKeys.contains('onChange')) {
                    widget.onCompositeEvent?.call('onChange');
                  }
                },
                child: Icon(Icons.close, size: 18, color: s.iconColor),
              ),
            ],
            if (s.trailingIcon != null) ...[
              const SizedBox(width: 8),
              catalogIcon(
                s.trailingIcon,
                size: 20,
                color: hasError ? _kErrorRed : s.iconColor,
              ),
            ],
            if (canObscure) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: s.iconColor,
                ),
              ),
            ],
          ],
        );

        return s.wrap(
          context,
          field: s.box(borderColor: borderColor, child: row),
          hasError: hasError,
          errorText: field.errorText,
          currentLength: _controller.text.length,
        );
      },
    );
  }
}
