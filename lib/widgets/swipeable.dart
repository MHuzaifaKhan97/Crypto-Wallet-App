import 'package:flutter/material.dart';
import '../runtime/models.dart';
import 'icons.dart';

/// Manifest: Swipeable.
///
/// Wraps ONE child row and reveals a destructive action behind it when the
/// row is dragged sideways. Templates have been telling people to "swipe to
/// delete any beneficiary" while nothing in the catalog could swipe at all.
///
/// Why reveal-then-tap rather than Flutter's [Dismissible]:
///   * Dismissible commits on the swipe itself. On a payee list that means a
///     mis-swipe deletes a saved beneficiary, and the only recovery is an
///     undo affordance nothing here has. Requiring the button tap makes the
///     destructive step deliberate.
///   * Dismissible removes its child from the tree on dismiss, which fights
///     a document whose list is rebuilt from state: the row would vanish
///     locally, then reappear on the next rebuild until the delete call came
///     back. Here the row NEVER removes itself — it fires `onAction` and the
///     document decides (call the API, then re-read the list). One owner of
///     the truth.
///
/// `dismissOnFullSwipe` opts into the faster gesture for non-destructive
/// actions (archive, mark read): dragging past 55% of the width fires
/// `onAction` directly. The row still does not remove itself.
///
/// Fires `onAction` via the standard node event channel, carrying the node's
/// repeat item context — so inside a `repeat` the step scope has the swiped
/// item's own fields, exactly like a row onTap.
class Swipeable extends StatefulWidget {
  final Widget child;
  final String actionLabel;
  final String actionIcon;
  final String? actionColor;
  final String? actionTextColor;
  final double actionWidth;

  /// 'endToStart' (drag right-to-left, the common case) or 'startToEnd'.
  final String direction;
  final double? radius;
  final bool dismissOnFullSwipe;

  /// Called when the revealed button is tapped (or on a full swipe when
  /// [dismissOnFullSwipe] is on).
  final VoidCallback? onAction;

  /// Typed props rather than a NodeModel: the readable emitter builds this
  /// widget with real constructor arguments, and the interpreter passes the
  /// node's own props through. One widget, two callers, no node literal.
  const Swipeable({
    super.key,
    required this.child,
    this.actionLabel = 'Delete',
    this.actionIcon = 'delete',
    this.actionColor,
    this.actionTextColor,
    this.actionWidth = 96,
    this.direction = 'endToStart',
    this.radius,
    this.dismissOnFullSwipe = false,
    this.onAction,
  });

  @override
  State<Swipeable> createState() => _SwipeableState();
}

class _SwipeableState extends State<Swipeable>
    with SingleTickerProviderStateMixin {
  /// Created lazily, on the first swipe — see motion.dart for the same trap.
  /// It must NOT be a `late final` initialiser: a row that is never swiped
  /// never reads it, and `dispose()` would then RUN the initialiser, building
  /// an AnimationController against an already-deactivated element, which
  /// throws "Looking up a deactivated widget's ancestor is unsafe" on every
  /// teardown of a screen holding one.
  AnimationController? _c;

  /// How far the row is currently pulled aside, in logical pixels. Always >= 0;
  /// the direction is applied at paint time.
  double _offset = 0;
  double _dragStart = 0;

  double get _actionWidth => widget.actionWidth.clamp(48.0, 200.0);

  bool get _fromEnd => widget.direction != 'startToEnd';

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    final c = _c ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    final from = _offset;
    final anim = Tween<double>(
      begin: from,
      end: target,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    void tick() => setState(() => _offset = anim.value);
    c
      ..stop()
      ..reset()
      ..addListener(tick);
    c.forward().whenComplete(() => c.removeListener(tick));
  }

  void _fire() {
    _animateTo(0);
    widget.onAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DesignTheme.of(context);
    final actionColor = parseHexColor(
      widget.actionColor,
      const Color(0xFFDC2626),
    );
    final actionTextColor = parseHexColor(
      widget.actionTextColor,
      const Color(0xFFFFFFFF),
    );
    final label = widget.actionLabel;
    final iconName = widget.actionIcon;
    final radius = widget.radius ?? theme.radius;
    final dismissOnFull = widget.dismissOnFullSwipe;

    final action = Align(
      alignment: _fromEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: _fire,
        child: Container(
          width: _actionWidth,
          decoration: BoxDecoration(
            color: actionColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              catalogIcon(iconName, size: 18, color: actionTextColor),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: actionTextColor,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Only horizontal drag callbacks: a tap (or a vertical scroll) is not
    // claimed here, so the wrapped row keeps its own onTap and the list still
    // scrolls normally.
    return Stack(
      children: [
        Positioned.fill(child: action),
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onHorizontalDragStart: (d) => _dragStart = d.localPosition.dx,
          onHorizontalDragUpdate: (d) {
            final raw = _fromEnd
                ? _dragStart - d.localPosition.dx
                : d.localPosition.dx - _dragStart;
            setState(() => _offset = raw.clamp(0.0, _actionWidth * 1.6));
          },
          onHorizontalDragEnd: (_) {
            final width = context.size?.width ?? 0;
            if (dismissOnFull && width > 0 && _offset > width * 0.55) {
              _fire();
            } else {
              // Past halfway the row stays open; short of it, it springs back.
              _animateTo(_offset > _actionWidth / 2 ? _actionWidth : 0);
            }
          },
          child: Transform.translate(
            offset: Offset(_fromEnd ? -_offset : _offset, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
