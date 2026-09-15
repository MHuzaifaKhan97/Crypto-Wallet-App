import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// One run of a [SpanText]: styled text that may be tappable, or an inline
/// widget (an Icon or Image child) sitting on the text line.
class SpanTextPart {
  final String text;
  final TextStyle? style;

  /// Makes this run tappable — the "Terms & Conditions" inside a sentence.
  final VoidCallback? onTap;

  /// When set, this run is this widget instead of text.
  final Widget? widget;

  const SpanTextPart({this.text = '', this.style, this.onTap, this.widget});
}

/// The `RichText` node: one paragraph built from several differently styled
/// runs, any of which can be tapped. Flutter's own `RichText` / `Text.rich`
/// with a TextSpan per run, so the sentence wraps as one paragraph (a Row of
/// Texts cannot wrap across runs) and a tappable run is hit-tested on its own
/// glyphs, not on a box around it.
///
/// ONE source for both surfaces: node_view.dart builds it from the node tree
/// (canvas, Test Mode, interpreter-mode apps) and the readable export
/// constructs it directly — catalog/ is copied into every generated project.
///
/// Stateful only to own the TapGestureRecognizers a tappable TextSpan needs:
/// a recognizer must be disposed, and a StatelessWidget has nowhere to do it.
/// They are kept across rebuilds and re-pointed at the current callbacks, so
/// the editor's rebuild-per-keystroke does not churn them.
class SpanText extends StatefulWidget {
  final List<SpanTextPart> spans;

  /// The paragraph's base style — what an inline widget sits against, and the
  /// fallback for anything a run does not set.
  final TextStyle? style;
  final TextAlign? textAlign;

  /// 0 / null = as many lines as the text needs; otherwise ellipsized.
  final int? maxLines;

  const SpanText({
    super.key,
    required this.spans,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  @override
  State<SpanText> createState() => _SpanTextState();
}

class _SpanTextState extends State<SpanText> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int used = 0;
    final children = <InlineSpan>[
      for (final part in widget.spans)
        if (part.widget != null)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: part.widget!,
          )
        else
          TextSpan(
            text: part.text,
            style: part.style,
            recognizer: part.onTap == null
                ? null
                : _recognizerAt(used++, part.onTap!),
            mouseCursor: part.onTap == null ? null : SystemMouseCursors.click,
          ),
    ];
    while (_recognizers.length > used) {
      _recognizers.removeLast().dispose();
    }
    final maxLines = (widget.maxLines ?? 0) > 0 ? widget.maxLines : null;
    return Text.rich(
      TextSpan(style: widget.style, children: children),
      textAlign: widget.textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }

  TapGestureRecognizer _recognizerAt(int i, VoidCallback onTap) {
    if (i == _recognizers.length) _recognizers.add(TapGestureRecognizer());
    return _recognizers[i]..onTap = onTap;
  }
}
