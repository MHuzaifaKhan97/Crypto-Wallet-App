import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Studio X — Design Mode: SVG rendering for the Image primitive.
//
// The Image primitive's `src` used to mean "raster": every branch of
// node_view.dart's _buildImage built a `dart:ui` Image widget, so a vector
// source rendered as a broken tile. Figma line icons imported through
// `import_figma_assets` came back as 4x PNGs for exactly that reason — heavy,
// and blurred at any size the design didn't ask for. An `.svg` source now
// builds an SvgPicture instead.
//
// This file is copied verbatim into every generated app, which is why it
// imports `flutter/widgets.dart` rather than material and knows nothing about
// DesignTheme: the caller passes its own placeholder/error tile in, so the
// canvas and a generated app show the same fallback the raster branch shows.

/// Whether an Image `src` names an SVG.
///
/// Extension on the PATH only. Every source shape the Image primitive accepts
/// carries the real filename:
///   · `bundled://hbl/mark.svg`  — a template's shipped vector
///   · `asset://mark.svg`        — a project upload, bundled by codegen
///   · `https://host/project-assets/<id>/mark.svg?v=1234`
///                               — what the canvas resolves an `asset:<id>`
///                                 ref to (see apps/web/src/lib/design-assets.ts;
///                                 the `?v=` cache-buster is why the query has
///                                 to come off before the extension test)
///
/// Deliberately NOT a content sniff: the decision has to be made while BUILDING
/// the widget, before any bytes exist, and a wrong guess is a whole frame of a
/// broken image. A `.svg` served with the wrong content type still renders,
/// because flutter_svg parses bytes rather than trusting the header.
bool isSvgSource(String src) {
  if (src.isEmpty) return false;
  var path = src;
  final q = path.indexOf('?');
  if (q >= 0) path = path.substring(0, q);
  final h = path.indexOf('#');
  if (h >= 0) path = path.substring(0, h);
  return path.toLowerCase().endsWith('.svg');
}

/// The flutter_svg loader for one source, using the SAME prefix vocabulary
/// node_view.dart's _buildImage uses for raster (`bundled://` and `asset://`
/// are bundled assets; anything else is a URL). Kept in one place so the
/// warm-up below and the widget cannot disagree about a cache key.
BytesLoader svgLoaderFor(String src) {
  if (src.startsWith('bundled://')) {
    return SvgAssetLoader('assets/${src.substring('bundled://'.length)}');
  }
  if (src.startsWith('asset://')) {
    return SvgAssetLoader('assets/gen/${src.substring('asset://'.length)}');
  }
  return SvgNetworkLoader(src);
}

/// An SVG rendered with the raster branch's geometry contract: the same
/// [BoxFit], and no intrinsic width/height of its own — the node's own box
/// layout supplies those, exactly as it does for an Image, so swapping a PNG
/// source for an SVG one moves nothing.
///
/// [onError] is the caller's fallback tile, wired to `errorBuilder` ONLY —
/// deliberately not to `placeholderBuilder`. Image.network shows nothing while
/// it loads and the fallback tile only when it fails; an SVG that flashed a
/// grey tile on every load would be a visible difference between the two
/// source kinds, which is the one thing this branch must not introduce.
///
/// A load FAILURE (a dangling ref, an offline url, malformed bytes) shows
/// [onError]'s tile and, unavoidably, logs one unhandled async error:
/// flutter_svg's own cache derives a future from the load with `.then(...)`
/// and attaches no error handler to it (Cache.putIfAbsent in cache.dart), so
/// the failure escapes to the zone no matter what THIS file does with its own
/// copy of the future. In production that is console noise — main.dart hooks
/// `FlutterError.onError` but installs no zone handler, so the editor is never
/// told. In `flutter test` it is fatal to the test, which is why the fallback
/// test asserts through the errorBuilder rather than by failing a real load.
/// The same cache also keeps the failed future forever, so a source that fails
/// once keeps its placeholder for the life of the session.
///
/// [colorFilter] is how `Image.tint` reaches an SVG. The raster branch wraps
/// its Image in `ColorFiltered(ColorFilter.mode(c, BlendMode.srcIn))`; passing
/// the identical filter here paints it inside the vector graphic instead —
/// same blend, same result, one fewer saveLayer.
Widget buildSvgSource(
  String src, {
  BoxFit fit = BoxFit.cover,
  ColorFilter? colorFilter,
  required WidgetBuilder onError,
}) {
  return SvgPicture(
    svgLoaderFor(src),
    fit: fit,
    colorFilter: colorFilter,
    errorBuilder: (context, _, _) => onError(context),
  );
}

// ── Static-capture warm-up ──────────────────────────────────────────────────
// An SvgPicture ALWAYS resolves asynchronously: SvgLoader.loadBytes fetches (or
// reads from the bundle) and then compiles the SVG, and even a fully cached
// result reaches the widget through an `await`. The storyboard/screen_preview
// capture path in host.dart renders a screen offscreen and rasterizes it after
// two frames — nowhere near enough for a network fetch — so without this every
// SVG in a preview would be a blank where an icon belongs.
//
// The fix is to load the bytes BEFORE the capture rather than to wait longer:
// flutter_svg's own `svg.cache` is keyed on the loader instance, so once these
// futures complete, the SvgPicture that mounts in the capture stage gets a
// SynchronousFuture from the cache and paints within the frames the capture
// already waits.

/// Load (and cache) every SVG in [srcs] so a subsequent capture paints them.
///
/// Never throws and never outlives [timeout]: a broken or slow source must
/// cost one screen its icon, not stall the whole snapshot queue — the same
/// reasoning as _captureCurrent's catch-and-continue.
Future<void> warmSvgSources(
  Iterable<String> srcs, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final List<Future<void>> loads = <Future<void>>[];
  for (final src in srcs) {
    if (!isSvgSource(src)) continue;
    // Null context on purpose: it makes getTheme() return `const SvgTheme()`
    // and _resolveBundle() return rootBundle, which is exactly what the widget
    // resolves to in a tree with no DefaultSvgTheme — i.e. the same cache key.
    loads.add(
      svgLoaderFor(src).loadBytes(null).then<void>((_) {}, onError: (_, _) {}),
    );
  }
  if (loads.isEmpty) return;
  try {
    await Future.wait(loads).timeout(timeout);
  } catch (_) {
    // Timed out or a loader threw synchronously — capture anyway.
  }
}

/// Every SVG-looking string anywhere in a screen's raw JSON.
///
/// A blunt walk of every string value rather than a per-prop allow-list, for
/// the same reason rewriteDocAssetRefs walks the whole document: `src` is not
/// the only prop that takes an image ref (DebitCreditCard's background,
/// OffersBanner's items, a nav tab's icon), and a warm-up that missed one would
/// fail in exactly the silent way this exists to prevent. Loading a string that
/// merely ends in ".svg" but is not a real source costs one failed fetch that
/// is swallowed above.
Set<String> collectSvgSources(Object? json) {
  final out = <String>{};
  void walk(Object? v) {
    if (v is String) {
      if (isSvgSource(v)) out.add(v);
    } else if (v is List) {
      for (final e in v) {
        walk(e);
      }
    } else if (v is Map) {
      for (final e in v.values) {
        walk(e);
      }
    }
  }

  walk(json);
  return out;
}
