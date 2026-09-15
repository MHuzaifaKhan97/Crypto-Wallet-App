// Runtime model for the Design Document. Deliberately loose (Map-backed)
// since the document is arbitrary editor-authored JSON — the interpreter's
// job is to render whatever is there, defensively. `type` / `variant` on
// ComponentModel must match the component manifest and this registry's
// switch(type) — that string equality is the whole contract.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'node.dart' show parseValidatorsJson;

/// Runtime color token library. Empty on the canvas (the web editor's bridge
/// pre-resolves `token:`/`gradient:` refs before sending the document), and
/// populated by the generated app's AppColors so its node literals can keep
/// `token:<name>` / `gradient:<name>` references and stay DRY.
class DesignPalette {
  static Map<String, Color> colors = const {};
  static Map<String, Gradient> gradients = const {};
}

/// Parses a color value → a solid [Color]. Accepts:
///   - `#RRGGBB` / `#AARRGGBB`     hex literal
///   - `token:NAME`               a DesignPalette color
///   - `gradient:NAME` / `lg:…`   a gradient → its FIRST stop (so foreground
///                                 props like text/border degrade gracefully)
/// Falls back on anything else rather than throwing. Shared by the catalog
/// widgets and the host's theme application. Readable-codegen helpers: a
/// dynamic bound-prop value as String — or ''/null when it isn't one. Same
/// rule as every `is String` prop reader in node_view.dart, packaged so
/// emitted call sites stay a single evaluation and analyzer-clean whatever
/// the expression's static type is (a compiled `date(...)` is statically
/// String; `state.x` is not).
String strOrEmpty(dynamic v) => v is String ? v : '';
String? strOrNull(dynamic v) => v is String ? v : null;

/// Readable-codegen helpers for typed catalog constructors: a Color as the
/// '#RRGGBBAA' string parseHexColor reads (CSS order), and a typed-param map
/// → prop map (nulls dropped, Colors hex-encoded) so a widget's internals can
/// keep reading `component.props` exactly as the JSON path supplies them.
String colorToHex(Color c) {
  final v = c.toARGB32();
  final rgb = (v & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
  final a = ((v >> 24) & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#$rgb$a';
}

Map<String, dynamic> typedProps(Map<String, Object?> raw) {
  final out = <String, dynamic>{};
  raw.forEach((k, v) {
    if (v == null) return;
    out[k] = v is Color ? colorToHex(v) : v;
  });
  return out;
}

/// True for any string [parseHexColor] / [parseGradient] can turn into a
/// colour: `#RRGGBB(AA)`, `token:NAME`, `gradient:NAME`, `lg:…`.
bool isColorRef(String v) =>
    v.startsWith('#') ||
    v.startsWith('token:') ||
    v.startsWith('gradient:') ||
    v.startsWith('lg:');

Color parseHexColor(String? hex, Color fallback) {
  return parseHexColorNullable(hex) ?? fallback;
}

Color? parseHexColorNullable(String? hex) {
  if (hex == null) return null;
  if (hex.startsWith('token:')) return DesignPalette.colors[hex.substring(6)];
  if (hex.startsWith('gradient:') || hex.startsWith('lg:')) {
    final g = parseGradient(hex);
    return (g != null && g.colors.isNotEmpty) ? g.colors.first : null;
  }
  if (!hex.startsWith('#')) return null;
  var h = hex.substring(1);
  if (h.length == 6) {
    h = 'FF$h';
  } else if (h.length == 8) {
    // Convert CSS #RRGGBBAA to Flutter AARRGGBB
    h = '${h.substring(6, 8)}${h.substring(0, 6)}';
  } else {
    return null;
  }
  final value = int.tryParse(h, radix: 16);
  return value == null ? null : Color(value);
}

/// Parses a fill value into a [LinearGradient], or null if it isn't a gradient.
/// Accepts:
///   - `gradient:NAME`  → a DesignPalette gradient (generated app)
///   - `lg:ANGLE:HEX@AT,HEX@AT,…`  → a self-contained encoding the web bridge
///     emits for the canvas (angle in degrees: 0 = right, 90 = down)
LinearGradient? parseGradient(String? v) {
  if (v == null) return null;
  if (v.startsWith('gradient:')) {
    final g = DesignPalette.gradients[v.substring(9)];
    return g is LinearGradient ? g : null;
  }
  if (!v.startsWith('lg:')) return null;
  final head = v.substring(3);
  final sep = head.indexOf(':');
  if (sep < 0) return null;
  final angle = double.tryParse(head.substring(0, sep)) ?? 90.0;
  final colors = <Color>[];
  final stops = <double>[];
  for (final seg in head.substring(sep + 1).split(',')) {
    if (seg.isEmpty) continue;
    final at = seg.split('@');
    colors.add(parseHexColor(at[0], const Color(0x00000000)));
    stops.add(at.length > 1 ? (double.tryParse(at[1]) ?? 0) : 0);
  }
  if (colors.isEmpty) return null;
  final rad = angle * math.pi / 180.0;
  final dx = math.cos(rad), dy = math.sin(rad);
  return LinearGradient(
    colors: colors,
    stops: stops.length == colors.length ? stops : null,
    begin: Alignment(-dx, -dy),
    end: Alignment(dx, dy),
  );
}

/// P13 (data binding): looks up the first present, non-null value among
/// `candidateKeys` in a resolved data-slot map. A component's data slot maps
/// to an arbitrary user-authored API response shape (via the api-manager
/// feature's `responseMapping`), so a catalog widget can't assume ONE exact
/// field name for e.g. "the balance" — it checks a handful of common
/// candidates instead. Returns null (triggering the widget's own hardcoded
/// placeholder) if none of the candidates are present.
dynamic firstOf(Map<String, dynamic> map, List<String> candidateKeys) {
  for (final key in candidateKeys) {
    if (map.containsKey(key) && map[key] != null) return map[key];
  }
  for (final entry in map.entries) {
    for (final key in candidateKeys) {
      if (entry.key.toLowerCase() == key.toLowerCase() && entry.value != null)
        return entry.value;
    }
  }
  return null;
}

class ThemeModel {
  final String primary;
  final double radius;
  final String fontFamily;
  // Extended tokens (KSA port Phase 1): optional in the document, defaulted
  // here so old docs (primary/radius/fontFamily only) stay valid. These let
  // re-skinned catalog widgets match a source app's exact surface/text
  // palette instead of hardcoding neutrals.
  final String background;
  final String surface;
  final String textPrimary;
  final String textSecondary;

  const ThemeModel({
    required this.primary,
    required this.radius,
    required this.fontFamily,
    this.background = '#F3F4F6',
    this.surface = '#FFFFFF',
    this.textPrimary = '#111827',
    this.textSecondary = '#6B7280',
  });

  factory ThemeModel.fromJson(Map<String, dynamic>? json) => ThemeModel(
    primary: (json?['primary'] as String?) ?? '#6366F1',
    radius: (json?['radius'] as num?)?.toDouble() ?? 16,
    fontFamily: (json?['fontFamily'] as String?) ?? 'Inter',
    background: (json?['background'] as String?) ?? '#F3F4F6',
    surface: (json?['surface'] as String?) ?? '#FFFFFF',
    textPrimary: (json?['textPrimary'] as String?) ?? '#111827',
    textSecondary: (json?['textSecondary'] as String?) ?? '#6B7280',
  );
}

/// P12 (global theme): carries the document's theme down to every catalog
/// widget as the EXACT resolved color/radius a component should use when it
/// has no per-instance override. Deliberately NOT `Theme.of(context).
/// colorScheme.primary` — Material 3's `ColorScheme.fromSeed` tone-maps the
/// seed color into a derived palette, so `colorScheme.primary` is close to
/// but not guaranteed identical to the brand color the user actually picked.
/// This carries the raw parsed value instead, so "change brand primary" and
/// "component recolors" mean the exact same color, not an approximation.
class DesignTheme extends InheritedWidget {
  final Color primary;
  final double radius;
  final String fontFamily;
  // Extended tokens (KSA port Phase 1). Optional named with sensible neutral
  // defaults, so every existing call site — host.dart, codegen-generated
  // screens, and each widget's golden-test _wrap — keeps compiling without
  // passing them. Re-skinned widgets read these for surface/text fidelity.
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  // True only inside the Design Mode editor's own canvas (host.dart's single
  // DesignTheme instantiation passes true explicitly). Every codegen-emitted
  // DesignTheme(...) literal omits this, so it defaults false in every
  // generated app with zero codegen changes needed. Lets a catalog widget
  // that can't meaningfully preview in an iframe (a live camera, a real
  // WebView) render a static placeholder on canvas and the real thing only
  // in a built app — see catalog/webview.dart.
  final bool isCanvas;

  // Responsive web breakpoints (px), mirroring DesignDocument.breakpoints —
  // the width thresholds at which a node's `responsive.md`/`responsive.lg`
  // overrides apply (see NodeModel.resolveForWidth, node.dart). Defaulted
  // to the same conventional values (768 / 1024) the schema falls back to
  // when a document omits `breakpoints`, so every existing call site —
  // host.dart, codegen-generated screens, and each widget's golden-test
  // _wrap — keeps compiling unchanged with zero codegen changes needed,
  // same pattern as the KSA-port extended theme tokens above.
  final double bpMd;
  final double bpLg;

  const DesignTheme({
    super.key,
    required this.primary,
    required this.radius,
    required this.fontFamily,
    this.background = const Color(0xFFF3F4F6),
    this.surface = const Color(0xFFFFFFFF),
    this.textPrimary = const Color(0xFF111827),
    this.textSecondary = const Color(0xFF6B7280),
    this.isCanvas = false,
    this.bpMd = 768,
    this.bpLg = 1024,
    required super.child,
  });

  static DesignTheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<DesignTheme>();
    assert(
      result != null,
      'DesignTheme.of() called with no DesignTheme ancestor',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(DesignTheme oldWidget) =>
      primary != oldWidget.primary ||
      radius != oldWidget.radius ||
      fontFamily != oldWidget.fontFamily ||
      background != oldWidget.background ||
      surface != oldWidget.surface ||
      textPrimary != oldWidget.textPrimary ||
      textSecondary != oldWidget.textSecondary ||
      isCanvas != oldWidget.isCanvas ||
      bpMd != oldWidget.bpMd ||
      bpLg != oldWidget.bpLg;
}

class ComponentModel {
  final String id;
  final String type;
  final String variant;
  final Map<String, dynamic> props;
  final Map<String, dynamic> bindings;

  /// P13 (data binding): resolved SANDBOX values for this component's bound
  /// data slots, e.g. `{"account": {"balance": 24580.45, "currency": "SAR"}}`.
  /// Keyed by DataSlot.slot, matching `bindings`' keys. This is BRIDGE-ONLY —
  /// the editor computes it from the project's API groups + `bindings`
  /// (which IS persisted) and injects it into the document sent over
  /// postMessage; it's never part of the persisted Design Document itself,
  /// since real data at runtime comes from an actual API call post-codegen,
  /// not from a sample the editor cached. A component with no binding for a
  /// slot simply won't have that key here — catalog widgets must fall back
  /// to their placeholder content in that case (see BalanceCard/
  /// RecentTransactions).
  final Map<String, dynamic> data;

  /// Form validation (Pillar 3): validation rules for a TextInput node — see
  /// NodeModel.validators (node.dart) for the shape. Populated straight off
  /// the node's raw JSON (node_view.dart hands `node.raw` to
  /// ComponentModel.fromJson for every composite, and `validators` lives at
  /// the same top level as `bindValue`), so no extra threading is needed
  /// beyond parsing it here. Read by catalog/text_input.dart.
  final List<Map<String, dynamic>> validators;

  /// The set of interaction triggers this node declares (the keys of the
  /// node's `events` map — e.g. `{onTap, onChange}`). Parsed off the node's
  /// raw JSON alongside [validators], so a catalog widget can tell whether an
  /// event chain actually exists before firing it (TextInput gates its
  /// per-keystroke `onChange` on this, matching Switch's
  /// `node.events.contains('onChange')` guard in node_view.dart). The action
  /// steps themselves stay in the node and are dispatched via onEvent — only
  /// the key set is needed here.
  final Set<String> eventKeys;

  const ComponentModel({
    required this.id,
    required this.type,
    required this.variant,
    required this.props,
    required this.bindings,
    this.data = const {},
    this.validators = const [],
    this.eventKeys = const {},
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) => ComponentModel(
    id: (json['id'] as String?) ?? '',
    type: (json['type'] as String?) ?? '',
    variant: (json['variant'] as String?) ?? 'Classic',
    props: (json['props'] as Map?)?.cast<String, dynamic>() ?? const {},
    bindings: (json['bindings'] as Map?)?.cast<String, dynamic>() ?? const {},
    data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    validators: parseValidatorsJson(json['validators']),
    eventKeys:
        (json['events'] as Map?)?.keys.map((k) => '$k').toSet() ?? const {},
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'variant': variant,
    'props': props,
    if (bindings.isNotEmpty) 'bindings': bindings,
  };

  String colorProp(String key, String fallback) {
    final v = props[key];
    return v is String && isColorRef(v) ? v : fallback;
  }

  /// Like [colorProp], but returns null instead of a fallback when the prop
  /// isn't set — lets a catalog widget distinguish "no explicit override"
  /// from "explicitly set", so it can fall back to the document's theme
  /// (see [DesignTheme]) instead of a hardcoded widget-specific default.
  /// P12 (global theme): per-component overrides still win when present.
  ///
  /// Accepts every value shape [parseHexColor] understands — a `#` literal,
  /// `token:NAME` / `gradient:NAME` (DesignPalette, i.e. the generated
  /// AppColors) and `lg:…`. The canvas pre-resolves tokens before the host
  /// ever sees them, so this only matters in a BUILT app, where a `#`-only
  /// check silently dropped every token-coloured composite prop to the theme
  /// fallback (found by the P5 readable-vs-interpreter golden diff: a
  /// `token:c-danger` Log-out button rendered in the brand colour).
  String? colorPropRaw(String key) {
    final v = props[key];
    return v is String && isColorRef(v) ? v : null;
  }

  double numberProp(String key, double fallback) {
    final v = props[key];
    if (v is num) return v.toDouble();
    return fallback;
  }

  /// Like [numberProp], but returns null instead of a fallback — same
  /// override-vs-theme-default distinction as [colorPropRaw].
  double? numberPropRaw(String key) {
    final v = props[key];
    return v is num ? v.toDouble() : null;
  }

  bool toggleProp(String key, bool fallback) {
    final v = props[key];
    return v is bool ? v : fallback;
  }

  /// P13 (data binding): the resolved sandbox object for one data slot, or
  /// null if that slot has no binding (or the binding is broken/unresolved)
  /// — either way, the widget should fall back to its own placeholder.
  Map<String, dynamic>? dataSlot(String slot) {
    final v = data[slot];
    return v is Map ? v.cast<String, dynamic>() : null;
  }

  /// Same as [dataSlot], for a slot expected to hold a LIST (e.g.
  /// RecentTransactions' "transactions" slot) rather than a single object.
  List<dynamic>? dataSlotList(String slot) {
    final v = data[slot];
    return v is List ? v : null;
  }
}

class ScreenModel {
  final String id;
  final String name;
  final List<ComponentModel> components;

  const ScreenModel({
    required this.id,
    required this.name,
    required this.components,
  });

  factory ScreenModel.fromJson(Map<String, dynamic>? json) {
    if (json == null)
      return const ScreenModel(id: '', name: '', components: []);
    final rawComponents = json['components'];
    final components = <ComponentModel>[];
    if (rawComponents is List) {
      for (final c in rawComponents) {
        if (c is Map)
          components.add(ComponentModel.fromJson(c.cast<String, dynamic>()));
      }
    }
    return ScreenModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      components: components,
    );
  }
}
