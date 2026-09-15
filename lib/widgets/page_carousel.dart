import 'dart:async';

import 'package:flutter/material.dart';
import '../runtime/models.dart';

/// A swipeable page carousel with an optional auto-slide timer and a tappable
/// dot indicator — the widget behind the `PageView` node primitive.
///
/// This is the PUBLIC twin the readable code export emits directly:
///
/// ```dart
/// PageCarousel(
///   pages: [SlideOne(), SlideTwo()],
///   autoSlide: true,
///   interval: const Duration(seconds: 3),
///   explicitHeight: 420,
/// )
/// ```
///
/// The node-tree interpreter (node_view.dart's `_buildPageView`) constructs the
/// same widget from a node's props, so the canvas, Test Mode and the exported
/// app all run this one implementation.
///
/// Behaviour: swipe is native; dots are tappable (jump to page); the auto-slide
/// timer is cancelled in dispose and paused while the user is dragging (resumed
/// — with a fresh full interval — once the drag settles). An externally driven
/// page ([initialPage] changing, e.g. from bound state) animates to the new
/// index via didUpdateWidget, so a binding is genuinely two-way.
///
/// [dotColor] / [activeDotColor] default to the ambient [DesignTheme]
/// (`textSecondary` at 35% / `primary`). [explicitHeight] wins over the bound
/// height a parent gives; with NO bound at all the carousel falls back to 320
/// rather than throwing the unbounded-height layout error.
class PageCarousel extends StatefulWidget {
  /// One widget per page. Swiping moves between them; the dot indicator shows
  /// one dot per entry.
  final List<Widget> pages;

  /// Advance to the next page every [interval] without user input.
  final bool autoSlide;

  /// Auto-slide cadence (only read when [autoSlide] is true).
  final Duration interval;

  /// Wrap around to the first page after the last one (auto-slide only —
  /// swiping never wraps).
  final bool loop;

  /// Paint the dot indicator.
  final bool showDots;

  /// Inactive dot color; null → `DesignTheme.textSecondary` at 35% opacity.
  final Color? dotColor;

  /// Active dot (pill) color; null → `DesignTheme.primary`.
  final Color? activeDotColor;

  /// Diameter of an inactive dot, and the height of every dot.
  final double dotSize;

  /// Width of the ACTIVE dot — wider than [dotSize] makes it a pill.
  final double activeDotWidth;

  /// Where the dot row sits on the cross axis: 'start', 'center' (the
  /// default and the historical behaviour) or 'end'. A design that runs its
  /// pager copy flush-left wants the dots under the copy's own left edge, not
  /// centred under the pager — and centred was the only option, which pushed
  /// templates into hand-drawing dots that cannot track the page.
  final String dotsAlign;

  /// Paint the dots ON the pages (bottom-centered) instead of below them.
  final bool overlayDots;

  /// Fixed height for the whole carousel; null → fill the bound the parent
  /// gives, or 320 when there is none.
  final double? explicitHeight;

  /// Page shown first (and, when it changes, the page to animate to).
  final int initialPage;

  /// Fires with the new index after every page change (swipe, dot tap or
  /// auto-slide).
  final ValueChanged<int>? onPageChanged;

  const PageCarousel({
    super.key,
    required this.pages,
    this.autoSlide = false,
    this.interval = const Duration(seconds: 3),
    this.loop = true,
    this.showDots = true,
    this.dotColor,
    this.activeDotColor,
    this.dotSize = 8,
    this.activeDotWidth = 20,
    this.dotsAlign = 'center',
    this.overlayDots = false,
    this.explicitHeight,
    this.initialPage = 0,
    this.onPageChanged,
  });

  @override
  State<PageCarousel> createState() => _PageCarouselState();
}

/// Clamps a (possibly non-numeric, possibly out-of-range) bound value to a
/// valid page index for a carousel of [pageCount] pages — anything that isn't a
/// number, and anything outside 0..pageCount-1, means "first page".
///
/// Shared by the interpreter (node_view's `_buildPageView`) and readable
/// generated screens, so a bound page index resolves identically in both.
int carouselPageIndex(dynamic value, int pageCount) {
  final i = (value is num) ? value.toInt() : 0;
  return (i < 0 || i >= pageCount) ? 0 : i;
}

class _PageCarouselState extends State<PageCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;
  bool _dragging = false;
  static const _kSlide = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _index = widget.initialPage;
    _controller = PageController(initialPage: _index);
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant PageCarousel old) {
    super.didUpdateWidget(old);
    // Bound state moved the page from outside (a setState / workflow step):
    // follow it. Our own onPageChanged write-back comes back as the same
    // index, so this is a no-op in the common case.
    if (widget.initialPage != old.initialPage &&
        widget.initialPage != _index &&
        widget.initialPage < widget.pages.length) {
      _animateTo(widget.initialPage);
    }
    if (widget.autoSlide != old.autoSlide ||
        widget.interval != old.interval ||
        widget.pages.length != old.pages.length) {
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoSlide || widget.pages.length < 2 || _dragging) return;
    _timer = Timer.periodic(widget.interval, (_) => _advance());
  }

  void _advance() {
    if (!mounted || _dragging) return;
    final n = widget.pages.length;
    if (n < 2) return;
    var next = _index + 1;
    if (next >= n) {
      if (!widget.loop) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      next = 0;
    }
    _animateTo(next);
  }

  void _animateTo(int page) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(page, duration: _kSlide, curve: Curves.easeInOut);
  }

  void _onPageChanged(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    // Keep the cadence honest after a swipe/tap: a full interval from NOW.
    _restartTimer();
    widget.onPageChanged?.call(i);
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _dragging = true;
      _timer?.cancel();
      _timer = null;
    } else if (n is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartTimer();
    }
    return false;
  }

  Alignment get _dotsAlignment {
    switch (widget.dotsAlign) {
      case 'start':
        return Alignment.centerLeft;
      case 'end':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  Widget _dots() {
    final theme = DesignTheme.of(context);
    final dotColor =
        widget.dotColor ?? theme.textSecondary.withValues(alpha: 0.35);
    final activeDotColor = widget.activeDotColor ?? theme.primary;
    final n = widget.pages.length;
    return Row(
      // `min` + an outer Align, rather than stretching this Row: the dots keep
      // their intrinsic width and the alignment is applied around them.
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < n; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _animateTo(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: i == _index ? widget.activeDotWidth : widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: i == _index ? activeDotColor : dotColor,
                  borderRadius: BorderRadius.circular(widget.dotSize / 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pager = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: PageView(
        controller: _controller,
        onPageChanged: _onPageChanged,
        children: widget.pages,
      ),
    );
    final n = widget.pages.length;
    final showDots = widget.showDots && n > 0;
    Widget body;
    if (!showDots) {
      body = pager;
    } else if (widget.overlayDots) {
      body = Stack(
        children: [
          Positioned.fill(child: pager),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Align(alignment: _dotsAlignment, child: _dots()),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: pager),
          const SizedBox(height: 12),
          Align(alignment: _dotsAlignment, child: _dots()),
        ],
      );
    }
    // Bounded height, always: an explicit `height` prop wins; otherwise fill
    // whatever bound the parent/self-layout gives; with NO bound (a hug
    // Column, a scrollable) fall back to 320 rather than throwing the
    // "unbounded height" layout error that takes the whole screen down.
    if (widget.explicitHeight != null)
      return SizedBox(height: widget.explicitHeight, child: body);
    return LayoutBuilder(
      builder: (context, c) =>
          c.hasBoundedHeight ? body : SizedBox(height: 320, child: body),
    );
  }
}
