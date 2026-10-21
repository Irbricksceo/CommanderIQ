# Claude project notes

Use this file as portable working context for Claude instances on different PCs. Keep it in the project and commit/sync it with the rest of the repository so each instance can pick up the same context.

## Project

CommanderIQ is an Android app for logging Magic: The Gathering Commander (EDH) games and using those records to generate statistics and informed feedback.

## Working agreements

- Read `DESIGN_DECISIONS.md` before making product or architecture choices.
- Treat decisions listed as confirmed there as authoritative. Do not silently turn open questions into requirements; ask the user or present options when a choice matters.
- When the user makes a lasting product or technical decision, update `DESIGN_DECISIONS.md` in the same change.
- Keep this file focused on stable project context and collaboration conventions. Put product/architecture decisions in `DESIGN_DECISIONS.md` instead of duplicating them here.
- Avoid machine-specific paths, local environment assumptions, credentials, and other secrets in tracked project notes.
- Before substantial changes, inspect the current project structure and follow its established conventions. Do not assume a framework or stack until it is selected.
- Explain important changes and note any unresolved questions or verification that could not be completed.

## Current status

Implementation has begun with a Flutter/Dart UI prototype in `lib/main.dart`, targeting Android first with iOS as a possible future platform. Android and iOS runner projects have been generated. The prototype covers the home destinations, deck entry, game logging, and optional metric toggles; its data is only held in memory. The persistence package/database, minimum OS versions, and detailed application architecture have not yet been selected.
