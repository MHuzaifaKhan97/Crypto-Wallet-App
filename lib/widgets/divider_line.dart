import 'package:flutter/material.dart';
import '../runtime/models.dart';

/// Manifest: DividerLine — variants [Solid, Inset, Dashed], props
/// [color:color (#E5E7EB), thickness:number 1-8, indent:number 0-48].
///
/// Ported from ksa_demo_app `lib/widgets/divider/divider_widget.dart`.
/// The original used AppTheme.dividerColor and a fixed horizontal padding —
/// both removed; color comes from prop with neutral fallback, indent/thickness
/// are props, and Dashed variant uses a CustomPainter (pure geometry, no app
/// coupling) to draw evenly-spaced dashes.
///
/// NOTE: named DividerLine (not Divider) to avoid collision with Flutter's
/// material.dart Divider. The manifest type string is still "Divider".
class DividerLine extends StatelessWidget {
  final ComponentModel component;

  /// Readable-codegen entry (typed constructors, plan P4): named typed props
  /// → the same ComponentModel the registry path builds from JSON, so the
  /// internals below read `component.props` identically either way.
  DividerLine({
    super.key,
    String variant = 'Classic',
    Color? color,
    double? thickness,
    double? indent,
  }) : component = ComponentModel(
         id: '',
         type: 'Divider',
         variant: variant,
         props: typedProps({
           'color': color,
           'thickness': thickness,
           'indent': indent,
         }),
         bindings: const {},
       );

  /// Registry / interpreter entry — the node's parsed model as-is.
  const DividerLine.fromModel({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    // DesignTheme is required for the contract (color could fallback to primary
    // in future), but DividerLine uses a neutral gray as its default rather
    // than the theme primary — a divider shouldn't inherit brand color.
    DesignTheme.of(context); // ensures DesignTheme ancestor is present
    final color = parseHexColor(
      component.colorPropRaw('color'),
      const Color(0xFFE5E7EB),
    );
    final thickness = component.numberProp('thickness', 1).clamp(1.0, 8.0);
    final indent = component.numberProp('indent', 0).clamp(0.0, 48.0);

    switch (component.variant) {
      case 'Inset':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: indent),
          child: Container(height: thickness, color: color),
        );
      case 'Dashed':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: indent),
          child: SizedBox(
            height: thickness.clamp(4.0, 8.0),
            child: CustomPaint(
              painter: _DashedLinePainter(
                color: color,
                strokeWidth: thickness,
                dashWidth: 6,
                gapWidth: 4,
              ),
            ),
          ),
        );
      default: // Solid
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: indent),
          child: Container(height: thickness, color: color),
        );
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  const _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.gapWidth != gapWidth;

  @override
  bool hitTest(Offset position) => false;
}
