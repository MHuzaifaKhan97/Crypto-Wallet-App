// No-op on every compile target EXCEPT web (dart.library.js) — see main.dart's
// conditional import. Keeps mobile/VM builds from ever linking
// package:flutter_web_plugins, which only compiles for web.
void configureUrlStrategy() {}
