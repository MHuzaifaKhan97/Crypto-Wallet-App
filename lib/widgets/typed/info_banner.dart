// Typed wrapper for the `InfoBanner` catalog component (Readable Code Export
// P7.4). The parameters are InfoBanner's manifest props.
//
// `build` makes the same buildComponent(ComponentModel…) call the untyped
// `ComponentModel.fromJson({…})` form makes, so this renders identical pixels
// while the screen files read as Flutter. The real widget lives in
// lib/widgets/ and is untouched — it is reached through registry.dart's
// buildComponent, exactly as the interpreter reaches it.
import 'package:flutter/material.dart';
import '../../runtime/models.dart';
import '../../runtime/registry.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    this.variant = 'Classic',
    this.title,
    this.message,
    this.icon,
    this.accentColor,
    this.value,
    this.rawProps = const {},
    this.bindings = const {},
    this.validators = const [],
    this.eventKeys = const {},
    this.data = const {},
    this.onChanged,
    this.onItemTap,
    this.onCompositeEvent,
    this.onSetVar,
  });

  /// Manifest variant — one of: Info, Success, Warning. Defaults to 'Classic',
  /// which is what ComponentModel.fromJson uses when a node declares none.
  final String variant;

  final String? title;
  final String? message;
  final String? icon;
  final Color? accentColor;

  /// The `bindValue` target prop. Deliberately untyped: the untyped path puts
  /// the raw bound value here and several catalog widgets coerce it themselves
  /// (int / num / String), so narrowing it would lose values, not type them.
  final Object? value;

  /// Prop values that cannot be expressed as a typed parameter, merged over
  /// the typed ones. A manifest `text` prop is not always a Dart String —
  /// `items` / `rows` are declared `text` only because the properties panel
  /// has no list editor, and at runtime they carry a JSON array the widget
  /// parses. So every value the emitter cannot type (a bound expression whose
  /// result is not statically a String, a gradient in a colour slot, a prop no
  /// manifest declares) is handed over EXACTLY as the untyped path handed it
  /// to `props` — no coercion, no default substitution.
  final Map<String, Object?> rawProps;

  /// The node's data-slot bindings, verbatim.
  final Map<String, dynamic> bindings;

  /// Form-validation rules (see NodeModel.validators).
  final List<Map<String, dynamic>> validators;

  /// The interaction triggers the node declares — a widget checks this before
  /// firing an event chain that may not exist.
  final Set<String> eventKeys;

  /// Resolved data slots for this component (`bindings`' keys), i.e. the
  /// host screen's `_data['<nodeId>']`.
  final Map<String, dynamic> data;

  /// Two-way value write for this node's own `bindValue`.
  final ValueChanged<String>? onChanged;

  /// Per-item tap (QuickActions and friends).
  final ValueChanged<int>? onItemTap;

  /// The component's own named events, with an optional per-tap row context.
  final void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent;

  /// Generic (varName, value) state write — BoundList's per-item tap.
  final void Function(String varName, dynamic value)? onSetVar;

  @override
  Widget build(BuildContext context) => buildComponent(
    ComponentModel.fromJson(<String, dynamic>{
      'type': 'InfoBanner',
      'variant': variant,
      'props': typedProps(<String, Object?>{
        'title': title,
        'message': message,
        'icon': icon,
        'accentColor': accentColor,
        'value': value,
        ...rawProps,
      }),
      if (bindings.isNotEmpty) 'bindings': bindings,
      if (validators.isNotEmpty) 'validators': validators,
      if (eventKeys.isNotEmpty)
        'events': <String, dynamic>{for (final k in eventKeys) k: true},
      if (data.isNotEmpty) 'data': data,
    }),
    onChanged: onChanged,
    onItemTap: onItemTap,
    onCompositeEvent: onCompositeEvent,
    onSetVar: onSetVar,
  );
}
