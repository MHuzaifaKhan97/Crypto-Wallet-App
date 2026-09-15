import 'package:flutter/material.dart';
import '../runtime/models.dart';

/// Manifest: Avatar — variants [Small, Medium, Large], props [initials:text,
/// backgroundColor:color, textColor:color, size:number].
///
/// Ported from ksa_demo_app `lib/widgets/name_initials_circle/
/// name_initials_circle_widget.dart`. The original used AppTheme.primaryColor
/// and SizeConfig.screenWidth — both removed; colors now come from props
/// with DesignTheme fallback, size from variant + prop.
class Avatar extends StatelessWidget {
  final ComponentModel component;

  /// Readable-codegen entry (typed constructors, plan P4): named typed props
  /// → the same ComponentModel the registry path builds from JSON, so the
  /// internals below read `component.props` identically either way.
  Avatar({
    super.key,
    String variant = 'Classic',
    String? initials,
    Color? backgroundColor,
    Color? textColor,
    double? size,
  }) : component = ComponentModel(
         id: '',
         type: 'Avatar',
         variant: variant,
         props: typedProps({
           'initials': initials,
           'backgroundColor': backgroundColor,
           'textColor': textColor,
           'size': size,
         }),
         bindings: const {},
       );

  /// Registry / interpreter entry — the node's parsed model as-is.
  const Avatar.fromModel({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final bg = parseHexColor(
      component.colorPropRaw('backgroundColor'),
      theme.primary,
    );
    final fg = parseHexColor(
      component.colorPropRaw('textColor'),
      const Color(0xFFFFFFFF),
    );

    // Variant sets base diameter; prop overrides when different from default.
    final double variantSize = switch (component.variant) {
      'Small' => 36,
      'Large' => 64,
      _ => 48, // Medium (default)
    };
    // numberProp returns default (48) when prop is absent, so compare to 48 to
    // detect an explicit user override regardless of which variant is active.
    final double propSize = component.numberProp('size', 48).clamp(24.0, 96.0);
    final double diameter = (propSize != 48) ? propSize : variantSize;

    final rawInitials = component.props['initials'] is String
        ? component.props['initials'] as String
        : 'AK';
    final initials = rawInitials.toUpperCase().characters.take(2).string;

    final fontSize = (diameter * 0.4).clamp(10.0, 40.0);

    return Center(
      child: Container(
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(
          initials,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: fg,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
