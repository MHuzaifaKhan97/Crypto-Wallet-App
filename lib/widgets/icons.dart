import 'package:flutter/material.dart';

/// Shared icon resolver for catalog components (Phase: KSA app port).
///
/// Design Mode props are limited to color/number/enum/toggle/text, so a
/// component that shows an icon declares an `enum` prop whose options are names
/// from [kCatalogIconNames], and resolves it here at render time. This is the
/// "icon-as-prop" decision — it avoids bundling the source app's SVG assets
/// while keeping icons client-editable.
///
/// The SAME names are also what a navShell tab's `icon` may be, so a bottom
/// tab renders the exact icon someone picked rather than one guessed from its
/// label.
///
/// This file is copied verbatim into every generated app, so it is the
/// render-time source of truth. To grow the set, add the name to BOTH
/// kCatalogIconNames and the switch below, AND to CATALOG_ICON_DART in the
/// icon catalog.
const List<String> kCatalogIconNames = [
  // Money movement
  'send', 'request', 'receive', 'transfer', 'topup', 'exchange', 'pay',
  'bill', 'split',
  // Accounts & instruments
  'wallet', 'card', 'bank', 'savings', 'loan', 'freeze',
  // Navigation destinations
  'home', 'dashboard', 'grid', 'chart', 'history', 'receipt', 'person',
  'account', 'contacts', 'settings', 'more', 'menu',
  // Communication
  'notifications', 'email', 'chat', 'phone',
  // Security
  'security', 'lock', 'fingerprint', 'logout',
  // Codes & capture
  'qr', 'scan', 'camera', 'image',
  // Content
  'document', 'folder', 'offer', 'gift', 'shopping', 'food', 'transport',
  'location',
  // Actions
  'add', 'plus', 'minus', 'edit', 'delete', 'copy', 'share', 'download',
  'upload', 'refresh', 'search', 'filter', 'backspace', 'link',
  // Status & feedback
  'check', 'success', 'close', 'warning', 'info', 'help', 'star', 'favorite',
  // Directional arrows — the diagonals a transaction row needs, named for the
  // direction they point rather than for an action (see the TS side's note).
  'arrow_up_right', 'arrow_down_left',
  // Chrome & misc
  'arrow_forward',
  'arrow_back',
  'chevron_right',
  'chevron_left',
  'eye',
  'eye_off',
  'calendar', 'language', 'theme',
  // A caret that EXPANDS something in place — an account picker, a period
  // dropdown, an accordion. Distinct from chevron_right, which means "goes
  // somewhere else": substituting one for the other keeps the pixels roughly
  // right and tells the user the wrong thing about what the control does.
  'expand_more', 'expand_less',
  // The FILLED star. 'star' is Icons.star_outline — the empty half of a
  // favourite toggle — and until this there was no way to draw the other half.
  'star_filled',
];

IconData iconFromName(String? name) {
  switch (name) {
    // Money movement
    case 'send':
      return Icons.north_east;
    case 'request':
      return Icons.south_west;
    case 'receive':
      return Icons.south_east;
    case 'transfer':
      return Icons.swap_horiz;
    case 'topup':
      return Icons.add_circle_outline;
    case 'exchange':
      return Icons.currency_exchange;
    case 'pay':
      return Icons.payments_outlined;
    case 'bill':
      return Icons.receipt_long_outlined;
    case 'split':
      return Icons.call_split;
    // Accounts & instruments
    case 'wallet':
      return Icons.account_balance_wallet_outlined;
    case 'card':
      return Icons.credit_card;
    case 'bank':
      return Icons.account_balance_outlined;
    case 'savings':
      return Icons.savings_outlined;
    case 'loan':
      return Icons.request_quote_outlined;
    case 'freeze':
      return Icons.ac_unit;
    // Navigation destinations
    case 'home':
      return Icons.home_outlined;
    case 'dashboard':
      return Icons.dashboard_outlined;
    case 'grid':
      return Icons.grid_view_outlined;
    case 'chart':
      return Icons.bar_chart;
    case 'history':
      return Icons.history;
    case 'receipt':
      return Icons.receipt_outlined;
    case 'person':
      return Icons.person_outline;
    case 'account':
      return Icons.account_circle_outlined;
    case 'contacts':
      return Icons.contacts_outlined;
    case 'settings':
      return Icons.settings_outlined;
    case 'more':
      return Icons.more_horiz;
    case 'menu':
      return Icons.menu;
    // Communication
    case 'notifications':
      return Icons.notifications_none;
    case 'email':
      return Icons.email_outlined;
    case 'chat':
      return Icons.chat_bubble_outline;
    case 'phone':
      return Icons.phone_outlined;
    // Security
    case 'security':
      return Icons.shield_outlined;
    case 'lock':
      return Icons.lock_outline;
    case 'fingerprint':
      return Icons.fingerprint;
    case 'logout':
      return Icons.logout;
    // Codes & capture
    case 'qr':
      return Icons.qr_code_2;
    case 'scan':
      return Icons.qr_code_scanner;
    case 'camera':
      return Icons.camera_alt_outlined;
    case 'image':
      return Icons.image_outlined;
    // Content
    case 'document':
      return Icons.description_outlined;
    case 'folder':
      return Icons.folder_outlined;
    case 'offer':
      return Icons.local_offer_outlined;
    case 'gift':
      return Icons.card_giftcard;
    case 'shopping':
      return Icons.shopping_bag_outlined;
    case 'food':
      return Icons.restaurant_outlined;
    case 'transport':
      return Icons.directions_car_outlined;
    case 'location':
      return Icons.place_outlined;
    // Actions
    case 'add':
      return Icons.add;
    case 'plus':
      return Icons.add;
    case 'minus':
      return Icons.remove;
    case 'edit':
      return Icons.edit_outlined;
    case 'delete':
      return Icons.delete_outline;
    case 'copy':
      return Icons.copy_outlined;
    case 'share':
      return Icons.share_outlined;
    case 'download':
      return Icons.download_outlined;
    case 'upload':
      return Icons.upload_outlined;
    case 'refresh':
      return Icons.refresh;
    case 'search':
      return Icons.search;
    case 'filter':
      return Icons.filter_list_outlined;
    case 'backspace':
      return Icons.backspace_outlined;
    case 'link':
      return Icons.link;
    // Status & feedback
    case 'check':
      return Icons.check;
    case 'success':
      return Icons.check_circle_outline;
    case 'close':
      return Icons.close;
    case 'warning':
      return Icons.warning_amber_outlined;
    case 'info':
      return Icons.info_outline;
    case 'help':
      return Icons.help_outline;
    case 'star':
      return Icons.star_outline;
    case 'favorite':
      return Icons.favorite_border;
    // Chrome & misc
    // Directional arrows
    case 'arrow_up_right':
      return Icons.north_east;
    case 'arrow_down_left':
      return Icons.south_west;
    case 'arrow_forward':
      return Icons.arrow_forward;
    case 'arrow_back':
      return Icons.arrow_back;
    case 'chevron_right':
      return Icons.chevron_right;
    case 'chevron_left':
      return Icons.chevron_left;
    case 'eye':
      return Icons.visibility_outlined;
    case 'eye_off':
      return Icons.visibility_off_outlined;
    case 'calendar':
      return Icons.calendar_today_outlined;
    case 'language':
      return Icons.language;
    case 'theme':
      return Icons.dark_mode_outlined;
    case 'expand_more':
      return Icons.expand_more;
    case 'expand_less':
      return Icons.expand_less;
    case 'star_filled':
      return Icons.star;
    default:
      return Icons.circle_outlined;
  }
}

// ── Image icons ─────────────────────────────────────────────────────────────
// An icon prop may also hold an IMAGE reference instead of a catalog name —
// one of the design library's own uploads, picked from the Assets tab of the
// icon picker. Nothing extra is needed to get one here: the canvas resolves
// `asset:<id>` to a served URL before pushing the document and codegen
// rewrites it to `asset://<file>` and bundles the file (rewriteDocAssetRefs)
// — exactly what already happens for the Image primitive's `src`. Both forms
// land in these two functions.

/// True when an icon prop's value is an image reference rather than one of
/// [kCatalogIconNames].
bool isImageIconRef(String? v) {
  if (v == null || v.isEmpty) return false;
  return v.startsWith('asset://') ||
      v.startsWith('bundled://') ||
      v.startsWith('http://') ||
      v.startsWith('https://') ||
      v.startsWith('/');
}

/// Renders an icon prop: a catalog name draws the Material glyph tinted with
/// [color]; an image ref draws that image at [size] square, untinted (the
/// artwork carries its own colours — tinting a logo would destroy it).
///
/// Every place a USER picks an icon goes through here rather than
/// `Icon(iconFromName(...))`, so an uploaded glyph works wherever a catalog
/// one does. A failed load falls back to the same circle [iconFromName]
/// draws for an unknown name.
Widget catalogIcon(String? name, {double size = 24, Color? color}) {
  if (!isImageIconRef(name)) {
    return Icon(iconFromName(name), size: size, color: color);
  }
  final src = name!;
  Widget fallback() => Icon(Icons.circle_outlined, size: size, color: color);
  final Widget image;
  if (src.startsWith('bundled://')) {
    image = Image.asset(
      'assets/${src.substring('bundled://'.length)}',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback(),
    );
  } else if (src.startsWith('asset://')) {
    image = Image.asset(
      'assets/gen/${src.substring('asset://'.length)}',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback(),
    );
  } else {
    image = Image.network(
      src,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
  return SizedBox(width: size, height: size, child: image);
}
