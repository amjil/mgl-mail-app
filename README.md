# MGL Mail

A cross-platform email client for **Traditional Mongolian** (vertical script). It runs on iOS, Android, macOS, Windows, and Linux, with a mobile shell and a desktop shell that share one mail engine.

The UI is written in [ClojureDart](https://github.com/tensegritics/ClojureDart) on Flutter. Mail sync, storage, and SMTP live in a Dart `mail_core` layer behind a thin ClojureDart wrapper.

## Features

- IMAP sync and SMTP send, with local SQLite (Drift) storage
- Multiple accounts, including Outlook OAuth
- Inbox, Sent, Drafts, Outbox, Archive, Trash, and custom folders
- Search, attachments, read/unread, star, archive, and bulk actions
- Vertical Mongolian layout for reading and composing
- In-app Mongolian virtual keyboard on mobile; desktop IME with FST dictionaries
- Block editor for compose (headings, lists, quotes, attachments)
- Desktop shortcuts: **Cmd/Ctrl+N** compose, **Cmd/Ctrl+F** search, **Cmd/Ctrl+R** sync

## Requirements

- [Clojure CLI](https://clojure.org/guides/install_clojure) (`clj`)
- [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK `>=3.3.1 <4.0.0`)
- Sibling local packages (same parent directory as this repo):
  - `mgl-components`
  - `mongol-vritual-keyboard` (Mongolian virtual keyboard)
  - `mongol-ime` (Mongolian desktop IME)
  - `mgl-ime-core` (IME core / FST)
  - `mgl-block-editor`
  - `mgl-richtext-editor`

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
src/mail_app/          ClojureDart UI (mobile + desktop)
  main.cljd            Entry: bootstrap, MailBridge, then mobile or desktop app
  mobile/              Mobile screens and widgets
  desktop/             Desktop screens, shortcuts, and widgets
  services/            ClojureDart wrappers (mail-core, compose export)
  state/               App store
lib/mail_core/         Dart mail engine (IMAP, SMTP, Drift, OAuth)
assets/                Mongolian fonts and IME dictionaries
```

`mail-app.main` picks the shell from the platform: Android/iOS use the mobile app; macOS/Windows/Linux (and web) use the desktop app.

## Credits

- [suragch/mongol](https://github.com/suragch/mongol) — Mongolian vertical script widgets for Flutter
- [ClojureDart](https://github.com/tensegritics/ClojureDart) — Clojure on Flutter/Dart
- [enough_mail](https://pub.dev/packages/enough_mail) — IMAP/SMTP
