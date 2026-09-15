import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'models.dart';
import 'motion.dart';
import 'node.dart';
import 'registry.dart';
import 'svg_support.dart';
import '../widgets/icons.dart';
import '../widgets/page_carousel.dart';
import '../widgets/span_text.dart';
import '../widgets/swipeable.dart';

// Studio X — Design Mode v2: the node-tree renderer (Pillar 1, host side).
//
// `buildNode` recursively renders a NodeModel tree: PRIMITIVES (layout +
// leaf widgets) are built inline here; COMPOSITES (catalog types like
// BalanceCard) are delegated to the existing registry `buildComponent`, so all
// 22 catalog widgets keep working unchanged. Self box-layout (padding/margin/
// size) is applied per node; flex and Stack-position are applied by the PARENT
// (Row/Column/Stack) since they only mean anything in that context.
//
// [keyOf] (optional): when supplied, every node's widget is wrapped in a
// KeyedSubtree keyed by node id, so the host can measure/select any node (see
// host.dart geometry reporting + hit-testing). Threaded through the whole
// recursion so nested nodes are keyed too.

/// Primitive node types this renderer handles inline. Everything else is
/// treated as a catalog composite and dispatched through buildComponent.
/// (Deliberately disjoint from existing composite type names — 'Button',
/// 'TextInput', 'Heading', 'Divider' are composites, not primitives here.)
const Set<String> kPrimitiveTypes = {
  'Column',
  'Row',
  'Stack',
  'Container',
  'Text',
  'Image',
  'Icon',
  'Spacer',
  'SizedBox',
  'Center',
  'Padding',
  'Spinner',
  'Switch',
  'Slider',
  'PageView',
  'Swipeable',
  'RichText',
  'Checkbox',
};

bool isPrimitiveType(String type) => kPrimitiveTypes.contains(type);

/// True if any DESCENDANT (not the node itself) is independently interactive —
/// a TextInput (needs focus) or a node with its own onTap. Such a node must not
/// have its own onTap capture all taps (see buildNode).
bool _hasInteractiveDescendant(NodeModel node) {
  for (final c in node.children) {
    if (c.type == 'TextInput') return true;
    if (c.events.contains('onTap')) return true;
    if (_hasInteractiveDescendant(c)) return true;
  }
  return false;
}

/// True when a node is PAINTED as non-interactive — `disabled`, or `loading`
/// (a Button swaps its label for a spinner). Both props are presentational in
/// the catalog widgets: the tap itself is wired here, at the node level, so
/// without this check a button showing a spinner still fired its onTap. That
/// is how one impatient double-tap sends two identical POSTs — the bug is
/// invisible until an API call is slow, and then it is a duplicate payment.
/// The props are read post-resolution, so `loading: {$bind: state.busy}` is a
/// real bool here.
bool _isInertNode(NodeModel node) =>
    node.props['disabled'] == true || node.props['loading'] == true;

/// Composite catalog types that dispatch their OWN per-item taps (see
/// QuickActions' `onItemTap`) rather than relying on a node-level onTap. A
/// node of one of these types must never also get the whole-node onTap wrap
/// below — that would layer an opaque GestureDetector over a widget that
/// already routes taps per-tile, stealing them before they reach the tile.
const Set<String> kSelfDispatchingTypes = {
  'QuickActions',
  'BalanceCard',
  'NumericKeypad',
  'SegmentedTabs',
  'BoundList',
  'DataTable',
  'SectionedTransactions',
  'AppBar',
  'OffersBanner',
};

typedef KeyOf = Key Function(String id);
typedef OnEvent =
    void Function(String nodeId, String event, [Map<String, dynamic>? itemCtx]);
typedef OnInput = void Function(String varName, dynamic value);

/// Render one node (and its subtree). [context] must be under a DesignTheme.
/// [onEvent] (Pillar 2): when a node declares an `onTap` event, its widget is
/// wrapped in a GestureDetector that calls onEvent(node.id, 'onTap') — the
/// caller (a generated screen) dispatches the action steps.
/// [onInput] (Pillar 3): when a node declares `bindValue`, its TextInput becomes
/// interactive and calls onInput(node.bindValue, typedValue) on every change.
Widget buildNode(
  BuildContext context,
  NodeModel node, {
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
}) {
  // Responsive web (mobile-first cascade), resolved FIRST so every check and
  // dispatch below — visibility, primitive/composite, layout, animation,
  // onTap wiring — sees the effective (breakpoint-merged) node rather than
  // the authored base. Single choke point, no per-widget changes, mirroring
  // how `animate` is integrated below. Children are untouched here: each
  // child resolves itself independently the next time buildNode recurses
  // into it (see NodeModel.resolveForWidth, node.dart).
  final designTheme = DesignTheme.of(context);
  final width = MediaQuery.of(context).size.width;
  final node0 = node.resolveForWidth(width, designTheme.bpMd, designTheme.bpLg);
  // Pillar 3: a node whose compiled visibleIf is false renders nothing. (Only
  // generated code sets `_visible`; the editor host leaves nodes visible.)
  // A breakpoint override's `visible: false` short-circuits here too, since
  // node0 already carries the resolved visibility.
  if (!node0.visible) return const SizedBox.shrink();
  // Design-time eye toggle: children are already filtered at parse time
  // (NodeModel.fromJson) so gaps close up; this guard covers the one position
  // with no parent to filter it — the screen root itself.
  if (node0.raw['hidden'] == true) return const SizedBox.shrink();
  final built = isPrimitiveType(node0.type)
      ? _buildPrimitive(context, node0, keyOf, onEvent, onInput)
      : buildComponent(
          ComponentModel.fromJson(node0.raw),
          onChanged: (onInput != null && node0.bindValue != null)
              ? (v) => onInput(node0.bindValue!, v)
              : null,
          onItemTap: onEvent != null
              ? (i) => onEvent(node0.id, 'qa:$i', node0.itemCtx)
              : null,
          // `rowCtx` (optional 2nd arg, DataTable's onRowTap): when a
          // composite passes a real per-tap value (the tapped row's own
          // map), prefer it over this node's static itemCtx (the enclosing
          // `repeat` context, if any) — see registry.dart's onCompositeEvent
          // param doc. Every other composite still only ever calls with 1
          // arg, so `rowCtx` stays null and this behaves exactly as before.
          onCompositeEvent: onEvent != null
              ? (ev, [rowCtx]) => onEvent(node0.id, ev, rowCtx ?? node0.itemCtx)
              : null,
          onSetVar: onInput,
        );
  Widget w = _applySelfLayout(context, built, node0.layout);
  // Static opacity + entrance animation, applied here so every component type
  // gets them from one place — no manifest prop, no catalog-widget change.
  // Wrapped OUTSIDE the self-layout so the padding/size travels with the node
  // as it slides in; wrapping inside would animate the content within a
  // stationary box.
  w = _applyPaint(w, node0);
  // A node's onTap wraps it in an opaque GestureDetector. Skip that when the
  // subtree has its own interactive children (a TextInput, or a node with its
  // own onTap) — otherwise a container/root onTap steals every tap and blocks
  // text fields from focusing and inner buttons from firing.
  if (onEvent != null &&
      node0.events.contains('onTap') &&
      !_isInertNode(node0) &&
      !_hasInteractiveDescendant(node0) &&
      !kSelfDispatchingTypes.contains(node0.type)) {
    w = _PressScale(
      onTap: () => onEvent(node0.id, 'onTap', node0.itemCtx),
      child: w,
    );
  }
  return keyOf == null ? w : KeyedSubtree(key: keyOf(node0.id), child: w);
}

/// Applies a node's static `opacity` and its entrance `animate` as ONE wrap.
///
/// Returning the child unchanged when it declares neither matters: wrapping
/// every node in a pass-through animation widget would add a StatefulWidget
/// and a ticker to all ~360 nodes of a screen for nothing, and a pass-through
/// Opacity would force a saveLayer on each of them on every paint.
///
/// The two TOGETHER are the case that breaks quietly. A node at `opacity 0.55`
/// with an entrance has to animate 0 → 0.55; a NodeEntrance whose fade ends at
/// 1 makes it flash to full opacity and then settle, which surfaces months
/// later as "the fade flashes" with nothing to point at. Handing the settled
/// value to the transition also keeps it at ONE compositing layer — an Opacity
/// nested inside the entrance would reach the same end value by multiplication
/// and pay for a second saveLayer on every frame of the animation.
///
/// An unknown effect name (a hand-authored typo, a document from a newer
/// editor) renders normally rather than failing the whole screen — but it must
/// still honour the static opacity, which is why the two are decided together
/// rather than in sequence.
Widget _applyPaint(Widget child, NodeModel node) {
  final opacity = node.opacity;
  final a = node.animate;
  final effect = a == null ? null : kNodeEffects[a.type];
  if (a == null || effect == null) {
    return opacity == null ? child : Opacity(opacity: opacity, child: child);
  }
  return NodeEntrance(
    effect: effect,
    duration: Duration(milliseconds: a.durationMs),
    delay: Duration(milliseconds: a.delayMs),
    curve: kNodeCurves[a.curve] ?? Curves.easeOut,
    opacity: opacity ?? 1.0,
    child: child,
  );
}

// ── Self box-layout (padding / size / margin), parent-independent ──────────
Widget _applySelfLayout(
  BuildContext context,
  Widget child,
  LayoutModel? layout,
) {
  if (layout == null) return child;
  Widget w = child;
  if (layout.padding != null)
    w = Padding(padding: layout.padding!.edgeInsets, child: w);
  final width = _screenDim(context, layout.width, false) ?? _dim(layout.width);
  final height =
      _screenDim(context, layout.height, true) ?? _dim(layout.height);
  if (width != null || height != null)
    w = SizedBox(width: width, height: height, child: w);
  if (layout.margin != null)
    w = Padding(padding: layout.margin!.edgeInsets, child: w);
  return w;
}

/// True when [_applySelfLayout] would wrap its child in another widget rather
/// than returning it untouched. Nodes whose ROOT widget is a ParentDataWidget
/// (today just Spacer → Expanded) must never be wrapped: the parent data would
/// land on a RenderObject whose parent isn't the Flex it was meant for, which
/// is a hard build failure, not a layout quirk. Keep in sync with
/// [_applySelfLayout] — every field it reads must be tested here.
bool _layoutWrapsChild(LayoutModel? l) =>
    l != null &&
    (l.padding != null ||
        l.margin != null ||
        l.width != null ||
        l.height != null);

double? _dim(Object? v) {
  if (v is double) return v;
  if (v == 'fill') return double.infinity;
  return null; // 'hug' or null → intrinsic
}

/// The space a screen body is actually laid out in: the device minus the
/// system bars.
///
/// Provided once per screen by host.dart, ABOVE the body's SafeArea — the only
/// place the real insets are still readable, because SafeArea zeroes both
/// `padding` and `viewPadding` for everything below it. So a node deep in the
/// tree cannot work this out for itself; it has to be told.
///
/// It measures the DEVICE, not the app: shell chrome is deliberately left in,
/// because a tab screen already pads for the floating nav bar itself and
/// subtracting it here too would double-count (which it did — s-profile
/// overflowed by exactly the bar's height until this was pinned down).
///
/// The MediaQuery fallback keeps standalone `buildNode` callers (widget tests,
/// goldens) working, and is exactly equivalent wherever nothing has consumed
/// an inset yet — which is every test surface, since none of them report any.
class ViewportScope extends InheritedWidget {
  const ViewportScope({
    super.key,
    required this.width,
    required this.height,
    required super.child,
  });

  final double width;
  final double height;

  static double dimOf(BuildContext context, bool isHeight) {
    final ViewportScope? scope = context
        .dependOnInheritedWidgetOfExactType<ViewportScope>();
    if (scope != null) return isHeight ? scope.height : scope.width;
    // viewPadding, NOT padding: a Scaffold with extendBody:true reports its
    // own bottom bar as `padding.bottom`, and subtracting app chrome here
    // would double-count against the clearance the screen already pads for.
    // viewPadding is the device's own insets and nothing else.
    return isHeight
        ? MediaQuery.sizeOf(context).height -
              MediaQuery.viewPaddingOf(context).vertical
        : MediaQuery.sizeOf(context).width -
              MediaQuery.viewPaddingOf(context).horizontal;
  }

  @override
  bool updateShouldNotify(ViewportScope old) =>
      old.width != width || old.height != height;
}

/// Resolves a 'screen' or 'viewport' layout value — either with an optional
/// `*multiplier` — to a concrete pixel dimension. Returns null for anything
/// else (fixed px, 'fill', 'hug', null) so callers fall back to `_dim`.
///
/// `screen` is the WHOLE device, status bar and gesture bar included.
/// `viewport` is what survives them.
///
/// The difference is invisible in the browser canvas, where there are no
/// system bars and `MediaQuery.padding` is all zeroes — and it is exactly the
/// bug that shipped: a `screen*1.0` root inside the body's
/// SafeArea(top: true) overflows by precisely the status-bar height, so
/// full-height screens fitted in the preview and scrolled on a phone.
///
/// Shell chrome (an app bar, a non-floating bottom nav) is NOT subtracted from
/// either — same caveat `screen` has always had, just a much smaller one.
double? _screenDim(BuildContext context, Object? v, bool isHeight) {
  if (v is! String) return null;
  final bool isViewport = v.startsWith('viewport');
  if (!isViewport && !v.startsWith('screen')) return null;
  final String prefix = isViewport ? 'viewport' : 'screen';
  final double base = isViewport
      ? ViewportScope.dimOf(context, isHeight)
      : (isHeight
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width);
  if (v == prefix) return base;
  if (v.startsWith('$prefix*')) {
    return base * (double.tryParse(v.substring(prefix.length + 1)) ?? 1.0);
  }
  return base;
}

// ── Primitives ─────────────────────────────────────────────────────────────
Widget _buildPrimitive(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  switch (node.type) {
    case 'Column':
      return _buildFlex(
        context,
        node,
        _effectiveAxis(node, Axis.vertical),
        keyOf,
        onEvent,
        onInput,
      );
    case 'Row':
      return _buildFlex(
        context,
        node,
        _effectiveAxis(node, Axis.horizontal),
        keyOf,
        onEvent,
        onInput,
      );
    case 'Stack':
      return _buildStack(context, node, keyOf, onEvent, onInput);
    case 'PageView':
      return _buildPageView(context, node, keyOf, onEvent, onInput);
    case 'Container':
      return _buildContainer(context, node, keyOf, onEvent, onInput);
    case 'Swipeable':
      return _buildSwipeable(context, node, keyOf, onEvent, onInput);
    case 'Text':
      return _buildText(context, node);
    case 'RichText':
      return _buildRichText(context, node, keyOf, onEvent, onInput);
    case 'Image':
      return _buildImage(context, node);
    case 'Icon':
      return _buildIcon(context, node);
    case 'Spacer':
      // A Spacer IS an Expanded — a ParentDataWidget, which MUST sit directly
      // inside its Row/Column or Flutter throws "Incorrect use of
      // ParentDataWidget" and the WHOLE screen fails to build (a blank canvas
      // / blank app, not just one misplaced gap). buildNode runs
      // _applySelfLayout over every node, so the moment this one carries any
      // layout width/height/padding/margin the Spacer ends up wrapped in a
      // SizedBox/Padding and the screen dies. An explicitly sized Spacer means
      // "a fixed gutter" anyway, so hand the sizing to _applySelfLayout and
      // emit a plain box rather than a flex Spacer.
      if (_layoutWrapsChild(node.layout)) return const SizedBox.shrink();
      return Spacer(
        flex: (node.props['flex'] is num)
            ? (node.props['flex'] as num).toInt()
            : 1,
      );
    case 'SizedBox':
      return SizedBox(
        width: (node.props['width'] is num)
            ? (node.props['width'] as num).toDouble()
            : null,
        height: (node.props['height'] is num)
            ? (node.props['height'] as num).toDouble()
            : null,
      );
    case 'Spinner':
      return _buildSpinner(context, node);
    case 'Switch':
      return _buildSwitch(context, node, onInput, onEvent);
    case 'Checkbox':
      return _buildCheckbox(context, node, onInput, onEvent);
    case 'Slider':
      return _buildSlider(context, node, onInput, onEvent);
    case 'Center':
      return Center(
        child: node.children.isEmpty
            ? null
            : buildNode(
                context,
                node.children.first,
                keyOf: keyOf,
                onEvent: onEvent,
                onInput: onInput,
              ),
      );
    case 'Padding':
      final inset =
          BoxInsetModel.fromJson(node.props['padding']) ??
          const BoxInsetModel();
      return Padding(
        padding: inset.edgeInsets,
        child: node.children.isEmpty
            ? null
            : buildNode(
                context,
                node.children.first,
                keyOf: keyOf,
                onEvent: onEvent,
                onInput: onInput,
              ),
      );
    default:
      return const SizedBox.shrink();
  }
}

/// True when [child] would render as nothing — the two guards at the top of
/// buildNode, checked from the PARENT so the gap can be skipped too. Without
/// this a `visibleIf`-hidden child left a hole the exact size of two gaps
/// (the one before it and the one after) wherever a conditional row sat
/// between real content, which is what put a chunk of dead space under
/// headings whose loading spinner had already gone away.
bool _rendersNothing(BuildContext context, NodeModel child) {
  final theme = DesignTheme.of(context);
  final resolved = child.resolveForWidth(
    MediaQuery.of(context).size.width,
    theme.bpMd,
    theme.bpLg,
  );
  return !resolved.visible || resolved.raw['hidden'] == true;
}

/// R1 — the reflow primitive: a Row can become a Column at a wider
/// breakpoint (or vice versa) with no new node type. `node` here is ALREADY
/// the post-`resolveForWidth` node (buildNode resolves before dispatching to
/// `_buildPrimitive`), so `props['axis']` reflects any
/// `responsive.md/lg.props.axis` override for the current viewport — it
/// rides the existing `props` cascade for free, exactly like any other prop.
/// `'row'`/`'column'` win explicitly; anything else (absent, a typo) falls
/// back to [fallback] — the type-derived default (Row -> horizontal, Column
/// -> vertical) every node had before `axis` existed, so a document that
/// never sets it is byte-for-byte unchanged.
///
/// Accepted debt (reduced scope of R1. `flutter analyze` does not catch it
/// either (static analysis, not a render). Real runtime overflow, if any,
/// only surfaces in an actual render at that breakpoint's width.
Axis _effectiveAxis(NodeModel node, Axis fallback) {
  final a = node.props['axis'];
  if (a == 'row') return Axis.horizontal;
  if (a == 'column') return Axis.vertical;
  return fallback;
}

/// [boundedMain]/[mainExtent] are set only by this function's own recursive
/// call — see the unbounded-flex resolution just below. `boundedMain == null`
/// means "not resolved yet"; a non-null value says whether `layout.flex`
/// children can be honoured here, and [mainExtent], when set, is the main-axis
/// extent this flex was bound to in order to honour them.
Widget _buildFlex(
  BuildContext context,
  NodeModel node,
  Axis axis,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput, {
  bool? boundedMain,
  double? mainExtent,
}) {
  final gap = (node.props['gap'] is num)
      ? (node.props['gap'] as num).toDouble()
      : 0.0;
  final scrollable = node.props['scrollable'] == true;
  final mainSize = (node.props['mainAxisSize'] == 'min')
      ? MainAxisSize.min
      : MainAxisSize.max;

  // ── The unbounded-flex resolution ──────────────────────────────────────
  //
  // `layout.flex` means "take a share of the free main-axis space". In an
  // UNBOUNDED main axis there is no free space to share, and every screen
  // root already sits in one: host.dart wraps every screen in a
  // SingleChildScrollView, and a `scrollable: true` Column adds another. The
  // old handling of that was a static `!scrollable` prop test, and it was
  // wrong in both directions:
  //
  //   * the flex was silently DROPPED under a scrollable flex — a Column that
  //     says "the pager fills the rest of the screen" rendered a pager with no
  //     height at all, which is how a PageView ended up at PageCarousel's 320px
  //     last-resort fallback with page content authored for ~700px overflowing
  //     out of it and painting over the copy underneath it;
  //   * and it was not dropped in a NON-scrollable flex that merely SITS in an
  //     unbounded axis (a plain Column inside a hug Container inside the scroll
  //     frame), where Flutter throws "RenderFlex children have non-zero flex
  //     but incoming height constraints are unbounded" and takes the whole
  //     screen down. Only debug asserts catch that: a release canvas silently
  //     lays the flex child out as if it had no flex at all.
  //
  // So ask the constraint, not the prop. When the main axis really is
  // unbounded, bind this flex to the space a full-height screen has —
  // `ViewportScope`, the same bound `layout.height: 'viewport'` resolves to —
  // so `flex` divides something real instead of nothing. Vertical only: a
  // horizontally scrollable Row is a content-width rail (templates rely on
  // flex being ignored there, and give their rail children fixed widths).
  //
  // A bare `Spacer` IS an Expanded, so it needs the same bind — but only where
  // it is actually built as one. Inside a scrollable flex it is already
  // collapsed to a shrink (see expandFlex below and the Spacer branch), which
  // is what every template with one is authored against; binding there would
  // change layouts that render correctly today.
  final bool wantsMainAxisSpace = node.children.any(
    (c) => c.layout?.flex != null || (!scrollable && c.type == 'Spacer'),
  );
  if (boundedMain == null && axis == Axis.vertical && wantsMainAxisSpace) {
    return LayoutBuilder(
      builder: (ctx, cs) {
        if (cs.hasBoundedHeight && !scrollable) {
          return _buildFlex(
            ctx,
            node,
            axis,
            keyOf,
            onEvent,
            onInput,
            boundedMain: true,
          );
        }
        // A scrollable flex hands its OWN child an unbounded axis, so its
        // incoming bound (when it has one) is the extent to fill; otherwise the
        // viewport is the only real bound in reach.
        final double extent = (scrollable && cs.hasBoundedHeight)
            ? cs.maxHeight
            : ViewportScope.dimOf(ctx, true);
        if (!extent.isFinite || extent <= 0) {
          return _buildFlex(
            ctx,
            node,
            axis,
            keyOf,
            onEvent,
            onInput,
            boundedMain: false,
          );
        }
        return _buildFlex(
          ctx,
          node,
          axis,
          keyOf,
          onEvent,
          onInput,
          boundedMain: true,
          mainExtent: extent,
        );
      },
    );
  }
  // Whether `layout.flex` (and a bare Spacer, which IS an Expanded) can be
  // honoured on this flex at all.
  final expandFlex = boundedMain ?? !scrollable;

  // Build children, inserting `gap` between them and wrapping flex children
  // in Expanded (only valid inside a Row/Column, hence handled here).
  final kids = <Widget>[];
  // Tracks whether anything has actually been laid out yet, so the gap goes
  // BETWEEN rendered children rather than at every index > 0.
  var emittedAny = false;
  // A separator sits exactly where the gap sits, so it inherits the gap's
  // whole edge-case story: it only ever goes BETWEEN two things that actually
  // rendered. That is what makes the last row's trailing divider impossible —
  // only this loop knows which child is last, which is precisely what a
  // per-item `Column [Row, Divider]` workaround cannot know (MCP issues log
  // #27). A repeat's items are ordinary children by the time they get here
  // (codegen spreads them; the bridge resolver clones them for Test Mode), so
  // one item means no separator and an empty list means none either.
  final separator = node.separator;
  for (var i = 0; i < node.children.length; i++) {
    final child = node.children[i];
    // The skip used to be gated on `gap > 0` alone. With a separator and no
    // gap, an invisible child would otherwise still collect a separator on
    // each side of the hole it left.
    if ((gap > 0 || separator != null) && _rendersNothing(context, child))
      continue;
    // A Spacer fills the free main-axis space — but a SCROLLABLE flex has no
    // free space to fill (its main axis is unbounded), and Flutter throws
    // "RenderFlex children have non-zero flex but incoming constraints are
    // unbounded", again failing the whole screen. Render it as nothing, which
    // is what "expand into zero free space" already means. Same reasoning as
    // the `!scrollable` guard on layout.flex just below — that one was already
    // here; Spacer built its own Expanded and slipped past it.
    Widget w =
        (!expandFlex && child.type == 'Spacer' && child.layout?.flex == null)
        ? _applySelfLayout(context, const SizedBox.shrink(), child.layout)
        : buildNode(
            context,
            child,
            keyOf: keyOf,
            onEvent: onEvent,
            onInput: onInput,
          );
    final flex = child.layout?.flex;
    if (flex != null && expandFlex)
      w = Expanded(flex: flex.toInt().clamp(1, 1000), child: w);
    if (emittedAny && gap > 0) {
      kids.add(
        axis == Axis.vertical ? SizedBox(height: gap) : SizedBox(width: gap),
      );
    }
    if (emittedAny && separator != null) {
      // The separator sits INSIDE the gap, with the gap repeated after it, so
      // it lands exactly where a hand-placed Divider child in a gapped Column
      // already lands (gap on both sides — the shape every template's eye is
      // calibrated to). keyOf is deliberately not passed down: this is one
      // node object drawn N-1 times, and keyOf memoises ONE GlobalKey per node
      // id, so every copy would share a key and throw "Duplicate GlobalKey".
      // It is a property of the container, not a child, so it is not
      // selectable on the canvas either.
      kids.add(
        buildNode(context, separator, onEvent: onEvent, onInput: onInput),
      );
      if (gap > 0) {
        kids.add(
          axis == Axis.vertical ? SizedBox(height: gap) : SizedBox(width: gap),
        );
      }
    }
    kids.add(w);
    emittedAny = true;
  }

  final effectiveMain = scrollable ? MainAxisSize.min : mainSize;
  final mainAxisAlignment = _mainAxis(node.props['mainAxisAlignment']);
  final crossAxisAlignment = _crossAxis(node.props['crossAxisAlignment']);

  // Use the idiomatic Row/Column (Flex subclasses) — matches what codegen
  // emits and keeps `find.byType(Row)`-style checks meaningful.
  final flex = axis == Axis.vertical
      ? Column(
          mainAxisSize: effectiveMain,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: kids,
        )
      : Row(
          mainAxisSize: effectiveMain,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: kids,
        );

  // The bound the resolution above chose, applied INSIDE this node's own
  // scroll view (outside it, the scroll view would still hand the flex an
  // unbounded axis and nothing would have changed).
  final Widget body = mainExtent == null
      ? flex
      : (axis == Axis.vertical
            ? SizedBox(height: mainExtent, child: flex)
            : SizedBox(width: mainExtent, child: flex));

  if (scrollable) {
    // Clip.none — SingleChildScrollView defaults to Clip.hardEdge, which
    // clips flush to its own bounds. Those bounds sit right at whatever
    // padding wraps it (a screen's outer padding almost always wraps a
    // scrollable content column), so any child's elevation shadow bleeding
    // into that padding gets cut off at the edge — cards flush against the
    // scroll edge render with no visible shadow on that side. Nothing here
    // relies on the scrollview clipping its content (hit-testing and layout
    // are unaffected), so there's no correctness downside to letting
    // decorative shadows bleed into the padding gutter they already have room in.
    return SingleChildScrollView(
      scrollDirection: axis,
      clipBehavior: Clip.none,
      child: body,
    );
  }
  return body;
}

Widget _buildStack(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  return Stack(
    children: node.children.map((child) {
      final w = buildNode(
        context,
        child,
        keyOf: keyOf,
        onEvent: onEvent,
        onInput: onInput,
      );
      final pos = child.layout?.position;
      if (pos != null) {
        return Positioned(
          top: pos.top,
          right: pos.right,
          bottom: pos.bottom,
          left: pos.left,
          child: w,
        );
      }
      return w;
    }).toList(),
  );
}

/// PageView — a swipeable page carousel. Every CHILD node is one page, built
/// through the same buildNode recursion a Column uses (so keyOf/onEvent/
/// onInput thread into each slide). The carousel itself is a StatefulWidget
/// ([PageCarousel] — the same public widget the readable code export emits;
/// see its doc for the prop contract).
Widget _buildPageView(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  final theme = DesignTheme.of(context);
  final pages = <Widget>[
    for (final child in node.children)
      buildNode(
        context,
        child,
        keyOf: keyOf,
        onEvent: onEvent,
        onInput: onInput,
      ),
  ];
  final p = node.props;
  double numOr(String k, double d) =>
      (p[k] is num) ? (p[k] as num).toDouble() : d;
  final explicitHeight = numOr('height', 0);
  // Two-way binding: state-codegen / the Test Runtime inject the bound
  // variable as props.value (the current page index); out-of-range or
  // non-numeric → first page.
  final initial = carouselPageIndex(p['value'], pages.length);
  return PageCarousel(
    pages: pages,
    // Canvas (the editor's own iframe, incl. storyboard thumbnails): never
    // auto-advance — a moving canvas is distracting and thumbnails must be
    // deterministic. Swipe + dot taps still work there. Test Mode and the
    // built app (isCanvas false) auto-slide. Same DesignTheme.isCanvas gate
    // FilePicker/WebView use for their static-on-canvas behaviour.
    autoSlide: p['autoSlide'] == true && !theme.isCanvas,
    interval: Duration(
      milliseconds: numOr('intervalMs', 3000).clamp(100, 600000).toInt(),
    ),
    loop: p['loop'] != false,
    showDots: p['showDots'] != false,
    dotColor: (p['dotColor'] is String)
        ? parseHexColor(
            p['dotColor'] as String,
            theme.textSecondary.withValues(alpha: 0.35),
          )
        : theme.textSecondary.withValues(alpha: 0.35),
    activeDotColor: (p['activeDotColor'] is String)
        ? parseHexColor(p['activeDotColor'] as String, theme.primary)
        : theme.primary,
    dotSize: numOr('dotSize', 8),
    activeDotWidth: numOr('activeDotWidth', 20),
    overlayDots: p['dotsPosition'] == 'overlay',
    dotsAlign: (p['dotsAlign'] is String) ? p['dotsAlign'] as String : 'center',
    // A PageView needs a bounded height. Resolution order: the `height` prop
    // → the node's own layout.height (applied OUTSIDE by _applySelfLayout, so
    // the inner widget just fills whatever bound it gets) → 320.
    explicitHeight: explicitHeight > 0 ? explicitHeight : null,
    initialPage: initial,
    onPageChanged: (index) {
      if (onInput != null && node.bindValue != null)
        onInput(node.bindValue!, index);
      // Page index travels as the event's item context (`item.page` in the
      // step expressions) — the same optional 3rd-arg channel DataTable uses
      // for its tapped-row map; a `repeat` ctx, if any, is kept alongside.
      if (onEvent != null && node.events.contains('onPageChanged')) {
        onEvent(node.id, 'onPageChanged', {...?node.itemCtx, 'page': index});
      }
    },
  );
}

/// Swipeable: one child row, a destructive action revealed behind it. The
/// action is dispatched as the node's own `onAction` event, carrying the
/// repeat item context so a swiped row inside a `for each` knows which item
/// it was — exactly like a row onTap. See catalog/swipeable.dart for why this
/// reveals-then-taps instead of using Flutter's Dismissible.
Widget _buildSwipeable(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  // Exactly one child: the row. More than one and only the first is wrapped —
  // silently dropping the rest would be worse than showing them unwrapped, so
  // the extras render in a Column beneath it.
  final kids = node.children
      .map(
        (c) => buildNode(
          context,
          c,
          keyOf: keyOf,
          onEvent: onEvent,
          onInput: onInput,
        ),
      )
      .toList();
  final child = kids.isEmpty
      ? const SizedBox.shrink()
      : (kids.length == 1
            ? kids.first
            : Column(mainAxisSize: MainAxisSize.min, children: kids));
  String? colorProp(String k) =>
      node.props[k] is String ? node.props[k] as String : null;
  return Swipeable(
    actionLabel: node.props['actionLabel'] is String
        ? node.props['actionLabel'] as String
        : 'Delete',
    actionIcon: node.props['actionIcon'] is String
        ? node.props['actionIcon'] as String
        : 'delete',
    actionColor: colorProp('actionColor'),
    actionTextColor: colorProp('actionTextColor'),
    actionWidth: node.props['actionWidth'] is num
        ? (node.props['actionWidth'] as num).toDouble()
        : 96,
    direction: node.props['direction'] is String
        ? node.props['direction'] as String
        : 'endToStart',
    radius: node.props['radius'] is num
        ? (node.props['radius'] as num).toDouble()
        : null,
    dismissOnFullSwipe: node.props['dismissOnFullSwipe'] == true,
    onAction: onEvent == null
        ? null
        : () => onEvent(node.id, 'onAction', node.itemCtx),
    child: child,
  );
}

Widget _buildContainer(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  final theme = DesignTheme.of(context);
  // Fill can be a solid color OR a gradient (token/gradient ref or `lg:` encoding).
  final fill = node.props['color'];
  final gradient = fill is String ? parseGradient(fill) : null;
  final color = (gradient == null && fill is String)
      ? parseHexColor(fill, Colors.transparent)
      : null;
  final radius = (node.props['radius'] is num)
      ? (node.props['radius'] as num).toDouble()
      : 0.0;
  final radiusCorners = (node.props['radiusCorners'] is String)
      ? node.props['radiusCorners'] as String
      : 'all';
  BorderRadius? borderRadius;
  if (radius > 0) {
    final r = Radius.circular(radius);
    switch (radiusCorners) {
      case 'top':
        borderRadius = BorderRadius.vertical(top: r);
        break;
      case 'bottom':
        borderRadius = BorderRadius.vertical(bottom: r);
        break;
      case 'left':
        borderRadius = BorderRadius.horizontal(left: r);
        break;
      case 'right':
        borderRadius = BorderRadius.horizontal(right: r);
        break;
      case 'topLeft':
        borderRadius = BorderRadius.only(topLeft: r);
        break;
      case 'topRight':
        borderRadius = BorderRadius.only(topRight: r);
        break;
      case 'bottomLeft':
        borderRadius = BorderRadius.only(bottomLeft: r);
        break;
      case 'bottomRight':
        borderRadius = BorderRadius.only(bottomRight: r);
        break;
      default:
        borderRadius = BorderRadius.circular(radius);
    }
  }
  final borderColor = (node.props['borderColor'] is String)
      ? parseHexColor(node.props['borderColor'] as String, theme.textSecondary)
      : null;
  final borderWidth = (node.props['borderWidth'] is num)
      ? (node.props['borderWidth'] as num).toDouble()
      : 0.0;
  final elevation = (node.props['elevation'] is num)
      ? (node.props['elevation'] as num).toDouble()
      : 0.0;
  final padding = BoxInsetModel.fromJson(node.props['padding']);
  final blur = (node.props['blur'] is num)
      ? (node.props['blur'] as num).toDouble()
      : 0.0;
  // `clip` — ClipRRect on the box itself: Container clips its child to the
  // decoration's own shape (the rounded rect), INSIDE the decoration, so the
  // shadow and border still paint and only the child is cut.
  final clip = node.props['clip'] == true;

  final Widget box = Container(
    clipBehavior: clip ? Clip.antiAlias : Clip.none,
    padding: padding?.edgeInsets,
    decoration: BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: borderRadius,
      border: (borderColor != null && borderWidth > 0)
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: const Color(0x1F000000),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation * 0.5),
              ),
            ]
          : null,
    ),
    child: node.children.isEmpty
        ? null
        : buildNode(
            context,
            node.children.first,
            keyOf: keyOf,
            onEvent: onEvent,
            onInput: onInput,
          ),
  );

  // `blur` — frosted glass: blurs whatever is BEHIND this container, so the
  // card takes on the colour of the artwork under it instead of sitting on it
  // as a flat white panel.
  //
  // Two things are load-bearing. The ClipRRect must WRAP the BackdropFilter,
  // not sit inside it: a BackdropFilter samples the whole layer beneath it and
  // paints unbounded, so without an outer clip the blur bleeds across the
  // entire screen rather than stopping at the card's corners. And the fill has
  // to be translucent — a solid `color` hides the very thing being blurred,
  // which makes the prop look broken rather than absent.
  if (blur <= 0) return box;
  final Widget glass = ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: box,
    ),
  );
  if (elevation <= 0) return glass;
  // The shadow has to be drawn OUTSIDE the clip. A shadow is painted beyond
  // the widget's own bounds by definition, so the ClipRRect above removes it
  // entirely — `elevation` and `blur` together would silently lose the
  // shadow, which looks like the elevation slider doing nothing.
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: const Color(0x1F000000),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation * 0.5),
        ),
      ],
    ),
    child: glass,
  );
}

Widget _buildText(BuildContext context, NodeModel node) {
  // Matches every other prop reader in this file (color/size/etc.): check
  // `is String` before casting. A hard `as String?` crashes the WHOLE
  // screen's build the moment `text` is anything else — e.g. a `{$bind}`
  // expression object, which the canvas doesn't resolve for Text (only
  // codegen does; other bound props like AmountDisplay's `value` already
  // fall back to a default here rather than throwing).
  final text = (node.props['text'] is String)
      ? node.props['text'] as String
      : '';
  return Text(
    text,
    textAlign: _textAlign(node.props['align']),
    style: _textStyleOf(context, node.props),
  );
}

/// The TextStyle a Text node's props describe. Shared by the Text primitive
/// and every run of a RichText, so a span and a Text with the same props are
/// the same pixels.
TextStyle _textStyleOf(BuildContext context, Map<String, dynamic> props) {
  final theme = DesignTheme.of(context);
  final size = (props['size'] is num)
      ? (props['size'] as num).toDouble()
      : 14.0;
  final color = (props['color'] is String)
      ? parseHexColor(props['color'] as String, theme.textPrimary)
      : theme.textPrimary;
  // Per-node family, falling back to the app's. Set by a typography token
  // whose `fontFamily` names one, or typed directly on the node. `is String`
  // + non-empty rather than a cast: a prop can legitimately hold an
  // unresolved `{$bind}` MAP, and casting one throws during build, which
  // takes the whole screen down instead of one Text — the guard every other
  // prop read in this file already uses.
  final family =
      (props['fontFamily'] is String &&
          (props['fontFamily'] as String).isNotEmpty)
      ? props['fontFamily'] as String
      : theme.fontFamily;
  // Line height in PX (not a multiplier): the value a design file states —
  // "13/18" is fontSize 13, lineHeight 18. 0 / absent → the font's own
  // metrics, which is what every Text authored before this prop existed gets.
  // `even` leading distribution so the extra leading splits half above, half
  // below the glyphs — the CSS/Figma model — rather than Flutter's default
  // ascent-weighted split, which would push every line visually downward.
  final lineHeight = (props['lineHeight'] is num)
      ? (props['lineHeight'] as num).toDouble()
      : 0.0;
  return TextStyle(
    fontSize: size,
    fontWeight: _fontWeight(props['weight']),
    color: color,
    fontFamily: family,
    // Authored tracking, else 0 EXPLICITLY. A null letterSpacing merges
    // Material 3's ambient bodyMedium tracking (0.25) into every Text — 3%
    // wider runs than the font's own advances, enough to move a paragraph's
    // WRAP POINTS off the design's. Figma's default tracking is 0.
    letterSpacing: (props['letterSpacing'] is num)
        ? (props['letterSpacing'] as num).toDouble()
        : 0,
    height: lineHeight > 0 ? lineHeight / size : null,
    leadingDistribution: lineHeight > 0 ? TextLeadingDistribution.even : null,
    decoration: _textDecoration(props['decoration']),
  );
}

/// `decoration` — underline (a link) or lineThrough (a struck-out old
/// price). Absent / 'none' → null, which is what every Text had before.
TextDecoration? _textDecoration(Object? v) {
  switch (v) {
    case 'underline':
      return TextDecoration.underline;
    case 'lineThrough':
      return TextDecoration.lineThrough;
    default:
      return null;
  }
}

/// `RichText` — one paragraph from several differently styled runs, any of
/// which can be tapped ("I agree to the [Terms] and [Privacy Policy]").
///
/// Each `Text` child is a RUN, not a widget: its props (merged over the
/// RichText's own, so a run only states what differs) become a TextSpan
/// style, and its own `onTap` becomes a tap on those glyphs — dispatched
/// under the CHILD's id, so the Interactions panel works on a selected run
/// exactly as on any Text. Any other child (an Icon, a small Image) sits on
/// the line as an inline widget and is built as a normal node.
///
/// A run is never passed through buildNode, so nothing else buildNode does
/// applies to it: no self-layout, no opacity/animation, no canvas rect (a run
/// is selected from the layers tree, not by clicking the canvas). Visibility
/// is honoured here, with the same check buildNode's parents use.
Widget _buildRichText(
  BuildContext context,
  NodeModel node,
  KeyOf? keyOf,
  OnEvent? onEvent,
  OnInput? onInput,
) {
  final theme = DesignTheme.of(context);
  final width = MediaQuery.of(context).size.width;
  final parts = <SpanTextPart>[];
  for (final child in node.children) {
    if (_rendersNothing(context, child)) continue;
    if (child.type != 'Text') {
      parts.add(
        SpanTextPart(
          widget: buildNode(
            context,
            child,
            keyOf: keyOf,
            onEvent: onEvent,
            onInput: onInput,
          ),
        ),
      );
      continue;
    }
    final run = child.resolveForWidth(width, theme.bpMd, theme.bpLg);
    parts.add(
      SpanTextPart(
        text: (run.props['text'] is String) ? run.props['text'] as String : '',
        style: _textStyleOf(context, {...node.props, ...run.props}),
        onTap:
            (onEvent != null &&
                run.events.contains('onTap') &&
                !_isInertNode(run))
            ? () => onEvent(run.id, 'onTap', run.itemCtx)
            : null,
      ),
    );
  }
  return SpanText(
    spans: parts,
    style: _textStyleOf(context, node.props),
    textAlign: _textAlign(node.props['align']),
    maxLines: (node.props['maxLines'] is num)
        ? (node.props['maxLines'] as num).toInt()
        : null,
  );
}

Widget _buildImage(BuildContext context, NodeModel node) {
  // `is String` rather than `as String?`: a prop can legitimately hold a
  // `{$bind}` MAP (an unresolved expression — the editor resolves those
  // before pushing, but a raw document reaches this renderer in tests and
  // through any path that skips resolveBridgeDocument). The cast threw
  // "_Map<String, dynamic> is not a subtype of String?", and because it
  // happens during build it took the WHOLE screen down rather than one
  // image — the exact failure registry.dart's placeholder exists to avoid.
  // Every other prop read in this file already uses this guard.
  final src = (node.props['src'] is String) ? node.props['src'] as String : '';
  final radius = (node.props['radius'] is num)
      ? (node.props['radius'] as num).toDouble()
      : 0.0;
  Widget img;
  // Unified image source (see the Image manifest's `src` prop). Resolution
  // order by prefix:
  //   bundled://<folder>/<file> — a template's shipped PNG (offline,
  //     Image.asset), e.g. bundled://ksa/app_logo.png or
  //     bundled://hbl/app_logo.png. The folder is each template's own
  //     assets/<folder>/ dir (registered in pubspec.yaml), carried in the
  //     ref itself rather than hardcoded here — was `assets/ksa/` unconditionally
  //     until a second template (hbl) needed its own folder. Replaces the
  //     former `asset` enum prop.
  //   asset://<file>   — a project-uploaded image bundled by codegen into
  //     assets/gen/ (design-assets pipeline — see rewriteDocAssetRefs). The
  //     canvas never sends this form; it resolves asset:<id> refs to served
  //     URLs and takes the Image.network path below.
  //   otherwise        — a raw URL (Image.network) or empty (placeholder).
  //
  // Orthogonal to all three: an `.svg` source of ANY of those shapes renders
  // through flutter_svg instead of dart:ui (svg_support.dart), with the same
  // BoxFit and the same placeholder tile, so swapping a PNG for an SVG moves
  // no layout. The tint is handed to SvgPicture's own colorFilter rather than
  // to the ColorFiltered wrap below — same ColorFilter, same srcIn blend, one
  // fewer saveLayer.
  final tintRaw = node.props['tint'];
  final ColorFilter? tintFilter = (tintRaw is String && tintRaw.isNotEmpty)
      ? ColorFilter.mode(
          parseHexColor(tintRaw, Colors.transparent),
          BlendMode.srcIn,
        )
      : null;
  if (isSvgSource(src)) {
    Widget svg = buildSvgSource(
      src,
      fit: _boxFit(node.props['fit']),
      colorFilter: tintFilter,
      onError: _imagePlaceholder,
    );
    if (radius > 0) {
      svg = ClipRRect(
        borderRadius: _cornerRadius(radius, node.props['radiusCorners']),
        child: svg,
      );
    }
    return svg;
  }
  if (src.startsWith('bundled://')) {
    img = Image.asset(
      'assets/${src.substring('bundled://'.length)}',
      fit: _boxFit(node.props['fit']),
      errorBuilder: (_, _, _) => _imagePlaceholder(context),
    );
  } else if (src.startsWith('asset://')) {
    img = Image.asset(
      'assets/gen/${src.substring('asset://'.length)}',
      fit: _boxFit(node.props['fit']),
      errorBuilder: (_, _, _) => _imagePlaceholder(context),
    );
  } else if (src.isEmpty) {
    img = _imagePlaceholder(context);
  } else {
    img = Image.network(
      src,
      fit: _boxFit(node.props['fit']),
      errorBuilder: (_, _, _) => _imagePlaceholder(context),
    );
  }
  if (tintFilter != null) {
    img = ColorFiltered(colorFilter: tintFilter, child: img);
  }
  if (radius > 0) {
    img = ClipRRect(
      borderRadius: _cornerRadius(radius, node.props['radiusCorners']),
      child: img,
    );
  }
  return img;
}

/// `radius` + `radiusCorners` → a BorderRadius, sharing Container's nine-option
/// vocabulary so an Image rounds the same way a Container does. An unknown or
/// absent value means all four corners, which is how `radius` behaved before
/// `radiusCorners` existed.
BorderRadius _cornerRadius(double radius, Object? corners) {
  final r = Radius.circular(radius);
  switch (corners is String ? corners : 'all') {
    case 'top':
      return BorderRadius.vertical(top: r);
    case 'bottom':
      return BorderRadius.vertical(bottom: r);
    case 'left':
      return BorderRadius.horizontal(left: r);
    case 'right':
      return BorderRadius.horizontal(right: r);
    case 'topLeft':
      return BorderRadius.only(topLeft: r);
    case 'topRight':
      return BorderRadius.only(topRight: r);
    case 'bottomLeft':
      return BorderRadius.only(bottomLeft: r);
    case 'bottomRight':
      return BorderRadius.only(bottomRight: r);
    default:
      return BorderRadius.circular(radius);
  }
}

Widget _imagePlaceholder(BuildContext context) {
  final theme = DesignTheme.of(context);
  return Container(
    color: theme.surface,
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, color: theme.textSecondary),
  );
}

Widget _buildIcon(BuildContext context, NodeModel node) {
  final theme = DesignTheme.of(context);
  final size = (node.props['size'] is num)
      ? (node.props['size'] as num).toDouble()
      : 24.0;
  final color = (node.props['color'] is String)
      ? parseHexColor(node.props['color'] as String, theme.primary)
      : theme.primary;
  return catalogIcon(node.props['icon'] as String?, size: size, color: color);
}

Widget _buildSpinner(BuildContext context, NodeModel node) {
  final theme = DesignTheme.of(context);
  final size = (node.props['size'] is num)
      ? (node.props['size'] as num).toDouble()
      : 32.0;
  final stroke = (node.props['strokeWidth'] is num)
      ? (node.props['strokeWidth'] as num).toDouble()
      : 3.0;
  final color = (node.props['color'] is String)
      ? parseHexColor(node.props['color'] as String, theme.primary)
      : theme.primary;
  return SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      strokeWidth: stroke,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ),
  );
}

/// A bound boolean toggle. Interactive only in the generated app (onInput +
/// bindValue supplied); on the design canvas it renders disabled.
Widget _buildSwitch(
  BuildContext context,
  NodeModel node,
  OnInput? onInput,
  OnEvent? onEvent,
) {
  final theme = DesignTheme.of(context);
  final on = node.props['value'] == true;
  final color = (node.props['color'] is String)
      ? parseHexColor(node.props['color'] as String, theme.primary)
      : theme.primary;
  final hasOnChange = onEvent != null && node.events.contains('onChange');
  final canToggle = onInput != null && node.bindValue != null;
  return Switch(
    value: on,
    activeThumbColor: color,
    // Two independent, optional write paths on the same gesture: onInput
    // always does the bindValue write (setVar); onEvent additionally runs
    // this node's own `events.onChange` steps (e.g. a callApi) — same
    // combining pattern _PressScale's onTap uses for events elsewhere, just
    // with a second callback instead of one. Order matters: the bound state
    // var must already hold the NEW value before onChange's steps run, since
    // those steps read it back via `state.<bindValue>`.
    onChanged: (canToggle || hasOnChange)
        ? (v) {
            if (canToggle) onInput(node.bindValue!, v);
            if (hasOnChange) onEvent(node.id, 'onChange', node.itemCtx);
          }
        : null,
  );
}

/// A bound boolean tick box WITH its own label — "I agree to the terms",
/// "Save this contact for future payments". Writes exactly like
/// [_buildSwitch]: the bound variable gets the new value first, then this
/// node's own `onChange` steps run (with the new value as `value` in their
/// item context, over any enclosing repeat item).
///
/// Mirrored line for line by the code generator's emitCheckbox — the
/// two renderers must build the same tree, so change them together.
///
/// Three choices that are easy to undo by accident:
///  * It is ALWAYS a Row, even with no label. A bare box handed a tight width
///    (a stretch Column) is forced to that width and paints centred; inside a
///    `min` Row it keeps its own size and sits at the start.
///  * The label is `Flexible` (loose) in a `min` Row, so it wraps in a bounded
///    width and is simply laid out at its natural width in an unbounded one
///    (a Row parent) — a loose flex child does not throw there.
///  * Fill, tick and outline are passed explicitly for every state, so the
///    canvas (no state to write to, so no callback) paints the SAME colours
///    as the running app instead of Material's grey disabled look. `disabled`
///    is shown by dimming the whole control instead.
Widget _buildCheckbox(
  BuildContext context,
  NodeModel node,
  OnInput? onInput,
  OnEvent? onEvent,
) {
  final theme = DesignTheme.of(context);
  final Map<String, dynamic> p = node.props;
  final bool checked = p['value'] == true;
  final bool disabled = p['disabled'] == true;
  final double size = (p['size'] is num)
      ? (p['size'] as num).toDouble().clamp(8.0, 64.0)
      : 20.0;
  final Color active = (p['activeColor'] is String)
      ? parseHexColor(p['activeColor'] as String, theme.primary)
      : theme.primary;
  final Color check = (p['checkColor'] is String)
      ? parseHexColor(p['checkColor'] as String, const Color(0xFFFFFFFF))
      : const Color(0xFFFFFFFF);
  final Color border = (p['borderColor'] is String)
      ? parseHexColor(p['borderColor'] as String, theme.textSecondary)
      : theme.textSecondary;
  final String label = (p['label'] is String) ? p['label'] as String : '';
  final bool labelFirst = p['labelPosition'] == 'start';

  final bool canToggle = onInput != null && node.bindValue != null;
  final bool hasOnChange = onEvent != null && node.events.contains('onChange');
  final bool enabled = !disabled && (canToggle || hasOnChange);
  void toggle() {
    final bool v = !checked;
    if (canToggle) onInput(node.bindValue!, v);
    if (hasOnChange)
      onEvent(node.id, 'onChange', <String, dynamic>{
        ...?node.itemCtx,
        'value': v,
      });
  }

  // Material draws an 18px box; scaling it keeps the stroke and corner in
  // proportion, and the SizedBox keeps the layout at exactly `size`.
  final Widget box = SizedBox(
    width: size,
    height: size,
    child: Transform.scale(
      scale: size / 18,
      child: Checkbox(
        value: checked,
        onChanged: enabled ? (_) => toggle() : null,
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? active : Colors.transparent,
        ),
        checkColor: check,
        side: BorderSide(color: border, width: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      ),
    ),
  );
  final List<Widget> text = label.isEmpty
      ? const <Widget>[]
      : <Widget>[
          Flexible(
            child: Text(
              label,
              style: _textStyleOf(context, <String, dynamic>{
                'size': p['labelSize'],
                'color': p['labelColor'],
              }),
            ),
          ),
        ];
  Widget w = Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: labelFirst
        ? MainAxisAlignment.spaceBetween
        : MainAxisAlignment.start,
    children: labelFirst
        ? <Widget>[...text, if (text.isNotEmpty) const SizedBox(width: 10), box]
        : <Widget>[
            box,
            if (text.isNotEmpty) const SizedBox(width: 10),
            ...text,
          ],
  );
  if (disabled) w = Opacity(opacity: 0.5, child: w);
  // The label is part of the tap target. The box's own Checkbox wins the
  // gesture arena for a tap ON the box, so one tap never toggles twice.
  if (enabled)
    w = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggle,
      child: w,
    );
  return MergeSemantics(child: w);
}

/// A bound NUMBER, dragged. The twin of [_buildSwitch] in every respect except
/// what it carries — same two write paths, same "disabled on the canvas".
///
/// Every bound is defended, because a Slider ASSERTS rather than degrades:
/// `min < max` when there are divisions, `divisions > 0`, and the value inside
/// the range. A document can hold any of those wrong (a max below a min, a
/// stale value from a previous limit) and the assert would take the whole
/// screen down, so each is clamped into something Flutter accepts.
Widget _buildSlider(
  BuildContext context,
  NodeModel node,
  OnInput? onInput,
  OnEvent? onEvent,
) {
  final theme = DesignTheme.of(context);
  final double min = (node.props['min'] is num)
      ? (node.props['min'] as num).toDouble()
      : 0.0;
  final double maxRaw = (node.props['max'] is num)
      ? (node.props['max'] as num).toDouble()
      : 100.0;
  // A degenerate or inverted range would assert; give it a real span instead.
  final double max = maxRaw > min ? maxRaw : min + 1;
  final double raw = (node.props['value'] is num)
      ? (node.props['value'] as num).toDouble()
      : min;
  final double value = raw.isFinite ? raw.clamp(min, max) : min;

  final double? step = (node.props['step'] is num)
      ? (node.props['step'] as num).toDouble()
      : null;
  int? divisions;
  if (step != null && step > 0) {
    final int d = ((max - min) / step).round();
    if (d > 0) divisions = d;
  }

  final Color color = (node.props['color'] is String)
      ? parseHexColor(node.props['color'] as String, theme.primary)
      : theme.primary;

  final bool hasOnChange = onEvent != null && node.events.contains('onChange');
  final bool canWrite = onInput != null && node.bindValue != null;

  return Slider(
    value: value,
    min: min,
    max: max,
    divisions: divisions,
    activeColor: color,
    // Only with divisions does Flutter show it, which is also the only time it
    // reads as a step rather than a jitter of decimals.
    label: node.props['showValue'] == true ? value.round().toString() : null,
    // Same combining pattern as _buildSwitch: the bound variable holds the NEW
    // value before this node's own onChange steps run, so those steps can read
    // it back. Fires per drag frame — a step that calls an API belongs on a
    // button, not here.
    onChanged: (canWrite || hasOnChange)
        ? (double v) {
            final num out = divisions != null ? v.round() : v;
            if (canWrite) onInput(node.bindValue!, out);
            if (hasOnChange) onEvent(node.id, 'onChange', node.itemCtx);
          }
        : null,
  );
}

// ── prop → Flutter enum mappers ─────────────────────────────────────────────
MainAxisAlignment _mainAxis(dynamic v) {
  switch (v) {
    case 'center':
      return MainAxisAlignment.center;
    case 'end':
      return MainAxisAlignment.end;
    case 'spaceBetween':
      return MainAxisAlignment.spaceBetween;
    case 'spaceAround':
      return MainAxisAlignment.spaceAround;
    case 'spaceEvenly':
      return MainAxisAlignment.spaceEvenly;
    default:
      return MainAxisAlignment.start;
  }
}

CrossAxisAlignment _crossAxis(dynamic v) {
  switch (v) {
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'center':
      return CrossAxisAlignment.center;
    case 'end':
      return CrossAxisAlignment.end;
    default:
      return CrossAxisAlignment.start;
  }
}

TextAlign _textAlign(dynamic v) {
  switch (v) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'justify':
      return TextAlign.justify;
    default:
      return TextAlign.left;
  }
}

FontWeight _fontWeight(dynamic v) {
  if (v is num) {
    const map = {
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w400,
      500: FontWeight.w500,
      600: FontWeight.w600,
      700: FontWeight.w700,
      800: FontWeight.w800,
      900: FontWeight.w900,
    };
    return map[v.toInt()] ?? FontWeight.w400;
  }
  // The full w100..w900 range. This used to stop at w700 with everything else
  // falling through to `default` — so a node authored 'w800' painted at w400,
  // i.e. LIGHTER than a w700 heading rather than heavier. It was silent (no
  // gate checks prop VALUES) and it affected 109 nodes across the shipped
  // templates. Numeric weights were always handled correctly just above; only
  // the string names were short.
  switch (v) {
    case 'black':
    case 'w900':
      return FontWeight.w900;
    case 'extrabold':
    case 'w800':
      return FontWeight.w800;
    case 'bold':
    case 'w700':
      return FontWeight.w700;
    case 'semibold':
    case 'w600':
      return FontWeight.w600;
    case 'medium':
    case 'w500':
      return FontWeight.w500;
    case 'regular':
    case 'normal':
    case 'w400':
      return FontWeight.w400;
    case 'light':
    case 'w300':
      return FontWeight.w300;
    case 'extralight':
    case 'w200':
      return FontWeight.w200;
    case 'thin':
    case 'w100':
      return FontWeight.w100;
    default:
      return FontWeight.w400;
  }
}

BoxFit _boxFit(dynamic v) {
  switch (v) {
    case 'contain':
      return BoxFit.contain;
    case 'fill':
      return BoxFit.fill;
    case 'fitWidth':
      return BoxFit.fitWidth;
    case 'fitHeight':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    default:
      return BoxFit.cover;
  }
}

/// A node's onTap wrap (see buildNode): a small press-scale so tapping a
/// button/row gives tactile feedback instead of a flat, instant GestureDetector.
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScale({required this.child, required this.onTap});
  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _s = 1;
  // MouseRegion sits OUTSIDE the GestureDetector: it only advertises the
  // pointer cursor to the framework and never intercepts hit-testing, so it
  // composes with the tap-down/up scale animation below with zero behavior
  // change for touch devices (mouse-only concept, ignored on touch).
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _s = 0.97),
      onTapUp: (_) => setState(() => _s = 1),
      onTapCancel: () => setState(() => _s = 1),
      // Twin of PRESS_SCALE_DART in the code generator: a tap on any node
      // dismisses the keyboard before the event runs, so Test Mode behaves
      // like the shipped app rather than leaving the keyboard over the
      // result. A node holding a text field never carries onTap.
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _s,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    ),
  );
}
