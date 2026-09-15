import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../runtime/models.dart';

/// Manifest: QRCode — variants [Plain, Card], props
/// [data:text, size:number, foregroundColor:color, backgroundColor:color,
///  radius:number, caption:text].
///
/// Renders a REAL, scannable QR code (qr_flutter) from the literal `data`
/// string. `Plain` is just the code; `Card` centers it on a rounded surface
/// with a soft shadow and an optional caption — a shareable "show my QR" tile
/// used by the Merchant App template's receive-payment screen.
class QRCode extends StatelessWidget {
  final ComponentModel component;
  const QRCode({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);

    // qr_flutter throws on an empty payload — fall back to a placeholder string
    // so an unconfigured node still renders a valid (if meaningless) code.
    final raw = component.props['data'];
    final data = (raw is String && raw.trim().isNotEmpty)
        ? raw.trim()
        : 'https://studiox.app/pay';

    final size = component.numberProp('size', 200);
    final radius = component.numberProp('radius', 24);
    final fg = parseHexColor(
      component.colorPropRaw('foregroundColor'),
      theme.textPrimary,
    );
    final bg = parseHexColor(
      component.colorPropRaw('backgroundColor'),
      Colors.white,
    );
    final caption = component.props['caption'] is String
        ? (component.props['caption'] as String).trim()
        : '';

    final qr = QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: bg,
      // qr_flutter 4.x colors the code via eye + data-module styles
      // (foregroundColor is deprecated); keep both the same for a solid code.
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: fg),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: fg,
      ),
    );

    if (component.variant != 'Card') {
      return qr;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B2A4A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          qr,
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
