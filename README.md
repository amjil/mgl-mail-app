# MGL Mail

A cross-platform email client for **Traditional Mongolian** (vertical script). It runs on iOS, Android, macOS, Windows, and Linux, with a mobile shell and a desktop shell that share one mail engine.

The UI is written in [ClojureDart](https://github.com/tensegritics/ClojureDart) on Flutter. Mail sync, storage, and SMTP live in a Dart `mail_core` layer behind a thin ClojureDart wrapper (`MailBridge`).

## Features

- IMAP sync (delta + IDLE) and SMTP send, with local SQLite ([Drift](https://pub.dev/packages/drift)) storage
- Background workers per account: IMAP, outbox queue, and sent-folder reconcile
- Multiple accounts: generic IMAP/SMTP password login, plus Outlook / Microsoft 365 via OAuth2 (XOAUTH2)
- Folders: Inbox, Sent, Drafts, Outbox, Archive, Trash, Junk, and custom IMAP folders
- Create, rename, and delete custom folders
- Full-text search (FTS) over subject and body; contact autocomplete when composing
- Attachments, read/unread, star, archive, reply, reply all, forward, and bulk actions
- Conversation grouping in the desktop mail list (by Message-ID / In-Reply-To / References)
- Vertical Mongolian layout for reading and composing
- Dual-engine reader: native block renderer for MGL Mail, WebView (WebKit / Chromium) for ordinary HTML
- Block editor for compose (headings, lists, quotes, attachments)
- Draft auto-save (~5s) and per-account signatures
- In-app Mongolian virtual keyboard on mobile; desktop IME overlay with FST dictionaries
- Credentials: Keychain / Keystore in release; local JSON file in debug (unsigned macOS builds)

## Requirements

- [Clojure CLI](https://clojure.org/guides/install_clojure) (`clj`)
- [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK `>=3.3.1 <4.0.0`)
- Sibling local packages (same parent directory as this repo):

| Path | Package |
|------|---------|
| `mgl-components` | Shared UI components |
| `mongol-virtual-keyboard` | Mongolian virtual keyboard (mobile) |
| `mongol-ime` | Mongolian desktop IME |
| `mgl-ime-core` | IME core / FST |
| `mgl-block-editor` | Vertical block editor |
| `mgl-richtext-editor` | Rich-text fields (`mgl_editor_core`) |

These paths are set in `deps.edn` (and `mgl_editor_core` also in `pubspec.yaml`).

## Getting started

```sh
clj -M:cljd init
```

Open a simulator if you are targeting iOS:

```sh
open -a Simulator
```

Run the app:

```sh
clj -M:cljd flutter
```

To target a specific device:

```sh
clj -M:cljd flutter -d macos
clj -M:cljd flutter -d chrome
```

## Project layout

```
src/mail_app/                 ClojureDart UI (mobile + desktop)
  main.cljd                   Entry: bootstrap → MailBridge → mobile or desktop app
  platform.cljd               Desktop vs mobile detection
  theme.cljd                  Shared colors, fonts (OyunQaganTig), desktop theme
  bootstrap/                  FST / next-word dictionary load (desktop + mobile)
  mobile/                     Mobile screens and widgets
  desktop/                    Desktop screens, shortcuts, lifecycle, widgets
  widgets/                    Shared widgets (HTML WebView reader engine)
  services/                   ClojureDart wrappers (mail-core, compose export)
  state/                      App store
lib/mail_core/                Dart mail engine
  bridge/                     MailBridge + DTOs (UI-facing API)
  engine/                     MailEngine, per-account AccountEngine
  imap/                       Sync, IDLE, attachments
  smtp/                       SMTP send + IMAP APPEND
  workers/                    IMAP / outbox / sent background workers
  search/                     FTS indexer + search service
  oauth/                      Outlook OAuth
  db/                         Drift schema and DAOs
  secure/                     Credential store
assets/                       Mongolian fonts, IME dictionaries, and app icon
```

## App icon

Master artwork is the square `assets/icon/app_icon.png` (vector: `assets/icon/app_icon.svg`). iOS, Android, and Web keep that square so the OS can apply its own mask. macOS, Windows, and Linux need the shape baked into the PNG.

After changing the master, regenerate platform-shaped variants, then launcher icons:

```bash
python3 tool/render_platform_icons.py
dart run flutter_launcher_icons
```

`mail-app.main` picks the shell from the platform: Android/iOS use the mobile app; macOS/Windows/Linux (and web) use the desktop app.

Desktop home is a three-pane shell (folders | list | reading pane) with a draggable folder splitter. Mobile uses a drawer, list, and dedicated detail / settings screens.

## Dual-engine mail reader

Ordinary HTML mail (tables, marketing images, mixed CSS) cannot be laid out by the native block editor. The reader therefore uses two engines:

| Mail | Marker | Engine |
|------|--------|--------|
| Sent from this app | `data-mgl-mail`, `.mgl-mail-container`, `<!-- mgl-mail:… -->` | Native block editor (`be-html`), vertical Mongolian |
| External HTML (Taobao, notifications, …) | no MGL marker | WebView, normal top-to-bottom scroll |
| Plain text | — | Native blocks + quote panel |
| Windows / Linux HTML | — | Plain-text fallback (`webview_flutter` has no official host there) |

Desktop routing lives in `src/mail_app/desktop/widgets/reader_pane.cljd`. Mobile uses the same split in `src/mail_app/mobile/widgets/mail_body.cljd`. Shared WebView + CSS injection is `src/mail_app/widgets/html_webview.cljd`. Identity helpers are `export/mgl-mail-html?` and `lib/mail_core/smtp/mgl_mail_identity.dart`.

### How WebView rendering works

1. Detect MGL Mail. If the HTML contains our fingerprints, parse it with `be-html/import-from-html` and render native vertical blocks.
2. Otherwise load the HTML in `webview_flutter` as a normal web page (no `writing-mode` override).
3. Inject a light stylesheet: `OyunQaganTig` via `@font-face` (WebView cannot see Flutter’s bundled fonts), image/table `max-width: 100%`.
4. Intercept in-page `<a>` clicks and open them with the system browser (`url_launcher`), so the WebView does not navigate away from the message.

### Setup

These packages are already in `pubspec.yaml`. To add them again on a fresh checkout:

```sh
flutter pub add webview_flutter
flutter pub add webview_flutter_wkwebview
```

`webview_flutter_wkwebview` is required on **macOS** and **iOS** (WebKit). Android uses the Chromium WebView from `webview_flutter` (minSdk **24**). Official hosts today: Android, iOS, macOS.

After changing reader code, recompile ClojureDart as usual:

```sh
clj -M:cljd compile
# or run
clj -M:cljd flutter -d macos
```

## Desktop shortcuts

| Shortcut | Action |
|----------|--------|
| **Cmd/Ctrl+N** | Compose |
| **Cmd/Ctrl+F** | Search |
| **Cmd/Ctrl+R** | Sync (or Reply when reading a message) |
| **Cmd/Ctrl+Shift+R** | Reply All (when reading a message) |
| **Cmd/Ctrl+A** | Select all in the current list |
| **Cmd/Ctrl+click** / **Shift+click** | Multi-select / range-select |
| **Escape** | Clear selection or leave reading pane |
| **Delete** / **Backspace** | Delete current message (when reading) |
| **Cmd/Ctrl+Enter** | Send (compose) |
| **Cmd/Ctrl+S** | Save draft (compose) |

## Credits

- [suragch/mongol](https://github.com/suragch/mongol) — Mongolian vertical script widgets for Flutter
- [ClojureDart](https://github.com/tensegritics/ClojureDart) — Clojure on Flutter/Dart
- [enough_mail](https://pub.dev/packages/enough_mail) — IMAP/SMTP
- [webview_flutter](https://pub.dev/packages/webview_flutter) — WebKit / Chromium for ordinary HTML mail
- [Drift](https://pub.dev/packages/drift) — SQLite persistence
