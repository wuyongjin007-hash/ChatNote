# Qwen2.5 Local NLU Replacement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Qwen3.5 local voice-recording NLU artifact with the smaller Qwen2.5 0.5B Q4_K_M artifact and remove retired Qwen3.5 files on upgrade.

**Architecture:** Keep one `LocalModelKind.nlu` catalogue slot. Point it at the immutable ModelScope Qwen2.5 artifact and delete only the known retired Qwen3.5 directory during model-manager initialization. Keep the native bridge and JSON interpreter, while generating Qwen2.5-standard ChatML without Qwen3.5 thinking tags.

**Tech Stack:** Flutter/Dart, `path_provider`, `http`, `crypto`, llama.cpp JNI, `flutter_test`.

## Global Constraints

- NLU file: `qwen2.5-0.5b-instruct-q4_k_m.gguf`.
- Revision: `2e50b77b0eee3083842019e257b74854323d880a`.
- Size: `491400032` bytes.
- SHA-256: `74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db`.
- Android remains completely offline after model download.
- Do not alter the ASR, VAD, SQLite, or cloud intelligent-recording paths.

---

### Task 1: Lock the replacement model and retire the old directory

**Files:**
- Modify: `lib/src/local_ai/local_model_manager.dart`
- Test: `test/local_model_catalog_test.dart`

**Interfaces:**
- Produces: `LocalModelCatalog.qwen` describing Qwen2.5 and `LocalModelCatalog.retiredNluModelIds` listing only `qwen3-5-0-8b-q4-k-m`.

- [ ] **Step 1: Write failing catalogue assertions**

```dart
expect(nlu.id, 'qwen2-5-0-5b-instruct-q4-k-m');
expect(nlu.fileName, 'qwen2.5-0.5b-instruct-q4_k_m.gguf');
expect(nlu.bytes, 491400032);
expect(nlu.sha256, '74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db');
expect(LocalModelCatalog.retiredNluModelIds, ['qwen3-5-0-8b-q4-k-m']);
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/local_model_catalog_test.dart`
Expected: FAIL because the catalogue still contains Qwen3.5 metadata.

- [ ] **Step 3: Implement the locked model and cleanup**

```dart
static const retiredNluModelIds = ['qwen3-5-0-8b-q4-k-m'];

Future<void> _removeRetiredNluModels(Directory root) async {
  for (final id in LocalModelCatalog.retiredNluModelIds) {
    final directory = Directory(p.join(root.path, 'local_models', id));
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
```

Call the cleanup before enumerating the active catalogue in `initialize()`, then replace the active Qwen spec with the locked Qwen2.5 URL, revision, size and digest.

- [ ] **Step 4: Run the catalogue test to verify it passes**

Run: `flutter test test/local_model_catalog_test.dart`
Expected: PASS.

### Task 2: Use Qwen2.5 ChatML for local structured capture

**Files:**
- Modify: `lib/src/local_ai/local_voice_runtime.dart`
- Test: `test/local_voice_runtime_test.dart`

**Interfaces:**
- Consumes: `LocalCaptureInterpreter._prompt(String, DateTime, {bool retry})`.
- Produces: a `system -> user -> assistant` ChatML prompt with no `<think>` tags.

- [ ] **Step 1: Change the existing prompt assertion**

```dart
expect(generator.prompts.first, contains('<|im_start|>assistant\n'));
expect(generator.prompts.first, isNot(contains('<think>')));
```

- [ ] **Step 2: Run the prompt test to verify it fails**

Run: `flutter test test/local_voice_runtime_test.dart --plain-name "formats Qwen local capture prompts with thinking disabled"`
Expected: FAIL because the Qwen3.5 `<think>` content is present.

- [ ] **Step 3: Remove the Qwen3.5-only completion prefix**

```dart
<|im_start|>assistant
''';
```

Leave JSON requirements, retry instruction, amount normalization, and native invocation unchanged.

- [ ] **Step 4: Run the prompt and parser tests to verify they pass**

Run: `flutter test test/local_voice_runtime_test.dart`
Expected: PASS.

### Task 3: Validate the package

**Files:**
- Modify: none

**Interfaces:**
- Consumes: updated Dart catalogue and prompt.
- Produces: a debug APK that includes the same native runtime and downloads Qwen2.5 at runtime.

- [ ] **Step 1: Format changed Dart files**

Run: `dart format lib/src/local_ai/local_model_manager.dart lib/src/local_ai/local_voice_runtime.dart test/local_model_catalog_test.dart test/local_voice_runtime_test.dart`
Expected: formatter completes without errors.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: no analyzer issues.

- [ ] **Step 3: Run the complete test suite**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 4: Build the Android debug APK**

Run: `flutter build apk --debug`
Expected: `build/app/outputs/flutter-apk/app-debug.apk` is produced successfully.
