# AI Voice Idea Capture

Android-first local idea and todo capture app.

## Structure

- `mobile_app/` - Flutter/Dart Android client. Data lives in local SQLite.
There is no relay service in the personal-use build. API keys are stored locally on the phone through secure storage.

## MVP Flow

1. Android app records speech as a temporary local audio file.
2. The app uploads the audio through Volcengine Ark Files API and receives a `file_id`.
3. The app calls Volcengine Ark Responses API with `input_audio.file_id` and displays the returned text.
4. Speech text is sent to Volcengine Ark Chat Completions for structured todo/idea extraction.
5. The app asks follow-up questions when required fields are missing.
6. Confirmed todos and ideas are stored in local SQLite only.
7. Todo conflicts are detected locally before save.

## Local Development

The current machine does not have the Flutter/Dart SDK on `PATH`, so Flutter build/test commands require installing Flutter first.

Flutter app, after installing Flutter:

```powershell
cd mobile_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --debug
```
