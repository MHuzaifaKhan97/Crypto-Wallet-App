// Studio X Design Mode — shared motion primitives.
//
// This file is the SINGLE source for both surfaces: the canvas host renders it
// directly, and design-codegen copies it verbatim into every generated
// project. It used to be a hardcoded string in the codegen service, which is
// why the canvas had no animation at all — only generated apps ever saw it.
//
// Pure SDK: no animation package. Adding one would put a dependency in every
// generated project's pubspec for what AnimationController already does.
import 'package:flutter/material.dart';

/// Marks a subtree as being rendered for a STATIC capture (the storyboard's
/// offscreen thumbnail pass). Every entrance effect below jumps straight to its
/// settled state instead of playing.
///
/// Without this, a thumbnail is captured while `NodeEntrance` is still at
/// opacity 0 — and since node entrances can also carry a stagger `delay`, a
/// screen can be entirely invisible for hundreds of milliseconds after mount.
/// The result is a blank card. Waiting "long enough" is not a fix: the delay is
/// author-controlled and unbounded.
class StaticCapture extends InheritedWidget {
  const StaticCapture({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StaticCapture>() != null;

  @override
  bool updateShouldNotify(StaticCapture oldWidget) => false;
}

/// Plays a one-shot fade + slide-up when the screen first mounts.
class ScreenEntrance extends StatefulWidget {
  final Widget child;

  /// Jump straight to the settled state instead of playing the entrance.
  /// Used by the storyboard's offscreen thumbnail pass: capturing a frame
  /// mid-animation yields a faint, vertically-shifted image.
  final bool instant;
  const ScreenEntrance({super.key, required this.child, this.instant = false});
  @override
  State<ScreenEntrance> createState() => _ScreenEntranceState();
}

class _ScreenEntranceState extends State<ScreenEntrance>
    with SingleTickerProviderStateMixin {
  // Created lazily, and ONLY when this actually animates. It must not be a
  // `late final` initialiser: when the entrance is skipped, nothing ever reads
  // it, and `dispose()` would then RUN the initialiser — building an
  // AnimationController against an already-deactivated element, which throws
  // "Looking up a deactivated widget's ancestor is unsafe".
  AnimationController? _c;
  Animation<double>? _fade;
  Animation<Offset>? _slide;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StaticCapture is inherited, so this cannot be decided in initState.
    if (widget.instant || StaticCapture.of(context) || _c != null) return;
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _c = c;
    _fade = CurvedAnimation(parent: c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    c.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = _fade;
    final slide = _slide;
    if (fade == null || slide == null) return widget.child;
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: widget.child),
    );
  }
}

/// Repeating gradient sweep used to build skeleton loading placeholders.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  // Lazy for the same reason as the entrance controllers: a `late final` that
  // build() never reads gets initialised by dispose(), on a dead element.
  AnimationController? _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || StaticCapture.of(context)) return;
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    // A repeating sweep has no settled state to wait for.
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = c.value * 2 - 1;
            return LinearGradient(
              colors: const [
                Color(0xFFE9EDF3),
                Color(0xFFF6F8FB),
                Color(0xFFE9EDF3),
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(-1 + dx, 0),
              end: Alignment(1 + dx, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single rounded placeholder block used inside [LoadingSkeleton].
class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const ShimmerBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 8,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A dashboard-shaped skeleton shown while a bound-data screen loads.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerBox(height: 120, radius: 16),
            const SizedBox(height: 16),
            Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 3 ? 0 : 12),
                    child: const ShimmerBox(height: 56, radius: 12),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const ShimmerBox(height: 64, radius: 12),
            const SizedBox(height: 12),
            const ShimmerBox(height: 64, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Entrance effect kinds a node can declare via `animate.type`.
enum NodeEffect { fade, slideUp, slideDown, slideLeft, slideRight, scale }

const Map<String, NodeEffect> kNodeEffects = <String, NodeEffect>{
  'fade': NodeEffect.fade,
  'slideUp': NodeEffect.slideUp,
  'slideDown': NodeEffect.slideDown,
  'slideLeft': NodeEffect.slideLeft,
  'slideRight': NodeEffect.slideRight,
  'scale': NodeEffect.scale,
};

const Map<String, Curve> kNodeCurves = <String, Curve>{
  'linear': Curves.linear,
  'easeIn': Curves.easeIn,
  'easeOut': Curves.easeOut,
  'easeInOut': Curves.easeInOut,
  'easeOutCubic': Curves.easeOutCubic,
  'easeOutBack': Curves.easeOutBack,
};

/// Plays a one-shot entrance effect when a node first mounts.
///
/// Every effect fades in as well as its own transform — a slide or scale that
/// does not also fade reads as a glitch rather than an entrance.
///
/// The animation is started once from didChangeDependencies (not initState —
/// it must read the inherited StaticCapture) and never restarted by a rebuild,
/// so editing a property on the canvas does not re-fire it. That only holds while
/// the element keeps its State, which is why buildNode gives every node a
/// KeyedSubtree keyed on its stable node id.
class NodeEntrance extends StatefulWidget {
  final Widget child;
  final NodeEffect effect;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  /// Where the fade SETTLES, 0..1 — the node's own static
  /// `Node.opacity`, 1.0 when it declares none.
  ///
  /// It is a property of the entrance rather than an Opacity around it for two
  /// reasons. A node at 0.55 must animate 0 → 0.55: end at 1 and it flashes to
  /// full opacity before settling, which reads as a broken fade and is
  /// invisible in every static check. And FadeTransition already owns the one
  /// compositing layer this needs; an Opacity wrapped around or inside would
  /// reach the same value by multiplication and pay a second saveLayer on
  /// every frame.
  final double opacity;

  const NodeEntrance({
    super.key,
    required this.child,
    this.effect = NodeEffect.fade,
    this.duration = const Duration(milliseconds: 320),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.opacity = 1.0,
  });

  @override
  State<NodeEntrance> createState() => _NodeEntranceState();
}

class _NodeEntranceState extends State<NodeEntrance>
    with SingleTickerProviderStateMixin {
  // Lazily created, and only when this node actually animates — see the note
  // on _ScreenEntranceState._c for why a `late final` here is a dispose-time
  // crash rather than a style choice.
  AnimationController? _c;
  Animation<double>? _t;

  // Started here rather than in initState because whether to animate at all
  // depends on an inherited widget (StaticCapture), and inherited widgets
  // cannot be read from initState. Under a static capture the animation never
  // starts — so no pending stagger timer is left behind either.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || StaticCapture.of(context)) return;
    final c = AnimationController(vsync: this, duration: widget.duration);
    _c = c;
    _t = CurvedAnimation(parent: c, curve: widget.curve);
    if (widget.delay == Duration.zero) {
      c.forward();
    } else {
      // `mounted` guard: a staggered list item can be disposed before its delay
      // elapses (scrolled away, or the screen popped), and forwarding a disposed
      // controller throws.
      Future<void>.delayed(widget.delay, () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  /// Slide distance as a fraction of the child's own size, so the travel scales
  /// with the widget instead of being a fixed pixel offset.
  Offset get _begin {
    switch (widget.effect) {
      case NodeEffect.slideUp:
        return const Offset(0, 0.12);
      case NodeEffect.slideDown:
        return const Offset(0, -0.12);
      case NodeEffect.slideLeft:
        return const Offset(0.12, 0);
      case NodeEffect.slideRight:
        return const Offset(-0.12, 0);
      case NodeEffect.fade:
      case NodeEffect.scale:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    if (t == null) {
      // Static capture: the SETTLED state, which for a translucent node is its
      // own opacity — not the bare child. A thumbnail that showed the chip at
      // full opacity would disagree with the screen it is a picture of.
      return widget.opacity >= 1.0
          ? widget.child
          : Opacity(opacity: widget.opacity, child: widget.child);
    }
    Widget w = widget.child;
    if (widget.effect == NodeEffect.scale) {
      w = ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(t),
        child: w,
      );
    } else if (_begin != Offset.zero) {
      w = SlideTransition(
        position: Tween<Offset>(begin: _begin, end: Offset.zero).animate(t),
        child: w,
      );
    }
    // 0 → the node's own opacity, in the ONE layer FadeTransition already
    // builds. `t` alone would end at 1 and make a translucent node flash.
    return FadeTransition(
      opacity: widget.opacity >= 1.0
          ? t
          : t.drive(Tween<double>(begin: 0.0, end: widget.opacity)),
      child: w,
    );
  }
}
