// Studio X — Design Mode v2 (Pillar 3): the compiled-expression runtime.
//
// Per decision D3, bindable expressions ({$bind}, visibleIf, repeat.over,
// setState/condition/callApi values) are COMPILED to Dart at codegen — there is
// no interpreter. The compiled Dart calls these small helpers, which walk the
// runtime scope map (`_ctx` = {state, route, item, query}) null-safely. This
// file is copied VERBATIM into a generated project's lib/runtime/ (like node.dart
// / node_view.dart), so the compiled expressions have their runtime.
//
// Mirrors the editor-side TS evaluator so preview and shipped behaviour agree.
// Kept dependency-free.

library;

import 'dart:convert';
import 'dart:math';

/// Resolves [path] (e.g. ['state','user','name']) against the scope map [ctx],
/// null-safely across Maps and Lists (a numeric segment indexes a List). Returns
/// null for any missing/mistyped segment — never throws. Mirror of the path case
/// in evalExpr.
dynamic exprGet(Map<String, dynamic> ctx, List<String> path) =>
    exprPath(ctx, path);

/// Walks [path] from an arbitrary [root] (Map or List), null-safely — used to
/// extract a field out of a raw API response (callApi `assignPath`), e.g.
/// exprPath(res.data, ['data','token']).
dynamic exprPath(dynamic root, List<String> path) {
  dynamic cur = root;
  for (final key in path) {
    if (cur is Map) {
      cur = cur[key];
    } else if (cur is List) {
      final i = int.tryParse(key);
      if (i == null || i < 0 || i >= cur.length) return null;
      cur = cur[i];
    } else {
      return null;
    }
  }
  return cur;
}

/// Dart-side truthiness, matching evalExpr's `truthy`: only false / null / 0 /
/// '' are falsy (empty lists and maps are truthy, as in the TS evaluator).
bool exprTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Length of a String or collection; 0 otherwise (mirror of the `len` fn).
int exprLen(dynamic v) {
  if (v is String) return v.length;
  if (v is List) return v.length;
  if (v is Map) return v.length;
  if (v is Iterable) return v.length;
  return 0;
}

/// Element at [i] of [list], or null if out of range / not a List. Used by the
/// `repeat` codegen to read the item for each iteration.
dynamic exprElemAt(dynamic list, int i) {
  if (list is List && i >= 0 && i < list.length) return list[i];
  return null;
}

/// The value [v] as a list you can `for`-loop over — the one helper a repeat
/// (`for (final row in exprList(state.rows))`) and a `forEach` action step
/// need, so neither has to guard the source itself.
///
/// A state variable that hasn't loaded yet, a JSON field that came back a
/// scalar, a null: all yield an EMPTY run rather than throwing. That is the
/// same degradation [exprMap]/[exprFilter] already apply, and it is what makes
/// the emitted `for` element safe to write unguarded.
///
/// A non-List Iterable is materialised rather than rejected: the `forEach`
/// step has always accepted one (`if (_list is Iterable)`), and rejecting it
/// here would have narrowed that.
List<dynamic> exprList(dynamic v) {
  if (v is List) return v;
  if (v is Iterable) return v.toList();
  return const <dynamic>[];
}

// ── Array/object support: exprIndex / exprMap / exprFilter ──────────────────
// These back the `a[i]`, `[…]`, `{…}`, map() and filter() forms of the
// grammar — the reason a request body can now carry a list whose LENGTH
// depends on state, instead of the caller pre-generating one fixed-shape
// endpoint per possible length.

/// `a[i]` on a List (numeric or numeric-string index) and `a[k]` / `a.k` on a
/// Map. Out of range, mistyped or missing yields null rather than throwing —
/// the same null-safe walk [exprPath] already does for dotted access.
dynamic exprIndex(dynamic target, dynamic key) {
  if (target is List) {
    final i = key is num
        ? key.toInt()
        : int.tryParse(key?.toString().trim() ?? '');
    if (i == null || i < 0 || i >= target.length) return null;
    return target[i];
  }
  if (target is Map) {
    if (target.containsKey(key)) return target[key];
    final k = key is String ? key : key?.toString();
    return target.containsKey(k) ? target[k] : null;
  }
  return null;
}

/// Builds the child scope one map()/filter() iteration sees: a copy of [ctx]
/// with [name] bound to [value], so the lambda body's `exprGet` finds its item
/// without mutating (or outliving) the parent scope. Same discipline as
/// [exprWithItem], which does this for `repeat`.
Map<String, dynamic> _exprChildCtx(
  Map<String, dynamic> ctx,
  String name,
  dynamic value,
) {
  final Map<String, dynamic> child = Map<String, dynamic>.of(ctx);
  child[name] = value;
  return child;
}

/// `map(list, x => body)` — [build] applied to every element of [list], each
/// with its own child scope. A non-Iterable [list] (null, a failed lookup, a
/// scalar) yields an empty list rather than throwing, so a body built from a
/// state variable that hasn't loaded yet degrades to `[]`.
List<dynamic> exprMap(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) build,
) {
  if (list is! Iterable) return <dynamic>[];
  final out = <dynamic>[];
  for (final e in list) {
    out.add(build(_exprChildCtx(ctx, name, e)));
  }
  return out;
}

/// `filter(list, x => test)` — the elements of [list] whose [test] is truthy
/// (by [exprTruthy], so '' / 0 / null / false drop out). Same non-Iterable
/// degradation as [exprMap].
List<dynamic> exprFilter(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) test,
) {
  if (list is! Iterable) return <dynamic>[];
  final out = <dynamic>[];
  for (final e in list) {
    if (exprTruthy(test(_exprChildCtx(ctx, name, e)))) out.add(e);
  }
  return out;
}

/// Builds a child scope by copying [parent] and setting [name] = [value], then
/// invokes [build] with it and returns the result. Used by `repeat` so each
/// iteration's subtree sees its own `item` (or aliased name) in scope, without
/// mutating the parent scope.
T exprWithItem<T>(
  Map<String, dynamic> parent,
  String name,
  dynamic value,
  T Function(Map<String, dynamic>) build,
) {
  final Map<String, dynamic> ctx = Map<String, dynamic>.of(parent);
  ctx[name] = value;
  return build(ctx);
}

// ── money() / date() / mask() / initials() ──────────────────────────────────
// Determinism rules, chosen deliberately over "nicer" but
// ambiguous/locale-dependent behaviour:
//  - money: ASCII digits, '.' decimal separator, ',' thousands separator,
//    always 2dp, half-up rounding applied to the non-negative magnitude
//    (this sidesteps JS Math.round vs. Dart double.round disagreeing on the
//    halfway case for NEGATIVE numbers — round the magnitude, apply sign
//    after, and both languages agree).
//  - date: always UTC. An ISO-8601 string with no 'Z'/offset is treated as
//    ALREADY being UTC (never the host's local timezone) — otherwise preview
//    (Node, dev machine tz) and shipped app (device tz) would disagree. Month
//    names are fixed English abbreviations, never locale-formatted.
//  - mask / initials: ASCII-oriented whitespace splitting, no locale casing.
// Dependency-free (no intl) — this file ships verbatim into generated apps.

/// The first run of digits (with an optional decimal part) in a piece of text.
/// The sign is NOT part of the match: a '-' is often separated from its digits
/// by the currency decoration ('-£42.50', 'GBP -42.5'), so it's recovered from
/// whatever precedes the match instead — see [_exprReadNumber].
final RegExp _exprNumericToken = RegExp(r'\d+(?:\.\d+)?');

/// Parses one already-cleaned numeric token, keeping it an `int` when it has
/// no '.' — see [exprNum]'s note on why int-vs-double is user-visible.
num? _exprParseNumToken(String s) {
  if (!s.contains('.')) {
    final i = int.tryParse(s);
    if (i != null) return i;
  }
  final d = double.tryParse(s);
  return (d != null && d.isFinite) ? d : null;
}

/// THE numeric coercion — every helper that does maths or formats a number
/// reads its input through here. Numbers pass through. Strings are trimmed and
/// stripped of ',' thousands separators; if the WHOLE remainder is a number
/// that wins (so every value that already worked keeps its exact result), and
/// otherwise we fall back to the first number appearing in the text.
///
/// That fallback is the point: real values arrive pre-formatted — an API field
/// or a bound label reading 'GBP 7,845.1', '$1,200', '15.3%'. Those used to
/// collapse to 0, silently, which looked like the binding was empty rather
/// than unparsed. Null when there is no number at all.
num? _exprReadNumber(dynamic v) {
  if (v is num) return v.isFinite ? v : null;
  if (v is! String) return null; // null, bool, and anything else
  final cleaned = v.trim().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  final whole = _exprParseNumToken(cleaned);
  if (whole != null) return whole;
  final m = _exprNumericToken.firstMatch(cleaned);
  if (m == null) return null;
  final n = _exprParseNumToken(m.group(0)!);
  if (n == null) return null;
  // Anything before the first digit run is decoration ('-£', 'GBP -'); a '-'
  // in there is this number's sign. Losing it would turn an overdrawn balance
  // into a positive one, so it is recovered rather than dropped.
  return cleaned.substring(0, m.start).contains('-') ? -n : n;
}

double? _exprToNumberOrNull(dynamic v) => _exprReadNumber(v)?.toDouble();

String _exprGroupThousands(String digits) {
  var out = '';
  var count = 0;
  for (var i = digits.length - 1; i >= 0; i--) {
    out = digits[i] + out;
    count++;
    if (count % 3 == 0 && i != 0) out = ',$out';
  }
  return out;
}

/// Formats [v] as a thousands-grouped, 2-decimal string, optionally prefixed
/// with [ccy] (e.g. "PKR 125,000.00"). Non-numeric/null → "0.00" (or "PKR
/// 0.00").
String exprMoney(dynamic v, [dynamic ccy]) {
  final n0 = _exprToNumberOrNull(v);
  final n = n0 ?? 0.0;
  final negative = n < 0;
  final mag = n.abs();
  final cents = (mag * 100).round();
  final intPart = cents ~/ 100;
  final decPart = cents % 100;
  final numStr =
      '${_exprGroupThousands(intPart.toString())}.${decPart.toString().padLeft(2, '0')}';
  final sign = negative ? '-' : '';
  final ccyStr = (ccy is String && ccy.isNotEmpty) ? '$ccy ' : '';
  return '$ccyStr$sign$numStr';
}

const List<String> _exprMonthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _exprMonthFull = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _exprWeekdayFull = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

const List<String> _exprWeekdayAbbr = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

final RegExp _exprIsoRe = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?\s*(Z|[+-]\d{2}:?\d{2})?$',
);

bool _exprIsLeapYear(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

int _exprDaysInMonth(int y, int m) {
  if (m == 2) return _exprIsLeapYear(y) ? 29 : 28;
  return (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31;
}

bool _exprValidYmdHms(int y, int mo, int d, int h, int mi, int s) =>
    mo >= 1 &&
    mo <= 12 &&
    d >= 1 &&
    d <= _exprDaysInMonth(y, mo) &&
    h <= 23 &&
    mi <= 59 &&
    s <= 59;

/// Parses "anything date-shaped" to UTC epoch ms, or null. Accepts numbers
/// (epoch ms), ISO-8601, 'yyyy/MM/dd' / 'yyyy.MM.dd', and compact digit
/// strings (8 = yyyyMMdd, 12 = yyyyMMddHHmm, 14 = yyyyMMddHHmmss, 13 = epoch
/// millis). A timestamp with no 'Z'/offset is treated as ALREADY being UTC.
int? _exprParseDateMs(dynamic v) {
  if (v is num) return v.isFinite ? v.round() : null;
  if (v is! String) return null;
  var s = v.trim();
  if (s.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(s)) {
    if (s.length == 13) return int.tryParse(s);
    if (s.length == 8 || s.length == 12 || s.length == 14) {
      final y = int.parse(s.substring(0, 4));
      final mo = int.parse(s.substring(4, 6));
      final d = int.parse(s.substring(6, 8));
      final h = s.length >= 12 ? int.parse(s.substring(8, 10)) : 0;
      final mi = s.length >= 12 ? int.parse(s.substring(10, 12)) : 0;
      final sec = s.length == 14 ? int.parse(s.substring(12, 14)) : 0;
      if (!_exprValidYmdHms(y, mo, d, h, mi, sec)) return null;
      return DateTime.utc(y, mo, d, h, mi, sec).millisecondsSinceEpoch;
    }
    return null;
  }
  // yyyy/MM/dd and yyyy.MM.dd normalise to ISO's separators, then fall through.
  if (RegExp(r'^\d{4}[/.]\d{2}[/.]\d{2}').hasMatch(s)) {
    s =
        s.substring(0, 10).replaceAll('/', '-').replaceAll('.', '-') +
        s.substring(10);
  }
  final m = _exprIsoRe.firstMatch(s);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final month = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  final hour = m.group(4) != null ? int.parse(m.group(4)!) : 0;
  final minute = m.group(5) != null ? int.parse(m.group(5)!) : 0;
  final second = m.group(6) != null ? int.parse(m.group(6)!) : 0;
  if (!_exprValidYmdHms(year, month, day, hour, minute, second)) return null;
  var offsetMin = 0;
  final tz = m.group(7);
  if (tz != null && tz != 'Z') {
    final sign = tz.startsWith('-') ? -1 : 1;
    final clean = tz.substring(1).replaceAll(':', '');
    final oh = int.parse(clean.substring(0, 2));
    final om = clean.length > 2 ? int.parse(clean.substring(2, 4)) : 0;
    offsetMin = sign * (oh * 60 + om);
  }
  final utc = DateTime.utc(year, month, day, hour, minute, second);
  return utc.millisecondsSinceEpoch - offsetMin * 60000;
}

String _exprPad2(int n) => n < 10 ? '0$n' : '$n';

/// 0 = Sunday … 6 = Saturday, from UTC epoch ms (1970-01-01 was a Thursday).
int _exprWeekdayIndex(int ms) {
  final days = (ms / 86400000).floor();
  return ((days + 4) % 7 + 7) % 7;
}

String _exprIsoDate(int y, int mo, int d) =>
    '${y.toString().padLeft(4, '0')}-${_exprPad2(mo)}-${_exprPad2(d)}';

String _exprIsoDateTime(DateTime d) =>
    '${_exprIsoDate(d.year, d.month, d.day)}T${_exprPad2(d.hour)}:${_exprPad2(d.minute)}:${_exprPad2(d.second)}';

DateTime _exprUtc(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

/// Formats [ms] per [fmt]. Tokens: yyyy yy MMMM MMM MM M dd d EEEE EEE HH hh h
/// mm ss a; anything else passes through literally. Always UTC fields.
String _exprFormatDateMs(int ms, String fmt) {
  final d = _exprUtc(ms);
  final wd = _exprWeekdayIndex(ms);
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final out = StringBuffer();
  var i = 0;
  final f = fmt;
  while (i < f.length) {
    if (f.startsWith('yyyy', i)) {
      out.write(d.year.toString().padLeft(4, '0'));
      i += 4;
      continue;
    }
    if (f.startsWith('MMMM', i)) {
      out.write(_exprMonthFull[d.month - 1]);
      i += 4;
      continue;
    }
    if (f.startsWith('MMM', i)) {
      out.write(_exprMonthAbbr[d.month - 1]);
      i += 3;
      continue;
    }
    if (f.startsWith('MM', i)) {
      out.write(_exprPad2(d.month));
      i += 2;
      continue;
    }
    if (f.startsWith('EEEE', i)) {
      out.write(_exprWeekdayFull[wd]);
      i += 4;
      continue;
    }
    if (f.startsWith('EEE', i)) {
      out.write(_exprWeekdayAbbr[wd]);
      i += 3;
      continue;
    }
    if (f.startsWith('dd', i)) {
      out.write(_exprPad2(d.day));
      i += 2;
      continue;
    }
    if (f.startsWith('yy', i)) {
      out.write(_exprPad2(d.year % 100));
      i += 2;
      continue;
    }
    if (f.startsWith('HH', i)) {
      out.write(_exprPad2(d.hour));
      i += 2;
      continue;
    }
    if (f.startsWith('hh', i)) {
      out.write(_exprPad2(h12));
      i += 2;
      continue;
    }
    if (f.startsWith('mm', i)) {
      out.write(_exprPad2(d.minute));
      i += 2;
      continue;
    }
    if (f.startsWith('ss', i)) {
      out.write(_exprPad2(d.second));
      i += 2;
      continue;
    }
    if (f[i] == 'M') {
      out.write(d.month.toString());
      i += 1;
      continue;
    }
    if (f[i] == 'd') {
      out.write(d.day.toString());
      i += 1;
      continue;
    }
    if (f[i] == 'h') {
      out.write(h12.toString());
      i += 1;
      continue;
    }
    if (f[i] == 'a') {
      out.write(d.hour < 12 ? 'AM' : 'PM');
      i += 1;
      continue;
    }
    out.write(f[i]);
    i += 1;
  }
  return out.toString();
}

/// Formats [v] per [fmt] (default 'd MMM yyyy'). Accepts everything
/// [_exprParseDateMs] accepts — including compact strings like '20310731', so
/// `date('20310731', 'yyyy/MM/dd')` → '2031/07/31'. Unparseable input → ''.
String exprDate([dynamic v, dynamic fmt]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return '';
  final f = (fmt is String && fmt.isNotEmpty) ? fmt : 'd MMM yyyy';
  return _exprFormatDateMs(ms, f);
}

/// Masks all but the last [n] characters (default 4) of [v] with '•••• '.
/// Strings shorter than [n] are returned unchanged.
String exprMask([dynamic v, dynamic n]) {
  final s = v == null ? '' : v.toString();
  final kn = _exprToNumberOrNull(n);
  final k = (kn != null && kn > 0) ? kn.truncate() : 4;
  if (s.length < k) return s;
  return '•••• ${s.substring(s.length - k)}';
}

/// The counterpart of [exprMask]: shows the FIRST [n] characters (default 4)
/// and hides the rest — 'SA44 ••••'. Strings shorter than [n] are returned
/// unchanged.
String exprMaskEnd([dynamic v, dynamic n]) {
  final s = v == null ? '' : v.toString();
  final kn = _exprToNumberOrNull(n);
  final k = (kn != null && kn > 0) ? kn.truncate() : 4;
  if (s.length < k) return s;
  return '${s.substring(0, k)} ••••';
}

/// Strips everything but ASCII digits from [v]. A PhoneInput's bound value is
/// intl_phone_field's completeNumber ("+966123456789"); many APIs want bare
/// digits, no leading '+'. Surrounding whitespace stripped. Note the explicit
/// null branch: `null.toString()` in Dart is the four-character string 'null',
/// so trimming via toString() alone would make a not-yet-loaded field look
/// populated to a `len(trim(v)) > 0` guard.
String exprTrim(dynamic v) {
  return v == null ? '' : v.toString().trim();
}

String exprDigits(dynamic v) {
  final s = v == null ? '' : v.toString();
  return s.replaceAll(RegExp(r'[^0-9]'), '');
}

/// First letters of the first two whitespace-separated words of [v],
/// uppercased (single word → just its first letter; empty/null → '').
String exprInitials(dynamic v) {
  final s = v == null ? '' : v.toString().trim();
  if (s.isEmpty) return '';
  final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
}

/// Coerces [v] to a number for arithmetic (e.g. `state.balance - num(state.amount)`
/// when a numeric keypad writes strings through a two-way binding but the
/// bound state is a `num`). Reads its input via [_exprReadNumber], so a
/// pre-formatted value like 'GBP 7,845.1' yields 7845.1 rather than 0.
/// Empty/null/bool/no-number-at-all → `0` (int).
///
/// The int-vs-double choice is user-visible — `125000 - num('500')` must
/// render as "124500", not "124500.0" — so this is intentional, not
/// incidental: "no decimal point in the input" is treated as "this is a whole
/// number, keep it a whole number" rather than always widening to double.
num exprNum(dynamic v) => _exprReadNumber(v) ?? 0;

/// Case-insensitive "does it contain" test. An empty/null needle matches
/// everything, so an empty search box filters nothing out; a null haystack
/// matches nothing. A List haystack tests whether any ITEM equals the needle
/// (case-insensitively).
bool exprContains([dynamic haystack, dynamic needle]) {
  final String n = _exprToStr(needle).toLowerCase();
  if (n.isEmpty) return true;
  if (haystack is List)
    return haystack.any((el) => _exprToStr(el).toLowerCase() == n);
  return _exprToStr(haystack).toLowerCase().contains(n);
}

/// Returns an INT so string interpolation yields "5025", not "5025.0".
/// Non-finite input (num('') on an empty field) yields 0 rather than
/// throwing.
int exprRound(dynamic v) {
  final n = exprNum(v);
  return n.isFinite ? n.round() : 0;
}

/// Returns the LOCAL date as 'yyyy-MM-dd', the same shape DatePicker stores,
/// so `digits(today())` gives yyyyMMdd and composes with the date strings
/// these backends exchange. Local rather than UTC: a bill is overdue relative
/// to where the user is.
String exprToday() {
  final n = DateTime.now();
  String p(int v, [int w = 2]) => v.toString().padLeft(w, '0');
  return '${p(n.year, 4)}-${p(n.month)}-${p(n.day)}';
}

/// Returns a random integer from 0 to (limit - 1).
int exprRandom(dynamic limit) {
  final n = exprNum(limit);
  final maxVal = (n.isFinite && n > 0) ? n.toInt() : 100;
  return Random().nextInt(maxVal);
}

// ═════════════════════════════════════════════════════════════════════════════
// The extended function library. Every helper below is the Dart twin of the
// same-named `impl` in the code generator (mirrored api/web). All args are
// optional positionals so a half-written expression (`upper()`) still
// compiles rather than taking the build down. Null discipline throughout:
// null → '' (never the string 'null'), so `len(f(v)) > 0` stays a sound "is
// this populated?" guard.
// ═════════════════════════════════════════════════════════════════════════════

String _exprToStr(dynamic v) => v == null ? '' : v.toString();

/// Fixed-point formatting, half-up rounding on the magnitude (JS and Dart
/// agree there for non-negatives; sign applied after). A value rounding to
/// exactly 0 prints without a '-'.
String _exprFmtFixed(dynamic v, dynamic dp, bool group) {
  final n = _exprToNumberOrNull(v) ?? 0.0;
  final dpn = _exprToNumberOrNull(dp);
  final d = dpn == null ? 0 : max(0, min(10, dpn.truncate()));
  final neg = n < 0;
  final mag = n.abs();
  final shift = pow(10, d).toInt();
  final units = (mag * shift).round();
  final intPart = units ~/ shift;
  final decPart = units % shift;
  final intStr = group
      ? _exprGroupThousands(intPart.toString())
      : intPart.toString();
  final decStr = d > 0 ? '.${decPart.toString().padLeft(d, '0')}' : '';
  return '${neg && units > 0 ? '-' : ''}$intStr$decStr';
}

String _exprStripTrailingZeros(String s) {
  if (!s.contains('.')) return s;
  var out = s;
  while (out.endsWith('0')) {
    out = out.substring(0, out.length - 1);
  }
  if (out.endsWith('.')) out = out.substring(0, out.length - 1);
  return out;
}

/// Whole-valued doubles become ints so `${sqrt(144)}` prints "12", not "12.0"
/// — matching JS, where 12 and 12.0 are the same number.
num _exprIntIfWhole(double d) =>
    (d.isFinite && d == d.truncateToDouble() && d.abs() < 9e15) ? d.toInt() : d;

// ─── Text ────────────────────────────────────────────────────────────────────

String exprUpper([dynamic v]) => _exprToStr(v).toUpperCase();

String exprLower([dynamic v]) => _exprToStr(v).toLowerCase();

String exprCapitalize([dynamic v]) {
  final s = _exprToStr(v);
  return s.isEmpty ? '' : s.substring(0, 1).toUpperCase() + s.substring(1);
}

String exprTitleCase([dynamic v]) => _exprToStr(v)
    .trim()
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w.substring(0, 1).toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

bool exprStartsWith([dynamic v, dynamic p]) =>
    _exprToStr(v).startsWith(_exprToStr(p));

bool exprEndsWith([dynamic v, dynamic s]) =>
    _exprToStr(v).endsWith(_exprToStr(s));

/// Replaces every occurrence of plain text (not a regex).
String exprReplace([dynamic v, dynamic f, dynamic r]) {
  final find = _exprToStr(f);
  if (find.isEmpty) return _exprToStr(v);
  return _exprToStr(v).replaceAll(find, _exprToStr(r));
}

List<dynamic> exprSplit([dynamic v, dynamic sep]) {
  final s = _exprToStr(v);
  if (s.isEmpty) return <dynamic>[];
  return List<dynamic>.of(s.split(_exprToStr(sep)));
}

String exprSubstring([dynamic v, dynamic st, dynamic en]) {
  final s = _exprToStr(v);
  final a = max(0, min(s.length, exprNum(st).truncate()));
  final b = en == null
      ? s.length
      : max(a, min(s.length, exprNum(en).truncate()));
  return s.substring(a, b);
}

String exprLeft([dynamic v, dynamic n]) {
  final s = _exprToStr(v);
  final k = max(0, exprNum(n).truncate());
  return s.substring(0, min(k, s.length));
}

String exprRight([dynamic v, dynamic n]) {
  final s = _exprToStr(v);
  final k = max(0, exprNum(n).truncate());
  return k == 0 ? '' : s.substring(max(0, s.length - k));
}

String exprPadLeft([dynamic v, dynamic w, dynamic c]) {
  final ch = _exprToStr(c).isEmpty ? '0' : _exprToStr(c)[0];
  return _exprToStr(v).padLeft(max(0, exprNum(w).truncate()), ch);
}

String exprPadRight([dynamic v, dynamic w, dynamic c]) {
  final ch = _exprToStr(c).isEmpty ? ' ' : _exprToStr(c)[0];
  return _exprToStr(v).padRight(max(0, exprNum(w).truncate()), ch);
}

String exprRepeat([dynamic v, dynamic n]) {
  final k = max(0, min(1000, exprNum(n).truncate()));
  return _exprToStr(v) * k;
}

/// Reverses text — or a list.
dynamic exprReverse([dynamic v]) {
  if (v is List) return v.reversed.toList();
  return _exprToStr(v).split('').reversed.join();
}

int exprIndexOf([dynamic v, dynamic q]) => _exprToStr(v).indexOf(_exprToStr(q));

String exprCharAt([dynamic v, dynamic i]) {
  final s = _exprToStr(v);
  final k = exprNum(i).truncate();
  return (k >= 0 && k < s.length) ? s[k] : '';
}

String exprSlugify([dynamic v]) => _exprToStr(v)
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String exprTruncate([dynamic v, dynamic n]) {
  final s = _exprToStr(v);
  final k = max(0, exprNum(n).truncate());
  return s.length <= k ? s : '${s.substring(0, k)}…';
}

String exprRemoveSpaces([dynamic v]) =>
    _exprToStr(v).replaceAll(RegExp(r'\s+'), '');

String exprNormalizeSpace([dynamic v]) =>
    _exprToStr(v).trim().replaceAll(RegExp(r'\s+'), ' ');

int exprWordCount([dynamic v]) {
  final s = _exprToStr(v).trim();
  return s.isEmpty ? 0 : s.split(RegExp(r'\s+')).length;
}

String exprLetters([dynamic v]) =>
    _exprToStr(v).replaceAll(RegExp(r'[^A-Za-z]'), '');

String exprAlphanumeric([dynamic v]) =>
    _exprToStr(v).replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

// ─── Numbers ─────────────────────────────────────────────────────────────────

num exprRoundTo([dynamic v, dynamic dp]) {
  final n0 = _exprToNumberOrNull(v);
  final n = n0 ?? 0.0;
  final dpn = _exprToNumberOrNull(dp);
  final d = dpn == null ? 0 : max(0, min(10, dpn.truncate()));
  final shift = pow(10, d).toInt();
  final units = (n.abs() * shift).round();
  if (d == 0) return n < 0 ? -units : units;
  final r = units / shift;
  return _exprIntIfWhole(n < 0 ? -r : r);
}

int exprFloor([dynamic v]) {
  final n = _exprToNumberOrNull(v);
  return n == null ? 0 : n.floor();
}

int exprCeil([dynamic v]) {
  final n = _exprToNumberOrNull(v);
  return n == null ? 0 : n.ceil();
}

num exprAbs([dynamic v]) {
  final n = _exprToNumberOrNull(v);
  return n == null ? 0 : _exprIntIfWhole(n.abs());
}

num exprMin([dynamic a, dynamic b]) => min(exprNum(a), exprNum(b));

num exprMax([dynamic a, dynamic b]) => max(exprNum(a), exprNum(b));

num exprClamp([dynamic v, dynamic lo, dynamic hi]) =>
    min(max(exprNum(v), exprNum(lo)), exprNum(hi));

num exprPow([dynamic a, dynamic b]) {
  final r = pow(exprNum(a), exprNum(b));
  if (r is double && !r.isFinite) return 0;
  return r is double ? _exprIntIfWhole(r) : r;
}

num exprSqrt([dynamic v]) {
  final n = exprNum(v);
  return n <= 0 ? 0 : _exprIntIfWhole(sqrt(n.toDouble()));
}

int exprSign([dynamic v]) {
  final n = exprNum(v);
  return n > 0 ? 1 : (n < 0 ? -1 : 0);
}

String exprToFixed([dynamic v, dynamic dp]) => _exprFmtFixed(v, dp, false);

String exprPercent([dynamic v, dynamic dp]) =>
    '${_exprFmtFixed(exprNum(v) * 100, dp ?? 0, false)}%';

String exprFormatNumber([dynamic v, dynamic dp]) =>
    _exprFmtFixed(v, dp ?? 0, true);

String exprCompact([dynamic v, dynamic dp]) {
  final n = exprNum(v);
  final d = dp ?? 1;
  final mag = n.abs();
  if (mag >= 1e9)
    return '${_exprStripTrailingZeros(_exprFmtFixed(n / 1e9, d, false))}B';
  if (mag >= 1e6)
    return '${_exprStripTrailingZeros(_exprFmtFixed(n / 1e6, d, false))}M';
  if (mag >= 1e3)
    return '${_exprStripTrailingZeros(_exprFmtFixed(n / 1e3, d, false))}K';
  return _exprStripTrailingZeros(_exprFmtFixed(n, d, false));
}

String exprOrdinal([dynamic v]) {
  final n = exprNum(v).truncate();
  final abs = n.abs();
  final mod100 = abs % 100;
  final mod10 = abs % 10;
  final suffix = (mod100 >= 11 && mod100 <= 13)
      ? 'th'
      : mod10 == 1
      ? 'st'
      : mod10 == 2
      ? 'nd'
      : mod10 == 3
      ? 'rd'
      : 'th';
  return '$n$suffix';
}

bool exprIsEven([dynamic v]) => exprNum(v).truncate() % 2 == 0;

bool exprIsOdd([dynamic v]) => exprNum(v).truncate() % 2 != 0;

int exprRandomBetween([dynamic a, dynamic b]) {
  final x = exprNum(a).truncate();
  final y = exprNum(b).truncate();
  final lo = min(x, y);
  final hi = max(x, y);
  return lo + Random().nextInt(hi - lo + 1);
}

// ─── Dates & time ────────────────────────────────────────────────────────────

/// Reads a date WRITTEN in [fmt] (tokens yyyy MM dd HH mm ss; every other
/// character must match literally) and returns ISO — 'yyyy-MM-dd', or
/// 'yyyy-MM-ddTHH:mm:ss' when a time token appeared. Unparseable → ''.
String exprParseDate([dynamic v, dynamic fmt]) {
  final s = _exprToStr(v);
  final f = _exprToStr(fmt);
  if (s.isEmpty || f.isEmpty) return '';
  var si = 0;
  var fi = 0;
  var y = 0;
  var mo = 1;
  var d = 1;
  var h = 0;
  var mi = 0;
  var sec = 0;
  var hasTime = false;
  int? readDigits(int n) {
    if (si + n > s.length) return null;
    final part = s.substring(si, si + n);
    if (!RegExp(r'^\d+$').hasMatch(part)) return null;
    si += n;
    return int.parse(part);
  }

  while (fi < f.length) {
    if (f.startsWith('yyyy', fi)) {
      final r = readDigits(4);
      if (r == null) return '';
      y = r;
      fi += 4;
      continue;
    }
    if (f.startsWith('MM', fi)) {
      final r = readDigits(2);
      if (r == null) return '';
      mo = r;
      fi += 2;
      continue;
    }
    if (f.startsWith('dd', fi)) {
      final r = readDigits(2);
      if (r == null) return '';
      d = r;
      fi += 2;
      continue;
    }
    if (f.startsWith('HH', fi)) {
      final r = readDigits(2);
      if (r == null) return '';
      h = r;
      hasTime = true;
      fi += 2;
      continue;
    }
    if (f.startsWith('mm', fi)) {
      final r = readDigits(2);
      if (r == null) return '';
      mi = r;
      hasTime = true;
      fi += 2;
      continue;
    }
    if (f.startsWith('ss', fi)) {
      final r = readDigits(2);
      if (r == null) return '';
      sec = r;
      hasTime = true;
      fi += 2;
      continue;
    }
    if (si >= s.length || s[si] != f[fi]) return '';
    si++;
    fi++;
  }
  if (si != s.length) return '';
  if (y == 0 || !_exprValidYmdHms(y, mo, d, h, mi, sec)) return '';
  if (hasTime) return _exprIsoDateTime(DateTime.utc(y, mo, d, h, mi, sec));
  return _exprIsoDate(y, mo, d);
}

/// The device's current date and time, 'yyyy-MM-ddTHH:mm:ss' (local, like
/// exprToday — see its note on why local).
String exprNow() => _exprIsoDateTime(DateTime.now());

int exprTimestamp([dynamic v]) {
  if (v == null || v == '') return DateTime.now().millisecondsSinceEpoch;
  final ms = _exprParseDateMs(v);
  return ms ?? 0;
}

int exprYear([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? 0 : _exprUtc(ms).year;
}

int exprMonth([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? 0 : _exprUtc(ms).month;
}

int exprDay([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? 0 : _exprUtc(ms).day;
}

int exprHour([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? 0 : _exprUtc(ms).hour;
}

int exprMinute([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? 0 : _exprUtc(ms).minute;
}

String exprWeekday([dynamic v]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? '' : _exprWeekdayFull[_exprWeekdayIndex(ms)];
}

String exprAddDays([dynamic v, dynamic n]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return '';
  final d = _exprUtc(ms + exprNum(n).truncate() * 86400000);
  return _exprIsoDate(d.year, d.month, d.day);
}

/// Month arithmetic with end-of-month clamping (31 Jan + 1 month = 28/29 Feb,
/// never 2/3 Mar).
String _exprAddMonthsClamped(int ms, int n) {
  final d = _exprUtc(ms);
  final total = d.year * 12 + (d.month - 1) + n;
  final y = (total / 12).floor();
  final mo = ((total % 12) + 12) % 12 + 1;
  final dd = min(d.day, _exprDaysInMonth(y, mo));
  return _exprIsoDate(y, mo, dd);
}

String exprAddMonths([dynamic v, dynamic n]) {
  final ms = _exprParseDateMs(v);
  return ms == null ? '' : _exprAddMonthsClamped(ms, exprNum(n).truncate());
}

String exprAddYears([dynamic v, dynamic n]) {
  final ms = _exprParseDateMs(v);
  return ms == null
      ? ''
      : _exprAddMonthsClamped(ms, exprNum(n).truncate() * 12);
}

String exprAddHours([dynamic v, dynamic n]) {
  final ms = _exprParseDateMs(v);
  return ms == null
      ? ''
      : _exprIsoDateTime(_exprUtc(ms + exprNum(n).truncate() * 3600000));
}

String exprAddMinutes([dynamic v, dynamic n]) {
  final ms = _exprParseDateMs(v);
  return ms == null
      ? ''
      : _exprIsoDateTime(_exprUtc(ms + exprNum(n).truncate() * 60000));
}

int exprDiffDays([dynamic a, dynamic b]) {
  final x = _exprParseDateMs(a);
  final y = _exprParseDateMs(b);
  return (x == null || y == null) ? 0 : ((x - y) / 86400000).truncate();
}

int exprDiffHours([dynamic a, dynamic b]) {
  final x = _exprParseDateMs(a);
  final y = _exprParseDateMs(b);
  return (x == null || y == null) ? 0 : ((x - y) / 3600000).truncate();
}

int exprDiffMinutes([dynamic a, dynamic b]) {
  final x = _exprParseDateMs(a);
  final y = _exprParseDateMs(b);
  return (x == null || y == null) ? 0 : ((x - y) / 60000).truncate();
}

String exprTimeAgo([dynamic v]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return '';
  final diff = DateTime.now().millisecondsSinceEpoch - ms;
  final past = diff >= 0;
  final abs = diff.abs();
  String unit(int n, String name) {
    final phrase = '$n $name${n == 1 ? '' : 's'}';
    return past ? '$phrase ago' : 'in $phrase';
  }

  if (abs < 45000) return 'just now';
  final minutes = abs ~/ 60000;
  if (minutes < 60) return unit(max(1, minutes), 'minute');
  final hours = abs ~/ 3600000;
  if (hours < 24) return unit(hours, 'hour');
  final days = abs ~/ 86400000;
  if (days < 30) return unit(days, 'day');
  final months = days ~/ 30;
  if (months < 12) return unit(months, 'month');
  return unit(days ~/ 365, 'year');
}

String exprStartOfMonth([dynamic v]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return '';
  final d = _exprUtc(ms);
  return _exprIsoDate(d.year, d.month, 1);
}

String exprEndOfMonth([dynamic v]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return '';
  final d = _exprUtc(ms);
  return _exprIsoDate(d.year, d.month, _exprDaysInMonth(d.year, d.month));
}

bool exprIsToday([dynamic v]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return false;
  final d = _exprUtc(ms);
  final t = DateTime.now();
  return d.year == t.year && d.month == t.month && d.day == t.day;
}

int exprAge([dynamic v]) {
  final ms = _exprParseDateMs(v);
  if (ms == null) return 0;
  final b = _exprUtc(ms);
  final t = DateTime.now();
  var years = t.year - b.year;
  if (t.month < b.month || (t.month == b.month && t.day < b.day)) years--;
  return years;
}

// ─── Lists ───────────────────────────────────────────────────────────────────

dynamic exprFirst([dynamic v]) => (v is List && v.isNotEmpty) ? v.first : null;

dynamic exprLast([dynamic v]) => (v is List && v.isNotEmpty) ? v.last : null;

num exprSum([dynamic v]) {
  if (v is! List) return 0;
  num acc = 0;
  for (final el in v) {
    acc += exprNum(el);
  }
  return acc;
}

num exprAvg([dynamic v]) {
  if (v is! List || v.isEmpty) return 0;
  num acc = 0;
  for (final el in v) {
    acc += exprNum(el);
  }
  return _exprIntIfWhole((acc / v.length).toDouble());
}

num exprMinOf([dynamic v]) {
  if (v is! List || v.isEmpty) return 0;
  num acc = exprNum(v.first);
  for (final el in v) {
    acc = min(acc, exprNum(el));
  }
  return acc;
}

num exprMaxOf([dynamic v]) {
  if (v is! List || v.isEmpty) return 0;
  num acc = exprNum(v.first);
  for (final el in v) {
    acc = max(acc, exprNum(el));
  }
  return acc;
}

String exprJoin([dynamic v, dynamic sep]) {
  if (v is! List) return '';
  return v.map(_exprToStr).join(sep == null ? ', ' : _exprToStr(sep));
}

/// Sorted copy, ascending — numerically when every item is a number, else by
/// code-unit string compare (same as the TS mirror's `<`/`>`).
List<dynamic> exprSort([dynamic v]) {
  if (v is! List) return <dynamic>[];
  final out = List<dynamic>.of(v);
  final allNum = out.isNotEmpty && out.every((el) => el is num);
  if (allNum) {
    out.sort((a, b) => (a as num).compareTo(b as num));
  } else {
    out.sort((a, b) => _exprToStr(a).compareTo(_exprToStr(b)));
  }
  return out;
}

List<dynamic> exprUnique([dynamic v]) {
  if (v is! List) return <dynamic>[];
  final seen = <String>{};
  final out = <dynamic>[];
  for (final el in v) {
    String key;
    try {
      key = jsonEncode(el);
    } catch (_) {
      key = _exprToStr(el);
    }
    if (seen.add(key)) out.add(el);
  }
  return out;
}

List<dynamic> exprFlatten([dynamic v]) {
  if (v is! List) return <dynamic>[];
  final out = <dynamic>[];
  for (final el in v) {
    if (el is List) {
      out.addAll(el);
    } else {
      out.add(el);
    }
  }
  return out;
}

List<dynamic> exprTake([dynamic v, dynamic n]) {
  if (v is! List) return <dynamic>[];
  final k = max(0, exprNum(n).truncate());
  return v.take(k).toList();
}

List<dynamic> exprSkip([dynamic v, dynamic n]) {
  if (v is! List) return <dynamic>[];
  final k = max(0, exprNum(n).truncate());
  return v.skip(k).toList();
}

List<dynamic> exprConcat([dynamic a, dynamic b]) => <dynamic>[
  ...(a is List ? a : const <dynamic>[]),
  ...(b is List ? b : const <dynamic>[]),
];

List<dynamic> exprAppend([dynamic v, dynamic item]) => <dynamic>[
  ...(v is List ? v : const <dynamic>[]),
  item,
];

List<dynamic> exprWithout([dynamic v, dynamic item]) {
  if (v is! List) return <dynamic>[];
  final needle = _exprToStr(item);
  return v.where((el) => _exprToStr(el) != needle).toList();
}

List<dynamic> exprRange([dynamic a, dynamic b]) {
  var lo = 0;
  int hi;
  if (b == null) {
    hi = exprNum(a).truncate();
  } else {
    lo = exprNum(a).truncate();
    hi = exprNum(b).truncate();
  }
  final out = <dynamic>[];
  for (var i = lo; i < hi && out.length < 10000; i++) {
    out.add(i);
  }
  return out;
}

List<dynamic> exprPluck([dynamic v, dynamic key]) {
  if (v is! List) return <dynamic>[];
  final k = _exprToStr(key);
  return v
      .map<dynamic>((el) => (el is Map && el.containsKey(k)) ? el[k] : null)
      .toList();
}

// ─── Lists: higher-order helpers (compiled from `x => …` lambdas) ────────────

/// `find(list, x => test)` — the first element whose [test] is truthy, or null.
dynamic exprFind(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) test,
) {
  if (list is! Iterable) return null;
  for (final e in list) {
    if (exprTruthy(test(_exprChildCtx(ctx, name, e)))) return e;
  }
  return null;
}

/// `any(list, x => test)` — true when at least one element matches.
bool exprAny(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) test,
) {
  if (list is! Iterable) return false;
  for (final e in list) {
    if (exprTruthy(test(_exprChildCtx(ctx, name, e)))) return true;
  }
  return false;
}

/// `every(list, x => test)` — true when ALL elements match (empty list → true).
bool exprEvery(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) test,
) {
  if (list is! Iterable) return true;
  for (final e in list) {
    if (!exprTruthy(test(_exprChildCtx(ctx, name, e)))) return false;
  }
  return true;
}

/// `sortBy(list, x => key)` — sorted copy, ascending by the key expression.
/// Numeric compare when both keys are numbers, else code-unit string compare.
/// Decorated with the index for stability (Dart's List.sort is not stable, the
/// TS mirrors' Array.sort is).
List<dynamic> exprSortBy(
  Map<String, dynamic> ctx,
  String name,
  dynamic list,
  dynamic Function(Map<String, dynamic>) key,
) {
  if (list is! Iterable) return <dynamic>[];
  final items = list.toList();
  final keyed = <MapEntry<int, dynamic>>[];
  for (var i = 0; i < items.length; i++) {
    keyed.add(MapEntry(i, key(_exprChildCtx(ctx, name, items[i]))));
  }
  keyed.sort((a, b) {
    final ka = a.value;
    final kb = b.value;
    int cmp;
    if (ka is num && kb is num) {
      cmp = ka.compareTo(kb);
    } else {
      cmp = _exprToStr(ka).compareTo(_exprToStr(kb));
    }
    return cmp != 0 ? cmp : a.key.compareTo(b.key);
  });
  return keyed.map((e) => items[e.key]).toList();
}

// ─── Logic & validation ──────────────────────────────────────────────────────

bool exprNot([dynamic v]) => !exprTruthy(v);

dynamic exprIif([dynamic c, dynamic a, dynamic b]) => exprTruthy(c) ? a : b;

/// The first value that is not null and not empty text (compiled variadically:
/// `coalesce(a, b, c)` → `exprCoalesce(<dynamic>[a, b, c])`).
dynamic exprCoalesce(List<dynamic> args) {
  for (final a in args) {
    if (a != null && a != '') return a;
  }
  return null;
}

bool exprIsEmpty([dynamic v]) =>
    v == null || v == '' || (v is List && v.isEmpty) || (v is Map && v.isEmpty);

bool exprIsNotEmpty([dynamic v]) => !exprIsEmpty(v);

bool exprIsNull([dynamic v]) => v == null;

bool exprToBool([dynamic v]) => exprTruthy(v);

String exprStr([dynamic v]) => _exprToStr(v);

String exprTypeOf([dynamic v]) {
  if (v == null) return 'null';
  if (v is List) return 'list';
  if (v is Map) return 'object';
  if (v is bool) return 'boolean';
  if (v is num) return 'number';
  if (v is String) return 'string';
  return 'object';
}

bool exprBetween([dynamic v, dynamic lo, dynamic hi]) {
  final n = exprNum(v);
  return n >= exprNum(lo) && n <= exprNum(hi);
}

bool exprOneOf([dynamic v, dynamic list]) {
  if (list is! List) return false;
  final needle = _exprToStr(v);
  return list.any((el) => _exprToStr(el) == needle);
}

bool exprIsEmail([dynamic v]) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_exprToStr(v));

bool exprIsPhone([dynamic v]) {
  final s = _exprToStr(v).trim();
  if (s.isEmpty || !RegExp(r'^[+0-9][0-9\s\-().]*$').hasMatch(s)) return false;
  final d = s.replaceAll(RegExp(r'[^0-9]'), '');
  return d.length >= 7 && d.length <= 15;
}

bool exprIsUrl([dynamic v]) =>
    RegExp(r'^https?://[^\s/$.?#][^\s]*$').hasMatch(_exprToStr(v).trim());

/// Strict "is the WHOLE value a number?" — deliberately NOT [_exprReadNumber]:
/// isNumeric('12x') must stay false even though maths on '12x' now reads 12.
bool exprIsNumeric([dynamic v]) {
  if (v is num) return v.isFinite;
  if (v is! String) return false;
  final t = v.trim();
  if (t.isEmpty) return false;
  final d = double.tryParse(t);
  return d != null && d.isFinite;
}

/// Tests against a regular expression; an invalid pattern gives false.
bool exprMatches([dynamic v, dynamic p]) {
  try {
    return RegExp(_exprToStr(p)).hasMatch(_exprToStr(v));
  } catch (_) {
    return false;
  }
}

// ─── Encode & data ───────────────────────────────────────────────────────────

String exprJson([dynamic v]) {
  try {
    return jsonEncode(v);
  } catch (_) {
    return 'null';
  }
}

dynamic exprParseJson([dynamic v]) {
  try {
    return jsonDecode(_exprToStr(v));
  } catch (_) {
    return null;
  }
}

String exprUrlEncode([dynamic v]) => Uri.encodeComponent(_exprToStr(v));

String exprUrlDecode([dynamic v]) {
  try {
    return Uri.decodeComponent(_exprToStr(v));
  } catch (_) {
    return _exprToStr(v);
  }
}

String exprBase64Encode([dynamic v]) =>
    base64.encode(utf8.encode(_exprToStr(v)));

String exprBase64Decode([dynamic v]) {
  try {
    return utf8.decode(base64.decode(base64.normalize(_exprToStr(v).trim())));
  } catch (_) {
    return '';
  }
}

/// A random UUID v4 (e.g. for request ids). Random-based, dependency-free.
String exprUuid() {
  final r = Random();
  const hex = '0123456789abcdef';
  final sb = StringBuffer();
  for (var i = 0; i < 36; i++) {
    if (i == 8 || i == 13 || i == 18 || i == 23) {
      sb.write('-');
      continue;
    }
    if (i == 14) {
      sb.write('4');
      continue;
    }
    final n = r.nextInt(16);
    sb.write(i == 19 ? hex[(n & 0x3) | 0x8] : hex[n]);
  }
  return sb.toString();
}
