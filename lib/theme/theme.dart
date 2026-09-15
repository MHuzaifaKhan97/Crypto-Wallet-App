import 'package:flutter/material.dart';
import '../runtime/models.dart';

const String kDesignThemePrimary = 'token:brandIndigo';
const double kDesignThemeRadius = 16;
const String kDesignThemeFontFamily = 'Figtree';
const String kDesignThemeBackground = 'token:ground';
const String kDesignThemeSurface = 'token:surface';
const String kDesignThemeTextPrimary = 'token:ink';
const String kDesignThemeTextSecondary = 'token:inkMuted';

/// The project's color token library. Editing a token here recolors every
/// component that references it. Registered into DesignPalette (see below).
class AppColors {
  static const brandIndigo = Color(0xFF4F46E5);
  static const accentAmber = Color(0xFFF59E0B);
  static const ground = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const ink = Color(0xFF101828);
  static const inkMuted = Color(0xFF667085);
  static const hairline = Color(0xFFE4E7EC);
  static const gainGreen = Color(0xFF16A34A);
  static const lossRed = Color(0xFFDC2626);
  static const brandIndigoLight = Color(0xFF818CF8);
  static const surfaceAlt = Color(0xFFF1F3F9);
  static const inkInverse = Color(0xFFFFFFFF);
  static const accentStrong = Color(0xFFB45309);

  static final Map<String, Color> byName = <String, Color>{
    'brandIndigo': brandIndigo,
    'accentAmber': accentAmber,
    'ground': ground,
    'surface': surface,
    'surfaceRaised': surfaceRaised,
    'ink': ink,
    'inkMuted': inkMuted,
    'hairline': hairline,
    'gainGreen': gainGreen,
    'lossRed': lossRed,
    'brandIndigoLight': brandIndigoLight,
    'surfaceAlt': surfaceAlt,
    'inkInverse': inkInverse,
    'accentStrong': accentStrong,
  };

  static final Map<String, Gradient> gradients = <String, Gradient>{
    'heroIndigoViolet': LinearGradient(
      begin: Alignment(0.7071, -0.7071),
      end: Alignment(-0.7071, 0.7071),
      colors: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      stops: [0.000, 1.000],
    ),
  };
}

/// The one place this app's theme is applied. Every screen wraps its body in
/// `AppTheme.scope(child: ...)`; editing the constants above re-themes all of
/// them.
class AppTheme {
  static Widget scope({required Widget child}) => DesignTheme(
    primary: parseHexColor(kDesignThemePrimary, const Color(0xFF6366F1)),
    radius: kDesignThemeRadius,
    fontFamily: kDesignThemeFontFamily,
    background: background,
    surface: parseHexColor(kDesignThemeSurface, const Color(0xFFFFFFFF)),
    textPrimary: parseHexColor(
      kDesignThemeTextPrimary,
      const Color(0xFF111827),
    ),
    textSecondary: parseHexColor(
      kDesignThemeTextSecondary,
      const Color(0xFF6B7280),
    ),
    child: child,
  );

  /// The scaffold colour behind every screen.
  static Color get background =>
      parseHexColor(kDesignThemeBackground, const Color(0xFFF3F4F6));
}

/// Every distinct text style this app's screens use, named after the colour,
/// size and weight it carries. One method per style — a call site reads
/// `AppTextStyles.textPrimary15w600(theme)`.
class AppTextStyles {
  static TextStyle accentStrong13w400(DesignTheme theme) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.accentStrong,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle accentStrong18w700(DesignTheme theme) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.accentStrong,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle body(DesignTheme theme) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle bodyMuted(DesignTheme theme) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle caption(DesignTheme theme) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMuted,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle display(DesignTheme theme) => TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle figureMedium(DesignTheme theme) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: theme.textPrimary,
    fontFamily: 'Fragment Mono',
    letterSpacing: 0,
  );
  static TextStyle heading1(DesignTheme theme) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle heading2(DesignTheme theme) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexB3F8FAFC14w400(DesignTheme theme) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xB3F8FAFC),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexB3FFFFFF11w400(DesignTheme theme) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: const Color(0xB3FFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexB3FFFFFF11w700(DesignTheme theme) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: const Color(0xB3FFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexB3FFFFFF13w400(DesignTheme theme) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xB3FFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexCCFFFFFF11w700(DesignTheme theme) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: const Color(0xCCFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexCCFFFFFF13w400(DesignTheme theme) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xCCFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF12w600(DesignTheme theme) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF13w600(DesignTheme theme) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF14w700(DesignTheme theme) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF17w700(DesignTheme theme) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF18w700(DesignTheme theme) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF18w800(DesignTheme theme) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF20w700(DesignTheme theme) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle hexFFFFFF30w800(DesignTheme theme) => TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
    height: 34 / 30,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static TextStyle hexFFFFFF34w800(DesignTheme theme) => TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFFFFFFF),
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
    height: 38 / 34,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static TextStyle inkMuted12w600(DesignTheme theme) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.inkMuted,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle inkMuted13w400(DesignTheme theme) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
  static TextStyle inkMuted14w400(DesignTheme theme) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
    fontFamily: theme.fontFamily,
    letterSpacing: 0,
  );
}

/// Images, with this app's standard fallback tile when one fails to load.
class AppImage {
  static Widget asset(String path, {BoxFit fit = BoxFit.cover}) => Image.asset(
    path,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => _fallback(context),
  );

  static Widget network(String src, {BoxFit fit = BoxFit.cover}) =>
      Image.network(
        src,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );

  /// The tile shown for a missing or broken image.
  static Widget placeholder() => Builder(builder: _fallback);

  /// A source resolved at runtime: a bundled asset, a generated asset, a URL,
  /// or empty.
  static Widget source(String src, {BoxFit fit = BoxFit.cover}) {
    if (src.startsWith('bundled://')) {
      return asset('assets/${src.substring(10)}', fit: fit);
    }
    if (src.startsWith('asset://')) {
      return asset('assets/gen/${src.substring(8)}', fit: fit);
    }
    if (src.isEmpty) return placeholder();
    return network(src, fit: fit);
  }

  static Widget _fallback(BuildContext context) {
    final theme = DesignTheme.of(context);
    return Container(
      color: theme.surface,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: theme.textSecondary),
    );
  }
}

ThemeData buildDesignTheme() {
  DesignPalette.colors = AppColors.byName;
  DesignPalette.gradients = AppColors.gradients;
  final primary = parseHexColor(kDesignThemePrimary, const Color(0xFF6366F1));
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    fontFamily: kDesignThemeFontFamily,
  );
}
