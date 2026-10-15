# ChurchLib desktop: trial and license

The app now talks to the ChurchLib admin portal (`/api/v1/*`) to start a 7-day free trial, unlock a paid license for one computer, and keep working offline in between.

## Before you build

1. `flutter pub get`. Three packages were added: `crypto`, `cryptography`, `device_info_plus`.
2. Give the build two values (Dashboard → Settings shows both):

   | Value | What it is |
   |---|---|
   | `LICENSE_API_URL` | Address of the admin portal, e.g. `https://your-portal.example.com` |
   | `LICENSE_PUBLIC_KEY` | The 32-byte public key shown under *Desktop app connection* |

   ```sh
   flutter build windows \
     --dart-define=LICENSE_API_URL=https://your-portal.example.com \
     --dart-define=LICENSE_PUBLIC_KEY=<public key>
   ```
   Add the same two `--dart-define` flags to every build command in your release pipeline (Windows, macOS, Linux), including staging if it has its own portal.

   * **Release build without them:** the app shows "license server is not set up" instead of running for free, so a missing flag is caught in testing.
   * **Debug build without them:** everything is unlocked, so day-to-day development is not blocked.

## How it behaves

| Situation | What happens |
|---|---|
| First launch, online | Trial starts (the server records the computer). Setup continues as before. |
| First launch, offline | "Connect to the internet" screen with Try again. Setup needs internet anyway. |
| Trial running | Works fully offline. Sidebar shows "Free trial: N days left" and a **Buy license** button. |
| Trial ends while the app is open | **The session is never interrupted.** The banner changes, and the lock applies next time the app starts. |
| Trial over at startup | Paywall: price, M-Pesa or PayPal instructions, form for the transaction code. |
| Payment submitted | "Payment received": checks every 30 seconds and unlocks by itself once you approve it in the dashboard. |
| Licensed | Works offline forever. Nothing is shown. Settings → License shows key, computer id, last check. |
| License revoked | Paywall variant with support links (applied at next start). |
| Clock turned back | "Check your computer's date and time" until the clock is right. Licensed computers ignore the clock. |
| New computer | Dashboard: *Allow one more transfer*. App (old PC): Settings → License → *Move to another computer*. New PC: *Have a license key?* |

The app asks the server on every start, every 6 hours while running, and when the connection returns.

## What is trusted

* Only a token whose **Ed25519 signature** verifies with the built-in public key **and** whose computer id matches this computer is believed. The `status` text in the server's JSON is ignored.
* The computer id is the OS machine id (Windows install id, macOS hardware UUID, Linux `/etc/machine-id`) hashed with SHA-256. The raw id never leaves the computer. It is recomputed on every start and never copied into app storage, so copying the app's data folder to another PC does not move the license.
* Editing stored values can't grant anything: deleting them only makes the app ask the server again, and the server remembers the trial.

## Files

```
lib/core/license/         models, config, evaluator (pure rules), verifier, machine id,
                          storage, API client, service, cubit, registration
lib/features/license/ui/  paywall screen, purchase panel/window, sidebar banner, settings section
test/license/             rule tests, signature tests, cubit tests (fixtures signed by the portal)
```
Wiring changes: `injectable.dart` (manual registration, so **no `build_runner` is needed**), both `main` files, `app.dart`, the router and its redirect, `app_shell.dart`, `settings_sections.dart`, `open_windows.dart`, `pubspec.yaml`, and 51 new strings in `l10n/*.arb` plus the generated `lib/l10n/*.dart` (same format as `flutter gen-l10n`; running it again is harmless).

## Testing

`flutter test test/license` covers the rules, the signature check against tokens signed by the portal's own code, and the gate behaviour (first run locked, running session never interrupted, payment unlock, release).

Manual pass worth doing once, with a staging portal:
1. Fresh install online: the computer appears under **Installations** as *Trial*.
2. Start with no internet: connect screen. Reconnect, tap Try again: setup continues.
3. In the dashboard use **Extend trial**, or wait out a short trial: paywall appears at next start.
4. Submit a code: it shows under **Approvals**. Approve it: the paywall closes by itself.
5. Allow a transfer, release on PC A, redeem the key on PC B.

## Worth knowing

* **Licensing and the GPL.** `snap/snapcraft.yaml` declares `license: GPL-3.0`. Under the GPL anyone may remove the license check from the source and rebuild. The check keeps honest users honest, which is the realistic goal, but if you want to restrict that, the license needs to change (you can, as the copyright holder). Worth a deliberate decision.
* **Windows id.** Taken from `device_info_plus`, with a `reg query` fallback, then a random id kept in app storage as a last resort (that case would reset a trial if app data were wiped, so it should be rare).
* **Swahili.** The new Swahili strings are my translation. Please have a native speaker read them.
* `NetworkUtil.onConnectivityChanged` (existing code) compares a list to a single value, so it reports "online" on every change. It is harmless here because checks are rate-limited, but it is worth fixing.
