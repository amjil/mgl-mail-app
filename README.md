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
assets/                       Mongolian fonts and IME dictionaries
```

`mail-app.main` picks the shell from the platform: Android/iOS use the mobile app; macOS/Windows/Linux (and web) use the desktop app.

Desktop home is a three-pane shell (folders | list | reading pane) with a draggable folder splitter. Mobile uses a drawer, list, and dedicated detail / settings screens.

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
- [Drift](https://pub.dev/packages/drift) — SQLite persistence
