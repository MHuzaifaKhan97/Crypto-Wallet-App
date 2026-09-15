import 'package:flutter_web_plugins/url_strategy.dart';

/// Switches go_router (and Flutter's own Navigator) from hash URLs (#/...) to
/// plain path URLs on web, so the generated app is a normal web citizen —
/// shareable/bookmarkable links, working browser back/forward.
void configureUrlStrategy() {
  usePathUrlStrategy();
}
