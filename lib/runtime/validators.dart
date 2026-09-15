/// Shared field-validation runner — used by every interactive input catalog
/// widget (TextInput, PhoneInput, …) so `required`/`email`/`minLength`/
/// `maxLength`/`regex`/`match` behave identically everywhere a node carries
/// `validators`, instead of each widget re-implementing its own subset.
library;

/// Regex used by the `email` validator kind — deliberately simple (not a full
/// RFC 5322 matcher), matching the "good enough for a form field" bar.
final RegExp kEmailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// `url` — http(s) with a host and at least one dot. Deliberately permissive.
final RegExp kUrlRegex = RegExp(
  r'^https?://[^\s.]+\.[^\s]+$',
  caseSensitive: false,
);

/// `phone` — 7–15 digits, optional leading `+`, allowing spaces/dashes/parens
/// which are stripped before counting.
final RegExp kPhoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

/// `number` — an integer (optionally signed). `alphanumeric` — letters/digits.
final RegExp kIntRegex = RegExp(r'^-?\d+$');
final RegExp kAlphanumRegex = RegExp(r'^[a-zA-Z0-9]+$');

/// Runs a node's `validators` (in order) against `value`, returning the FIRST
/// failing rule's message (its own `message`, else a sensible per-kind
/// default), or null if every rule passes.
///
/// BACK-COMPAT: when `validators` is empty but the legacy `props.required`
/// toggle is set, behaves as a single implicit `required` rule so existing
/// screens (authored before validators existed) don't regress.
///
/// `match` (cross-field equality, e.g. "confirm password") compares `value`
/// against another field's live state variable, resolved through [readField]
/// (the rule's `value` is that other field's state-variable name). [readField]
/// is supplied in generated apps via StateScope; on the design canvas it is
/// null, and `match` degrades to a safe no-op rather than risk a crash.
String? runFieldValidators(
  List<Map<String, dynamic>> validators,
  bool legacyRequired,
  String value, {
  String? Function(String field)? readField,
}) {
  final rules = validators.isNotEmpty
      ? validators
      : (legacyRequired
            ? const [
                <String, dynamic>{'kind': 'required'},
              ]
            : const <Map<String, dynamic>>[]);

  for (final rule in rules) {
    final kind = rule['kind'] as String?;
    final message = rule['message'] as String?;
    switch (kind) {
      case 'required':
        if (value.trim().isEmpty) return message ?? 'Required';
        break;
      case 'email':
        if (!kEmailRegex.hasMatch(value))
          return message ?? 'Enter a valid email';
        break;
      case 'url':
        if (!kUrlRegex.hasMatch(value.trim()))
          return message ?? 'Enter a valid URL';
        break;
      case 'phone':
        final digits = value.replaceAll(RegExp(r'[\s\-()]'), '');
        if (!kPhoneRegex.hasMatch(digits))
          return message ?? 'Enter a valid phone number';
        break;
      case 'number':
        if (!kIntRegex.hasMatch(value.trim()))
          return message ?? 'Enter a number';
        break;
      case 'alphanumeric':
        if (!kAlphanumRegex.hasMatch(value))
          return message ?? 'Letters and numbers only';
        break;
      case 'min':
        {
          final n = (rule['value'] is num)
              ? (rule['value'] as num).toDouble()
              : null;
          final parsed = double.tryParse(value.trim());
          if (n != null && (parsed == null || parsed < n))
            return message ?? 'Must be at least $n';
        }
        break;
      case 'max':
        {
          final n = (rule['value'] is num)
              ? (rule['value'] as num).toDouble()
              : null;
          final parsed = double.tryParse(value.trim());
          if (n != null && (parsed == null || parsed > n))
            return message ?? 'Must be at most $n';
        }
        break;
      case 'minLength':
        final n = (rule['value'] is num)
            ? (rule['value'] as num).toInt()
            : null;
        if (n != null && value.length < n)
          return message ?? 'Must be at least $n characters';
        break;
      case 'maxLength':
        final n = (rule['value'] is num)
            ? (rule['value'] as num).toInt()
            : null;
        if (n != null && value.length > n)
          return message ?? 'Must be at most $n characters';
        break;
      case 'regex':
        final pattern = rule['value'] as String?;
        if (pattern != null) {
          try {
            if (!RegExp(pattern).hasMatch(value))
              return message ?? 'Invalid format';
          } catch (_) {
            // Malformed pattern authored in the editor — don't crash the
            // field over it; treat as passing.
          }
        }
        break;
      case 'match':
        {
          final other = rule['value'] as String?;
          // No resolver (canvas) or no target named → nothing to compare against.
          if (other != null && other.isNotEmpty && readField != null) {
            if (value != (readField(other) ?? '')) {
              return message ?? 'Fields do not match';
            }
          }
        }
        break;
      default:
        // Unknown rule kind (future addition) — ignore rather than fail.
        break;
    }
  }
  return null;
}
