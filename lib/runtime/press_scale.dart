// The tactile press feedback every tappable node gets (twin of the canvas
// renderer's press wrap): scales to 0.97 while pressed, 90ms ease-out.
import 'package:flutter/material.dart';

class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const PressScale({super.key, required this.child, required this.onTap});
  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  double _scale = 1;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: () {
        // Every tappable node in the app goes through here, so this is the one
        // place a tap can dismiss the keyboard for all of them. A button that
        // stays on the screen (a Continue that validates, a chip that filters)
        // otherwise left the keyboard covering the result — and an app-level
        // tap handler cannot fix it, because the button wins the gesture arena
        // and the app-level detector never fires.
        //
        // A node holding a text field never carries onTap (the emitter allows
        // only onChange there), so this cannot steal focus from a field the
        // user is trying to reach.
        FocusManager.instance.primaryFocus?.unfocus();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    ),
  );
}
