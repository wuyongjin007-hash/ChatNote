# Interaction Sounds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Play a local `xiu` sound after successful voice transcription and a local `ding` sound after a capture card is saved successfully.

**Architecture:** Add an injectable interaction sound service backed by `audioplayers`. The service generates two short WAV waveforms in memory, while the voice page depends only on its interface so widget tests can replace playback with an in-memory recorder and business actions remain independent from audio failures.

**Tech Stack:** Flutter, Dart, Riverpod, audioplayers, generated in-memory WAV audio, flutter_test.

## Global Constraints

- Audio must be local and require no network request.
- Playback failure must never block transcription, saving, or UI state updates.
- `xiu` plays only after non-empty voice transcription, before AI organization starts.
- `ding` plays only after a capture has been saved successfully.
- Existing recording, AI, database, conflict, and deletion behavior must remain unchanged.

---

### Task 1: Injectable interaction sound service

**Files:**
- Create: `lib/src/audio/interaction_sound_service.dart`
- Modify: `lib/src/providers.dart`
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `InteractionSoundService.playDing()` and `InteractionSoundService.playXiu()`.
- Produces: `interactionSoundServiceProvider` for UI injection and test overrides.

- [ ] Add `audioplayers`.
- [ ] Add a service that generates local WAV tones, reuses one player, and swallows playback errors.
- [ ] Register the service with Riverpod and dispose it with the provider.

### Task 2: Voice-page sound triggers

**Files:**
- Modify: `test/voice_page_stream_test.dart`
- Modify: `lib/src/features/voice/voice_page.dart`

**Interfaces:**
- Consumes: `interactionSoundServiceProvider`.

- [ ] Add a failing widget test asserting successful voice transcription calls `playXiu()` once.
- [ ] Add a failing widget test asserting successful draft save calls `playDing()` once.
- [ ] Run the focused tests and verify both fail because playback is not wired.
- [ ] Trigger `playXiu()` after a non-empty transcription and `playDing()` after `saveCapture` succeeds.
- [ ] Run focused tests until they pass.

### Task 3: Regression verification

**Files:**
- Verify all modified production and test files.

- [ ] Run `C:\flutter\bin\flutter.bat analyze`.
- [ ] Run `C:\flutter\bin\flutter.bat test`.
- [ ] Run `C:\flutter\bin\flutter.bat build apk --debug --android-skip-build-dependency-validation`.
- [ ] Run `git diff --check` and inspect the final diff.
