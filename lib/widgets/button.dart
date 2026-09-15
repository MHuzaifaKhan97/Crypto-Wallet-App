import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: Button — variants [Filled, Gradient, Outlined], props [label:text,
/// primaryColor:color, radius:number, labelColor:color, showIcon:toggle,
/// icon:enum, fullWidth:toggle, disabled:toggle, disabledColor:color,
/// disabledLabelColor:color, loading:toggle, flat:toggle].
///
/// ONE foreground colour, three things painted with it: the label, the icon
/// and the loading spinner all resolve to `labelColor`, falling back to the
/// variant's own (white on Filled/Gradient, `primaryColor` on Outlined, where
/// primaryColor is the BORDER). There is deliberately no `iconColor`: a
/// two-tone icon/label CTA has never been asked for, and the prop would be a
/// fourth colour to keep in sync in every document and every spec listing.
/// Splitting them here breaks that contract silently.
///
/// Ported from ksa_demo_app `lib/widgets/buttons/button_widget.dart` and
/// `lib/widgets/buttons/custom_button.dart` (GradientButton /
/// GradientOutlinedButton family). App-coupling removed: AppTheme → DesignTheme,
/// SizeConfig/MediaQuery widths → fullWidth toggle, onTap → no-op (presentational),
/// outline_gradient_button pkg → hand-rolled gradient border painter,
/// ShaderText → hand-rolled gradient text shader, SVG/PNG asset refs → iconFromName.
///
/// Premium fintech re-skin: Filled uses a subtle primary→darker-primary
/// gradient with a soft primary-tinted shadow; Gradient stays a brighter
/// primary→lightened gradient; Outlined keeps its primary border + text,
/// no fill. All variants share generous vertical padding and a bold label.
class Button extends StatelessWidget {
  final ComponentModel component;

  /// Readable-codegen entry (typed constructors, plan P4): named typed props
  /// → the same ComponentModel the registry path builds from JSON, so the
  /// internals below read `component.props` identically either way.
  Button({
    super.key,
    String variant = 'Classic',
    String? label,
    Color? primaryColor,
    double? radius,
    Color? labelColor,
    bool? showIcon,
    String? icon,
    bool? fullWidth,
    bool? disabled,
    bool? loading,
  }) : component = ComponentModel(
         id: '',
         type: 'Button',
         variant: variant,
         props: typedProps({
           'label': label,
           'primaryColor': primaryColor,
           'radius': radius,
           'labelColor': labelColor,
           'showIcon': showIcon,
           'icon': icon,
           'fullWidth': fullWidth,
           'disabled': disabled,
           'loading': loading,
         }),
         bindings: const {},
       );

  /// Registry / interpreter entry — the node's parsed model as-is.
  const Button.fromModel({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final primary = parseHexColor(
      component.colorPropRaw('primaryColor'),
      theme.primary,
    );
    // Clamped to 999 (was 24) so a fully-rounded pill is expressible. Flutter
    // treats an over-large circular radius as "as round as the box allows", so
    // a tall button stays a stadium rather than distorting; the ceiling only
    // guards against absurd values.
    final radius = component.numberProp('radius', 10).clamp(0.0, 999.0);
    // Optional override for the label + icon. Null (the manifest default is an
    // empty string) means "keep the variant's own colour", so every document
    // written before this prop existed renders exactly as it did. Filled and
    // Gradient were hardcoded white, which made Button unusable on a pale CTA
    // and pushed templates into hand-rolled Container+Text pills.
    final labelOverride = parseHexColorNullable(
      component.colorPropRaw('labelColor'),
    );
    final showIcon = component.toggleProp('showIcon', false);
    final iconName = component.props['icon'] is String
        ? component.props['icon'] as String
        : 'send';
    final fullWidth = component.toggleProp('fullWidth', true);
    final disabled = component.toggleProp('disabled', false);
    final loading = component.toggleProp('loading', false);
    // Flat mode. The variants below are a "premium fintech" re-skin: Filled
    // paints a primary→darker gradient under a soft primary-tinted shadow, and
    // Outlined paints a gradient border and gradient-shaded text. A design
    // language built on flat colour and hairlines has no way to opt out of
    // that, so a flat CTA had to be hand-rolled as a Container+Text — which
    // renders identically and does nothing when tapped, the exact trap this
    // component exists to prevent. `flat` turns off the gradient, the shadow
    // and the label shader; nothing else changes, and it defaults false so
    // every document written before it renders byte-identically.
    final flat = component.toggleProp('flat', false);
    final label = component.props['label'] is String
        ? component.props['label'] as String
        : 'Continue';
    final variant = component.variant;

    // Lightened secondary for gradient end-stop (same lerp pattern as ProgressRing gradient)
    final lightened = Color.lerp(primary, Colors.white, 0.45) ?? primary;
    final gradient = LinearGradient(colors: [primary, lightened]);

    // The disabled pair used to be two hardcoded greys, which put every
    // disabled CTA off-palette in any design that isn't neutral-grey — the same
    // trap as the hardcoded white label above and the hardcoded gradient that
    // `flat` exists to turn off. A template's only alternative was two buttons
    // under opposite `visibleIf`, one of them inert. Empty means "keep the
    // original greys", so every document written before this renders
    // byte-identically.
    final disabledColor =
        parseHexColorNullable(component.colorPropRaw('disabledColor')) ??
        const Color(0xFFD1D5DB);
    final disabledTextColor =
        parseHexColorNullable(component.colorPropRaw('disabledLabelColor')) ??
        const Color(0xFF9CA3AF);

    // When loading, the spinner uses the same color as the label text would.
    // Filled/Gradient label is white; Outlined label is primary (gradient-shaded, use primary).
    final spinnerColorFilledGradient = disabled
        ? disabledTextColor
        : (labelOverride ?? Colors.white);

    Widget content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                spinnerColorFilledGradient,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) ...[
                catalogIcon(
                  iconName,
                  size: 18,
                  color: _iconColor(
                    variant,
                    disabled,
                    primary,
                    disabledTextColor,
                    labelOverride,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Flexible, not Expanded: FlexFit.loose keeps the label at its
              // intrinsic width whenever it fits (so a short label stays
              // centred with the icon, unchanged), and only lets it shrink —
              // and therefore ellipsise — when the row would otherwise
              // overflow.
              Flexible(
                child: _LabelWidget(
                  label: label,
                  variant: variant,
                  disabled: disabled,
                  primary: primary,
                  gradient: gradient,
                  disabledTextColor: disabledTextColor,
                  labelOverride: labelOverride,
                ),
              ),
            ],
          );

    final borderRadius = BorderRadius.circular(radius);
    // Generous vertical padding instead of a fixed height — gives the
    // button a taller, more premium footprint.
    const contentPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 20);
    // Subtle darker-primary gradient for the Filled variant.
    final filledGradient = flat
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary,
              Color.lerp(primary, Colors.black, 0.12) ?? primary,
            ],
          );
    // Soft primary-tinted shadow shared by Filled/Gradient.
    final buttonShadow = flat
        ? null
        : [
            BoxShadow(
              color: primary.withValues(alpha: 0.32),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ];

    Widget button;
    switch (variant) {
      case 'Gradient':
        button = Container(
          decoration: BoxDecoration(
            // Flat is honoured here too: the variant is named for its default
            // look, not for a promise that it must always be a gradient.
            gradient: (disabled || flat) ? null : gradient,
            color: disabled ? disabledColor : (flat ? primary : null),
            borderRadius: borderRadius,
            boxShadow: disabled ? null : buttonShadow,
          ),
          child: Padding(
            padding: contentPadding,
            child: Center(child: content),
          ),
        );
        break;
      case 'Outlined':
        button = _OutlinedGradientButton(
          label: label,
          showIcon: showIcon,
          iconName: iconName,
          primary: primary,
          // A one-stop "gradient" IS a solid colour, so flat mode needs no
          // second painter — the border and the label shader both resolve to
          // `primary` and read as flat.
          gradient: flat
              ? LinearGradient(colors: [primary, primary])
              : gradient,
          radius: radius,
          contentPadding: contentPadding,
          disabled: disabled,
          loading: loading,
          disabledColor: disabledColor,
          disabledTextColor: disabledTextColor,
          labelOverride: labelOverride,
        );
        break;
      default: // Filled
        button = Container(
          decoration: BoxDecoration(
            gradient: disabled ? null : filledGradient,
            // `color` carries the fill whenever there is no gradient to carry
            // it — i.e. when disabled, and now also in flat mode.
            color: disabled
                ? disabledColor
                : (filledGradient == null ? primary : null),
            borderRadius: borderRadius,
            boxShadow: disabled ? null : buttonShadow,
          ),
          child: Padding(
            padding: contentPadding,
            child: Center(child: content),
          ),
        );
    }

    return Align(
      alignment: Alignment.center,
      child: SizedBox(width: fullWidth ? double.infinity : null, child: button),
    );
  }

  Color _iconColor(
    String variant,
    bool disabled,
    Color primary,
    Color disabledTextColor,
    Color? labelOverride,
  ) {
    if (disabled) return disabledTextColor;
    if (labelOverride != null) return labelOverride;
    if (variant == 'Outlined') return primary;
    return Colors.white;
  }
}

// ── Label widget: white for Filled/Gradient, gradient shader for Outlined ──
class _LabelWidget extends StatelessWidget {
  final String label;
  final String variant;
  final bool disabled;
  final Color primary;
  final LinearGradient gradient;
  final Color disabledTextColor;
  final Color? labelOverride;

  const _LabelWidget({
    required this.label,
    required this.variant,
    required this.disabled,
    required this.primary,
    required this.gradient,
    required this.disabledTextColor,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    // ONE builder for all four branches, and every one of them ellipsises.
    // A plain Text here could not shrink, so a label wider than the button's
    // content box painted the striped overflow bar instead of the label —
    // and at 390px phone width that box is only 310px, i.e. a hard cliff at
    // ~20 characters of 15px w700. The IRIS template sat exactly on it
    // ("Complete Verification", 21 chars, overflowed by 10px); every other
    // template and every user-authored document had the same cliff, and it
    // moves closer at 360/375px, at larger text-scale factors, and in
    // longer-worded locales. The caller pairs this with a Flexible — both
    // halves are required: Flexible lets the box shrink, ellipsis decides
    // what happens when it does.
    Widget text(Color color) => Text(
      label,
      style: style.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    if (disabled) return text(disabledTextColor);

    // Checked before the Outlined branch: an explicit colour should win over
    // the gradient shader too, otherwise Outlined would be the one variant the
    // prop silently did nothing on.
    if (labelOverride != null) return text(labelOverride!);

    if (variant == 'Outlined') {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: text(Colors.white),
      );
    }

    return text(Colors.white);
  }
}

// ── Outlined variant: transparent fill, gradient border, gradient text ──
// Hand-rolled to avoid the `outline_gradient_button` third-party package.
class _OutlinedGradientButton extends StatelessWidget {
  final String label;
  final bool showIcon;
  final String iconName;
  final Color primary;
  final LinearGradient gradient;
  final double radius;
  final EdgeInsets contentPadding;
  final bool disabled;
  final bool loading;
  final Color disabledColor;
  final Color disabledTextColor;
  final Color? labelOverride;

  const _OutlinedGradientButton({
    required this.label,
    required this.showIcon,
    required this.iconName,
    required this.primary,
    required this.gradient,
    required this.radius,
    required this.contentPadding,
    required this.disabled,
    required this.loading,
    required this.disabledColor,
    required this.disabledTextColor,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderPainter(
        gradient: disabled ? null : gradient,
        fallbackColor: disabledColor,
        radius: radius,
        strokeWidth: 2,
      ),
      child: Padding(
        padding: contentPadding,
        child: Center(
          child: loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      disabled ? disabledTextColor : (labelOverride ?? primary),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showIcon) ...[
                      catalogIcon(
                        iconName,
                        size: 18,
                        color: disabled
                            ? disabledTextColor
                            : (labelOverride ?? primary),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // See the Flexible on the main variant's row above.
                    Flexible(
                      child: _LabelWidget(
                        label: label,
                        variant: 'Outlined',
                        disabled: disabled,
                        primary: primary,
                        gradient: gradient,
                        disabledTextColor: disabledTextColor,
                        labelOverride: labelOverride,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final LinearGradient? gradient;
  final Color fallbackColor;
  final double radius;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.fallbackColor,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = fallbackColor;
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.fallbackColor != fallbackColor ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;

  @override
  bool hitTest(Offset position) => false;
}
