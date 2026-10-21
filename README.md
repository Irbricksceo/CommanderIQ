# CommanderIQ

A Flutter app for recording Magic: The Gathering Commander games and learning from your play history. Android is the first target; iOS is a future target.

## Current starter

The first UI pass includes the home dashboard, Decks, Game Records, Insights, Stats, Settings entry point, deck creation, and a Quick Log form. Decks, game records, and metric toggles currently live only in memory and are lost when the app closes. Persistent local storage has not been selected or implemented yet.

## Flutter setup

Install the Flutter SDK and Android Studio (including an Android SDK and emulator or device). Android and iOS runner projects are already included. From this directory, resolve Flutter packages and check the toolchain:

```powershell
flutter pub get
flutter doctor
```

Then run on a connected Android device or emulator:

```powershell
flutter run
```

An iOS build can be generated on macOS with Xcode; iOS is not required for the Android-first initial build.
