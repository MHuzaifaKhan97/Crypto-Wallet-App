import 'package:flutter/widgets.dart';

/// Carries the generated app's live state map down the widget tree so a leaf
/// catalog widget can READ another field's current value at validation time —
/// what the `match` validator (e.g. confirm-password) needs.
///
/// Generated screens wrap their body in `StateScope(state:
/// ref.watch(appStateProvider), child: …)`; because it depends on the watched
/// provider, any field that reads it via [maybeOf] re-validates when the OTHER
/// field changes (so a confirm field turns valid the moment the two agree).
///
/// The design canvas never mounts a StateScope — inputs there are static — so
/// [maybeOf] returns null and cross-field rules degrade to a safe no-op.
class StateScope extends InheritedWidget {
  final Map<String, dynamic> state;
  const StateScope({super.key, required this.state, required super.child});

  static StateScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StateScope>();

  /// Current value of state variable [name] as a string ('' when absent/null,
  /// matching how empty text fields compare).
  String read(String name) {
    final v = state[name];
    return v == null ? '' : '$v';
  }

  @override
  bool updateShouldNotify(StateScope oldWidget) =>
      !identical(oldWidget.state, state);
}
