# Crypto Trading App

A Flutter app exported from Studio X. **This export is one-way**: Studio X
cannot import your edits back. From here on, this repository is the source of
truth — treat it like any hand-written Flutter project.

## Run it

```
flutter pub get
flutter run
```

If `android/` or `ios/` folders are missing (the export carries only the
app source), create them once with:

```
flutter create . --platforms android,ios
```

## Where things are

| Path                   | What it is                                                      |
| ---------------------- | --------------------------------------------------------------- |
| `lib/main.dart`        | App entry: theme, routing (go_router), startup                  |
| `lib/screens/`         | One file per screen — plain widget code                         |
| `lib/overlays/`        | Dialogs and bottom sheets, one widget class each                |
| `lib/widgets/`         | The reusable widget library (buttons, cards, inputs, …)         |
| `lib/widgets/typed/`   | Typed wrappers over that library — constructor params, not maps |
| `lib/theme/theme.dart` | Colors, fonts, radii (`AppColors`, `AppTextStyles`)             |
| `lib/state/`           | App-wide state (Riverpod store; `setVar`/`state`) + its scope   |
| `lib/api/`             | Every API endpoint, base URLs, auth headers                     |
| `lib/custom/`          | Custom functions and widgets — your hand-written code           |
| `lib/runtime/`         | Small shared helpers (expressions, motion, models, validators)  |
| `env/`                 | Per-environment base URLs (`--dart-define-from-file`)           |

Everything here is yours: plain Flutter, no framework of ours to learn, no
file you are not meant to touch. This app ships **only the widgets it uses** —
`lib/widgets/` is this app's library, not a catalog, so a file in it is one
some screen imports.

> Note: 7 screen tree(s) use features the readable emitter does not cover yet and are rendered through the bundled interpreter (`lib/runtime/node_view.dart`) instead:
>
> - `s-home`: color token 'c-border' is not a Dart identifier
> - `s-portfolio`: color token 'c-border' is not a Dart identifier
> - `s-market`: color token 'c-border' is not a Dart identifier
> - `s-profile`: color token 'c-border' is not a Dart identifier
> - `s-search`: color token 'c-border' is not a Dart identifier
> - `s-history`: color token 'c-border' is not a Dart identifier
> - `s-notifications`: color token 'c-border' is not a Dart identifier

## Adding a screen

1. Create `lib/screens/my_screen.dart` with a `StatelessWidget`/`StatefulWidget`.
2. Register a route for it in `lib/main.dart` (see the existing `GoRoute` entries).
3. Navigate with `context.push('/my-screen')` from any `onTap`.

## Removing a screen

Delete its file under `lib/screens/`, remove its `GoRoute` and import
from `lib/main.dart`, and remove any `context.push`/`context.go` calls that
pointed at it. `flutter analyze` will list anything you missed.

## Removing a widget you no longer use

Delete the file under `lib/widgets/` and the import lines that named it.
Two more places may mention it: its typed wrapper in `lib/widgets/typed/`
(delete that too), and the `switch` in `lib/runtime/registry.dart` — remove
that `case` and the import above it. `flutter analyze` finds the rest.

## Adding a package

Add it under `dependencies:` in `pubspec.yaml`, run `flutter pub get`, and
import it where you need it — nothing else in this repo has to know:

```
dependencies:
  intl: ^0.20.2          # already here
  your_package: ^1.0.0   # yours
```

## APIs & environments

`lib/api/api_client.dart` is this app's API catalog: one `Dio` per API group,
then **one named method per endpoint**, with the URL, the HTTP verb and the
endpoint's static header/body/query values baked in. Screens call those
methods — no screen carries a URL.

```dart
final res = await apiClients.<group><Endpoint>(
  walletId: state.walletId,   // required String — it is a URL path segment
  accounts: rows,             // Object? — sent as-is, so a List stays a List
);
final data = res.data;        // the decoded JSON body
```

Each method's doc comment names the verb, the path and where every parameter
lands (path segment, query key, header, body field). A parameter is typed when
the endpoint pins the type down — a path segment can only be a `String` — and
stays `Object?` when it does not, so nothing claims a type your backend never
promised. An optional argument you omit is left out of the request entirely
rather than sent as null.

**Environments.** Every base URL — and every group credential (see below) —
lives in `env/`:

```
flutter run --dart-define-from-file=env/dev.json
flutter build apk --release --dart-define-from-file=env/prod.json
```

Edit `env/staging.json` etc. to point at your servers, or pass single values
with `--dart-define=<GROUP>_BASE_URL=…`.

**Credentials.** A group's fixed auth header (a Basic token, an API key) is
**not** compiled into `api_client.dart` — it is read from the build
environment, and `env/*.json` carries the value this app was configured with:

```dart
const String <group>AuthorizationHeader =
    String.fromEnvironment('<GROUP>_AUTHORIZATION');
```

Treat `env/*.json` as secrets — keep them out of version control (or replace
the values with your own) and rotate there, not in the Dart source. A build
that forgets the env file sends an empty header and fails its API calls, which
is deliberate: it never falls back to a token baked into the bundle.

Requests go straight from the app to your backend. Nothing in this repository
routes through Studio X.

## Release signing & Play builds

This export contains **no keystore and no passwords** — they are never written
into a project or a zip. `android/app/build.gradle.kts` is already wired to
sign release builds from `android/key.properties`; you supply that file.

1. Put your keystore at `android/app/release.jks` (any path works).
   In Studio X: **Settings → App & Release → Android signing → Download backup**
   gives you the `.jks` this app was signed with — the _same_ key you must keep
   using, or Google Play will reject the upload as a different app.
   No keystore yet? Create one:

   ```
   keytool -genkeypair -v -keystore android/app/release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copy `android/key.properties.example` to `android/key.properties` and fill
   it in (`storeFile` may be absolute or relative to `android/app/`).
   **Add `android/key.properties` and `*.jks` to `.gitignore` — never commit
   either.** Losing the keystore means you can never update the app on Play.

3. Build:

   ```
   flutter build appbundle --release   # .aab — what Google Play accepts
   flutter build apk --release         # .apk — direct install / side-loading
   ```

   Outputs: `build/app/outputs/bundle/release/app-release.aab` and
   `build/app/outputs/flutter-apk/app-release.apk`.

   Verify you signed with the right key, not the debug one (APKs are
   v2/v3-signed, so use `apksigner` from the Android build-tools; `keytool`
   only reads the jar-signed .aab):

   ```
   $ANDROID_HOME/build-tools/<version>/apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
   keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
   ```

### Obfuscation and crash reports

```
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Obfuscation strips Dart identifiers, so crash stack traces come back as
gibberish. **Archive `build/symbols/` for every release you ship** (it is not
in this repo, and the next build overwrites it) and turn a trace back into
source with:

```
flutter symbolize -i crash.txt -d build/symbols/app.android-arm64.symbols
```
