# Idea Swipe Delete Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users reveal a delete action by swiping an idea card left and remove the idea immediately after tapping it.

**Architecture:** Use `flutter_slidable` for reliable horizontal gesture handling inside the vertically scrolling idea list. Keep deletion in `EntryRepository`, then reload the current fuzzy-search result after SQLite deletion completes.

**Tech Stack:** Flutter, Dart, Riverpod, Drift/SQLite, flutter_slidable, flutter_test.

## Global Constraints

- Swipe the idea card left to reveal a right-side red circular trash action.
- Delete only after the trash action is tapped; swiping alone must not delete.
- After deletion, the card disappears immediately with no snackbar, confirmation, or undo.
- Do not change idea search, tags, card content, or todo behavior.

---

### Task 1: Swipe action and deletion flow

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/src/data/entry_repository.dart`
- Modify: `lib/src/features/query/query_page.dart`
- Modify: `test/idea_page_test.dart`

**Interfaces:**
- Produces: `EntryRepository.deleteIdea(String id)`.
- Consumes: existing `AppDatabase.deleteEntry(String id)` and `searchIdeas(String query)`.

- [ ] Add `flutter_slidable`.
- [ ] Write a failing widget test that swipes one idea, taps its delete action, and verifies only that idea is removed from SQLite and the list.
- [ ] Run the focused test and verify it fails because no delete action exists.
- [ ] Add `EntryRepository.deleteIdea` and convert `_IdeaList` to stateful loading so it can refresh after deletion.
- [ ] Wrap each card in `Slidable` with one red circular trash action.
- [ ] Run focused and full tests.

### Task 2: Android verification

**Files:**
- Verify all modified files.

- [ ] Run `C:\flutter\bin\flutter.bat analyze`.
- [ ] Run `C:\flutter\bin\flutter.bat test`.
- [ ] Run `C:\flutter\bin\flutter.bat build apk --debug --android-skip-build-dependency-validation`.
- [ ] Run `git diff --check` and inspect the final diff.
