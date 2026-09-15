import 'package:flutter/material.dart';
import '../widgets/quick_actions.dart';
import '../widgets/button.dart';
import '../widgets/list_row.dart';
import '../widgets/avatar.dart';
import '../widgets/info_banner.dart';
import '../widgets/divider_line.dart';
import '../widgets/text_input.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/amount_display.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/otp_input.dart';
import '../widgets/qr_code.dart';
import 'models.dart';

/// The interpreter's dispatch table. `component.type` strings here MUST match
/// the component manifest exactly — that string equality is the contract
/// between the properties panel, this canvas, and codegen.
///
/// Unknown types render a labeled, non-crashing placeholder — a malformed or
/// stale document (e.g. referencing a since-removed catalog type) should
/// never take the whole canvas down.
/// CC3 (custom widgets): user-defined widget classes, registered at app
/// startup by the GENERATED lib/runtime/custom_widget_registry.dart (absent on
/// the canvas, which is exactly why the canvas renders the labeled
/// placeholder below instead — it cannot compile user Dart).
final Map<String, Widget Function(ComponentModel)> customWidgetBuilders = {};

Widget buildComponent(
  ComponentModel component, {
  ValueChanged<String>? onChanged,
  ValueChanged<int>? onItemTap,
  // `[itemCtx]` (optional 2nd positional arg, added for DataTable): most
  // composites just forward the event name and rely on node_view.dart's own
  // default itemCtx (the node's static repeat context, if any) — see
  // node_view.dart's `onCompositeEvent: (ev, [rowCtx]) => onEvent(node0.id,
  // ev, rowCtx ?? node0.itemCtx)`. DataTable is the first composite to pass a
  // REAL per-tap value here (the tapped row's own map), which node_view.dart
  // then prefers over the static itemCtx for that one dispatch. Widening this
  // signature is backward compatible: a narrower `void Function(String)?`
  // (BoundList's own field type) still accepts a value of this wider type —
  // Dart's optional-parameter function subtyping — so BoundList/BalanceCard
  // below keep compiling and behaving unchanged.
  void Function(String event, [Map<String, dynamic>? itemCtx])?
  onCompositeEvent,
  // Generic (varName, value) state write — unlike `onChanged`, which is
  // always tied to THIS node's own `bindValue`, this lets a composite write
  // to several DIFFERENT named state vars from one interaction (BoundList's
  // per-item tap: several {stateVar, itemField} pairs configured on the node,
  // resolved against whichever item was tapped). Only BoundList uses it today.
  void Function(String varName, dynamic value)? onSetVar,
}) {
  try {
    switch (component.type) {
      case 'QuickActions':
        return QuickActions(component: component, onItemTap: onItemTap);
      case 'Button':
        return Button.fromModel(component: component);
      case 'ListRow':
        return ListRow.fromModel(component: component);
      case 'Avatar':
        return Avatar.fromModel(component: component);
      case 'InfoBanner':
        return InfoBanner(component: component);
      case 'Divider':
        return DividerLine.fromModel(component: component);
      case 'TextInput':
        return TextInput.fromModel(
          component: component,
          onChanged: onChanged,
          onCompositeEvent: onCompositeEvent,
        );
      case 'NumericKeypad':
        return NumericKeypad(component: component, onChanged: onChanged);
      case 'AmountDisplay':
        return AmountDisplay(component: component, onChanged: onChanged);
      case 'SegmentedTabs':
        return SegmentedTabs(
          component: component,
          onChanged: onChanged,
          onCompositeEvent: onCompositeEvent,
        );
      case 'OtpInput':
        return OtpInput(
          component: component,
          onChanged: onChanged,
          onCompositeEvent: onCompositeEvent,
        );
      case 'QRCode':
        return QRCode(component: component);
      default:
        return _UnknownComponentPlaceholder(type: component.type);
    }
  } catch (_) {
    // A malformed prop (bad color hex, wrong prop shape, etc.) must not crash
    // the whole screen — isolate the failure to this one widget's slot.
    return _UnknownComponentPlaceholder(type: component.type, broken: true);
  }
}

class _UnknownComponentPlaceholder extends StatelessWidget {
  final String type;
  final bool broken;
  const _UnknownComponentPlaceholder({required this.type, this.broken = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        broken ? '$type (render error)' : '$type (no renderer)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      ),
    );
  }
}
