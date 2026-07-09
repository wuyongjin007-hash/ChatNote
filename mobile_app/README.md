# Mobile App

Flutter/Dart Android app for local todo and idea capture.

## Data Policy

All app records are stored on the phone in SQLite:

- capture sessions
- entries
- todos
- ideas
- tags
- FTS search index

The app still calls network services directly for:

- Volcengine Ark / Doubao speech understanding
- Volcengine Ark / Doubao text generation for structured extraction

## Android Setup

Install Flutter, then run:

```powershell
flutter pub get
flutter test
flutter build apk --debug
```

Speech recognition now follows the Volcengine Ark Files API flow:

1. Record a temporary local `.m4a` file.
2. Upload it to `POST /api/v3/files` with `purpose=user_data`.
3. Read the returned `file_id`.
4. Call `POST /api/v3/responses` with `input_audio.file_id`.
5. Display the returned text in the app, then send the text to Volcengine Ark Chat Completions for semantic extraction.

The implementation lives in:

```text
lib/src/speech/volcengine_ark_files_client.dart
lib/src/speech/volcengine_speech_service.dart
```
