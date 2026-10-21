# CommanderIQ — Design Decisions

This document is the source of truth for product and technical decisions. Keep confirmed decisions separate from open questions; update it when a decision is made.

## Product overview

CommanderIQ is an Android app for logging games of Magic: The Gathering Commander (EDH). It will use those records to generate statistics and informed feedback.

## Confirmed decisions

| Area | Decision | Notes |
|---|---|---|
| Platform | Build with Flutter and Dart, targeting Android first and keeping iOS as a future platform | Flutter was chosen despite the initial Dart learning curve; use a shared cross-platform codebase. Android and iOS runner projects are generated; minimum supported OS versions are not yet chosen. |
| Game format | Magic: The Gathering Commander (EDH) | The app records games played in this format. |
| Core purpose | Record games and derive stats and informed feedback | Detailed data model, analytics, and feedback scope remain open. |
| Storage | Local storage only for the first version | Cloud-synced storage is not planned for now and may be reconsidered later. |
| Home navigation | Provide destinations for Decks, Game Records, Insights, and Stats, plus a general Settings button | The home screen also has a Quick Log action that opens the game logging screen directly. |
| Deck management | Users can create and maintain decks with at least a deck name, commander, and bracket | Additional deck information may be included; exact fields remain open. |
| Game logging | A game record selects one of the user's decks and records game details | Deck selection is a dropdown ordered by most recently played by default. |
| Core game fields | Win/Loss, Date, Game Bracket, and Turns | These are the default/core fields for a game record. Turns is listed only once, despite also appearing in the optional-field list in the initial proposal. |
| Optional game metrics | Had Fun, Venue, and Seat Position are available out of the box and can be enabled or disabled | Users can also create custom metrics. Metric configuration and custom metric creation belong in Stats. |
| Venue entry | Venue selection offers previously used venues and an option to add a new venue | Exact venue data and editing behavior remain open. |

## Open questions

- Which additional deck details and game details should be supported (such as notes or other participants)?
- How should user-created metrics be defined, entered during logging, edited, and represented in reports?
- How should decks that have never been played be ordered in the deck picker?
- Is the app single-player/private, or should multiple players share records?
- What statistics and feedback are useful, and how should uncertainty or small sample sizes be communicated?
- Which persistence approach, minimum supported OS versions, and application architecture should be used?
- What local backup, export/import, privacy, and account requirements should apply?
- What visual identity and accessibility requirements should guide the UI?

## Decision log

Add newest decisions first. Include the date, decision, and a brief reason; capture significant trade-offs where useful.

| Date | Decision | Reason / trade-offs |
|---|---|---|
| 2026-10-20 | Begin implementation with a Flutter UI prototype for the agreed home destinations, deck entry, game logging, and metric toggles | Validate the mobile navigation and first-pass workflow before selecting a persistent local database; prototype data is temporary in-memory state. |
| 2026-10-20 | Use Flutter with Dart, targeting Android first while keeping iOS as a future platform | Provides a shared cross-platform app codebase; the user is willing to learn Dart. |
| 2026-10-20 | First-pass product structure: local-only Android app with four home destinations, Quick Log, deck management, core and configurable game metrics, and reusable venue selection | Establishes the initial navigation and logging model while leaving implementation choices and unspecified field details open. |
