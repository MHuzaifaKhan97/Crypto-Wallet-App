import 'package:flutter/material.dart';

// Studio X — Design Mode v2: the Node tree model (Pillar 1, host side).
//
// A screen's `root` is a NodeModel tree; every node is a primitive
// (Column/Row/Container/Text/…) or a catalog composite (BalanceCard/…).
// Parsing keeps the original JSON (`raw`) so composite nodes can be handed
// straight to ComponentModel.fromJson (see node_view.dart). Additive — v1 flat
// documents are wrapped into a Column root by the migrator (Dart mirror:
// nodeFromComponentsList).

/// Edge insets (px); any omitted side = 0.
class BoxInsetModel {
  final double top, right, bottom, left;
  const BoxInsetModel({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  static BoxInsetModel? fromJson(dynamic j) {
    if (j is num) {
      final v = j.toDouble();
      return BoxInsetModel(top: v, right: v, bottom: v, left: v);
    }
    if (j is! Map) return null;
    double d(String k) => (j[k] is num) ? (j[k] as num).toDouble() : 0;
    return BoxInsetModel(
      top: d('top'),
      right: d('right'),
      bottom: d('bottom'),
      left: d('left'),
    );
  }

  EdgeInsets get edgeInsets =>
      EdgeInsets.only(top: top, right: right, bottom: bottom, left: left);
}

/// Stack-child positioning.
class PositionModel {
  final double? top, right, bottom, left;
  const PositionModel({this.top, this.right, this.bottom, this.left});
  static PositionModel? fromJson(dynamic j) {
    if (j is! Map) return null;
    double? d(String k) => (j[k] is num) ? (j[k] as num).toDouble() : null;
    return PositionModel(
      top: d('top'),
      right: d('right'),
      bottom: d('bottom'),
      left: d('left'),
    );
  }
}

/// How a node is sized/placed by its parent (box model + flex + stack position).
class LayoutModel {
  /// double (px) | 'fill' | 'hug' | null.
  final Object? width;
  final Object? height;
  final double? flex;
  final BoxInsetModel? padding;
  final BoxInsetModel? margin;
  final String? alignSelf; // start|center|end|stretch
  final PositionModel? position;

  const LayoutModel({
    this.width,
    this.height,
    this.flex,
    this.padding,
    this.margin,
    this.alignSelf,
    this.position,
  });

  // Anything not on this list is DROPPED to null (intrinsic sizing) rather
  // than rejected, so a new size word has to be added here as well as in
  // node_view.dart's _screenDim — otherwise it parses, passes every document
  // check, and silently loses the size. That is exactly how `viewport` first
  // behaved: most screens just went intrinsic, and only the three whose
  // Column had a flex child failed loudly ("non-zero flex but incoming height
  // constraints are unbounded"), which is what caught it.
  static Object? _size(dynamic v) {
    if (v is num) return v.toDouble();
    if (v == 'fill' || v == 'hug') return v;
    if (v is String && (v.startsWith('screen') || v.startsWith('viewport'))) {
      return v;
    }
    return null;
  }

  static LayoutModel? fromJson(dynamic j) {
    if (j is! Map) return null;
    return LayoutModel(
      width: _size(j['width']),
      height: _size(j['height']),
      flex: (j['flex'] is num) ? (j['flex'] as num).toDouble() : null,
      padding: BoxInsetModel.fromJson(j['padding']),
      margin: BoxInsetModel.fromJson(j['margin']),
      alignSelf: j['alignSelf'] as String?,
      position: PositionModel.fromJson(j['position']),
    );
  }
}

/// One breakpoint's override of a node's base (phone) shape. Every field
/// is optional; an absent field means "no change at this breakpoint", not
/// "clear it". Parsed defensively like the rest of this file: a malformed
/// `responsive.md`/`responsive.lg` degrades to an override with no fields
/// set (i.e. a no-op) rather than throwing.
class NodeOverrideModel {
  final Map<String, dynamic>? props;
  final LayoutModel? layout;
  final bool? visible;

  const NodeOverrideModel({this.props, this.layout, this.visible});

  static NodeOverrideModel? fromJson(dynamic j) {
    if (j is! Map) return null;
    return NodeOverrideModel(
      props: (j['props'] is Map)
          ? (j['props'] as Map).cast<String, dynamic>()
          : null,
      layout: LayoutModel.fromJson(j['layout']),
      visible: j['visible'] is bool ? j['visible'] as bool : null,
    );
  }
}

/// A node in a screen's tree.
class NodeModel {
  final String id;
  final String type;
  final String variant;
  final Map<String, dynamic> props;
  final LayoutModel? layout;
  final List<NodeModel> children;
  final Map<String, List<NodeModel>> slots;

  /// The node drawn BETWEEN this flex's rendered children — never before the
  /// first, never after the last. Null when the node declares none, which is
  /// every node authored before this field existed.
  ///
  /// Not a child: it is deliberately absent from [children], so nothing that
  /// walks the tree (the editor's layers panel, node coverage, the selection
  /// overlay) sees N-1 phantom siblings. _buildFlex renders it with no
  /// `keyOf`, since one node object drawn many times would otherwise hand the
  /// same GlobalKey to every copy and throw.
  final NodeModel? separator;

  /// Static paint opacity for this node and its whole subtree, or null for
  /// "fully opaque, wrap nothing".
  ///
  /// Absent and 1.0 both parse to NULL, deliberately: Opacity forces a
  /// saveLayer on every paint, and a screen is ~360 nodes, so a pass-through
  /// wrapper is a real cost for no pixels. That makes "is there a layer?" a
  /// single null check at the one place that wraps ([_applyPaint]).
  final double? opacity;

  /// The original JSON for this node (id/type/variant/props/bindings/data) —
  /// passed straight to ComponentModel.fromJson for composite nodes.
  final Map<String, dynamic> raw;

  /// Pillar 2: event name (onTap, …) present on this node. The host only needs
  /// to know WHICH events exist to wire a GestureDetector; the action steps
  /// themselves are dispatched by the caller's onEvent callback.
  final Set<String> events;

  /// Whether this node should render — the AND of two independent signals:
  /// Pillar 3's compiled `visibleIf` (stored under the reserved `_visible`
  /// JSON key; only generated code sets it, the editor host never does) and
  /// R2's STATIC authored `Node.visible`. buildNode renders SizedBox.shrink()
  /// when false. [resolveForWidth] seeds its merge from this combined value
  /// BEFORE applying `responsive.md/lg.visible` overrides — so a base
  /// `visible:false` (the static field) plus `responsive.lg.visible:true`
  /// reveals a desktop-only node going up, exactly like a compiled
  /// `_visible:false` would have been overridden, since both feed the same
  /// seed.
  final bool visible;

  /// Pillar 3: two-way input binding target (a state variable name). When set
  /// on a TextInput, the generated app renders a real TextField that seeds from
  /// `state.[bindValue]` and writes typed input back via onInput. Null on the
  /// design canvas → the field stays a static placeholder.
  final String? bindValue;

  /// Pillar 2 + repeat: the in-scope repeat item(s) captured off `_ctx` at
  /// codegen time, keyed by their `repeat.as` name (e.g. `{'bene': {...}}`).
  /// Only set on interactive nodes inside a repeat; null everywhere else.
  /// Passed back to onEvent so a tapped repeated row's action steps can
  /// reference the tapped item.
  final Map<String, dynamic>? itemCtx;

  /// Form validation (Pillar 3): validation rules for an input node, e.g.
  /// `[{'kind': 'required', 'message': '...'}, {'kind': 'minLength', 'value': 6}]`.
  /// Evaluated in order by the input widget (see catalog/text_input.dart);
  /// empty when the node has none. Note: since `raw` already carries the full
  /// original node JSON (including `validators`), ComponentModel.fromJson(raw)
  /// parses this same list independently for the catalog widget — this field
  /// exists on NodeModel itself for symmetry with `bindValue` / callers that
  /// only have a NodeModel.
  final List<Map<String, dynamic>> validators;

  /// One-shot entrance animation: `{type, duration?, delay?, curve?}`, or null
  /// when the node declares none. Applied by buildNode for every component type
  /// (see node_view.dart), so no manifest or catalog widget knows about it.
  final AnimateModel? animate;

  /// Responsive web (mobile-first cascade): this node's base shape IS the
  /// phone design. At viewport width >= DesignDocument.breakpoints.md,
  /// `responsiveMd` merges over base; at >=.lg, `responsiveLg` merges over
  /// that (already md-merged) result. Both null when the node declares no
  /// `responsive` (or it was malformed). See [resolveForWidth].
  final NodeOverrideModel? responsiveMd;
  final NodeOverrideModel? responsiveLg;

  const NodeModel({
    required this.id,
    required this.type,
    required this.variant,
    required this.props,
    required this.raw,
    this.layout,
    this.children = const [],
    this.slots = const {},
    this.separator,
    this.opacity,
    this.events = const {},
    this.visible = true,
    this.bindValue,
    this.itemCtx,
    this.validators = const [],
    this.animate,
    this.responsiveMd,
    this.responsiveLg,
  });

  /// Resolves this node's EFFECTIVE shape at [width]: identity (this exact
  /// instance) when the node declares no `responsive` overrides at all;
  /// otherwise a merged copy with `responsiveMd` applied over the base when
  /// `width >= bpMd`, then `responsiveLg` applied over THAT (already
  /// md-merged) result when `width >= bpLg` — the mobile-first cascade
  /// described on [responsiveMd]. `props` merges shallowly key-by-key (an
  /// override key replaces the base key; keys the override doesn't mention
  /// are untouched); `layout` merges field-by-field the same way; `visible`
  /// is a straight replacement when the override sets it. `raw` is also
  /// updated (its `props` key swapped for the merged props) so composite/
  /// catalog nodes — which read `props` off `raw` via ComponentModel.fromJson,
  /// not off this typed field — see the same merged result (see node_view.dart
  /// buildNode). Children/slots are NOT touched: each child resolves itself
  /// independently when IT is built.
  NodeModel resolveForWidth(double width, double bpMd, double bpLg) {
    if (responsiveMd == null && responsiveLg == null) return this;

    var mergedProps = props;
    var mergedLayout = layout;
    // Seeded from the combined `visible` (static Node.visible AND compiled
    // visibleIf) computed in fromJson — R2's reveal-up cascade merges
    // responsive.md/lg.visible OVER this seed, same shallow-replace rule as
    // props/layout below.
    var mergedVisible = visible;
    var changed = false;

    void apply(NodeOverrideModel o) {
      if (o.props != null && o.props!.isNotEmpty) {
        mergedProps = {...mergedProps, ...o.props!};
      }
      if (o.layout != null) {
        mergedLayout = LayoutModel(
          width: o.layout!.width ?? mergedLayout?.width,
          height: o.layout!.height ?? mergedLayout?.height,
          flex: o.layout!.flex ?? mergedLayout?.flex,
          padding: o.layout!.padding ?? mergedLayout?.padding,
          margin: o.layout!.margin ?? mergedLayout?.margin,
          alignSelf: o.layout!.alignSelf ?? mergedLayout?.alignSelf,
          position: o.layout!.position ?? mergedLayout?.position,
        );
      }
      if (o.visible != null) mergedVisible = o.visible!;
      changed = true;
    }

    if (width >= bpMd && responsiveMd != null) apply(responsiveMd!);
    if (width >= bpLg && responsiveLg != null) apply(responsiveLg!);

    if (!changed) return this;

    final mergedRaw = identical(mergedProps, props)
        ? raw
        : {...raw, 'props': mergedProps};

    return NodeModel(
      id: id,
      type: type,
      variant: variant,
      props: mergedProps,
      raw: mergedRaw,
      layout: mergedLayout,
      children: children,
      slots: slots,
      separator: separator,
      opacity: opacity,
      events: events,
      visible: mergedVisible,
      bindValue: bindValue,
      itemCtx: itemCtx,
      validators: validators,
      animate: animate,
      responsiveMd: responsiveMd,
      responsiveLg: responsiveLg,
    );
  }

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    // Design-time eye toggle: a hidden child is dropped at PARSE time, not
    // rendered as SizedBox.shrink — the Column/Row child loop inserts `gap`
    // BETWEEN parsed children, so a shrunk phantom would still leave a double
    // gap where the node used to be. Filtering here makes hidden mean what
    // Figma's eye means: gone from layout entirely, while the document (and
    // the editor's tree) still carry the node. A node's OWN hidden flag is
    // additionally checked in buildNode, which is what covers the screen-root
    // position (a root is never someone's child).
    final childrenRaw = json['children'];
    final children = (childrenRaw is List)
        ? childrenRaw
              .whereType<Map>()
              .where((m) => m['hidden'] != true)
              .map((m) => NodeModel.fromJson(m.cast<String, dynamic>()))
              .toList()
        : <NodeModel>[];

    final slotsRaw = json['slots'];
    final slots = <String, List<NodeModel>>{};
    if (slotsRaw is Map) {
      slotsRaw.forEach((k, v) {
        if (v is List) {
          slots[k as String] = v
              .whereType<Map>()
              .where((m) => m['hidden'] != true)
              .map((m) => NodeModel.fromJson(m.cast<String, dynamic>()))
              .toList();
        }
      });
    }

    // A separator is parsed like any other node so it can be a Divider, a 1px
    // Container, or anything else a template's house style calls a hairline —
    // the reason this is a node and not a `dividers: true` flag.
    final separatorRaw = json['separator'];
    final separator = (separatorRaw is Map && separatorRaw['hidden'] != true)
        ? NodeModel.fromJson(separatorRaw.cast<String, dynamic>())
        : null;

    // Clamped and normalised HERE rather than at every use: a document can
    // arrive from a template or a hand edit that never met the write gate's
    // 0..1 range check, and Opacity ASSERTS its range in debug — a stray 55
    // would kill the canvas instead of painting something. >= 1 becomes null
    // so the no-wrap fast path covers "explicitly opaque" as well as absent.
    // A Spacer is an Expanded (ParentDataWidget) and must never be wrapped by
    // anything, which is the same rule _buildPrimitive already applies to
    // `layout` — so it never carries an opacity either.
    final opacityRaw = json['opacity'];
    final opacity =
        (opacityRaw is num && json['type'] != 'Spacer' && opacityRaw < 1)
        ? (opacityRaw < 0 ? 0.0 : opacityRaw.toDouble())
        : null;

    final eventsRaw = json['events'];
    final events = eventsRaw is Map
        ? eventsRaw.keys.map((k) => k.toString()).toSet()
        : <String>{};

    final responsiveRaw = json['responsive'];
    final responsiveMd = responsiveRaw is Map
        ? NodeOverrideModel.fromJson(responsiveRaw['md'])
        : null;
    final responsiveLg = responsiveRaw is Map
        ? NodeOverrideModel.fromJson(responsiveRaw['lg'])
        : null;

    return NodeModel(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      variant: (json['variant'] as String?) ?? 'Classic',
      props: (json['props'] as Map?)?.cast<String, dynamic>() ?? const {},
      layout: LayoutModel.fromJson(json['layout']),
      children: children,
      slots: slots,
      separator: separator,
      opacity: opacity,
      raw: json,
      events: events,
      // Combines the compiled runtime signal (`_visible`, from visibleIf) with
      // the static authored one (`visible`, R2) — either being false hides the
      // node. See the `visible` field doc above.
      visible: json['_visible'] != false && json['visible'] != false,
      bindValue: json['bindValue'] as String?,
      itemCtx: json['_itemCtx'] is Map
          ? (json['_itemCtx'] as Map).cast<String, dynamic>()
          : null,
      validators: parseValidatorsJson(json['validators']),
      animate: AnimateModel.fromJson(json['animate']),
      responsiveMd: responsiveMd,
      responsiveLg: responsiveLg,
    );
  }
}

/// A node's entrance-animation config. Parsed defensively: a malformed or
/// partial `animate` object falls back to sensible defaults rather than
/// throwing, since this JSON is hand-authorable in templates and the editor.
class AnimateModel {
  final String type;
  final int durationMs;
  final int delayMs;
  final String curve;

  const AnimateModel({
    required this.type,
    this.durationMs = 320,
    this.delayMs = 0,
    this.curve = 'easeOut',
  });

  /// Returns null for anything that isn't a map carrying a non-empty `type`,
  /// so callers can skip wrapping entirely instead of building a no-op.
  static AnimateModel? fromJson(Object? json) {
    if (json is! Map) return null;
    final type = json['type'];
    if (type is! String || type.isEmpty || type == 'none') return null;
    int asInt(Object? v, int fallback) => v is num ? v.round() : fallback;
    return AnimateModel(
      type: type,
      durationMs: asInt(json['duration'], 320),
      delayMs: asInt(json['delay'], 0),
      curve: json['curve'] is String ? json['curve'] as String : 'easeOut',
    );
  }
}

/// Defensively parses a node's `validators` JSON (a List of rule maps) into
/// `List<Map<String, dynamic>>`. Anything not shaped as List<Map> is dropped
/// rather than thrown — the document is arbitrary editor/codegen JSON.
/// Shared shape with ComponentModel's own parse (models.dart) since both read
/// the same `validators` key off a node's raw JSON.
List<Map<String, dynamic>> parseValidatorsJson(dynamic v) {
  if (v is! List) return const [];
  return v.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
}

NodeModel rootFromComponentsList(String screenId, List<dynamic> components) {
  return NodeModel(
    id: '${screenId}__root',
    type: 'Column',
    variant: 'Classic',
    props: const {
      'direction': 'vertical',
      'mainAxisSize': 'min',
      'crossAxisAlignment': 'stretch',
      // 16px matches the v1 host's per-slot bottom padding (see host.dart
      // _buildSlot) so a migrated screen keeps its original spacing.
      'gap': 16,
      // The host owns the scroll frame (SingleChildScrollView + padding), so
      // the screen root itself does not scroll — avoids a nested scroll view.
      'scrollable': false,
    },
    raw: const {},
    children: components
        .whereType<Map>()
        .map((m) => NodeModel.fromJson(m.cast<String, dynamic>()))
        .toList(),
  );
}
