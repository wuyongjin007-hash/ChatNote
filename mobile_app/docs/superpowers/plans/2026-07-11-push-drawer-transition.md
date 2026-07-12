# Push Drawer Transition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the overlay drawer and route fade-slide with a Doubao-style drawer that pushes and fades the current page, then rapidly retracts before navigation.

**Architecture:** `_AppShell` owns one animation controller and renders the drawer and page in a `Stack`. A small inherited scope exposes `openDrawer()` to page headers. Drawer destinations call a shell callback that closes the animation before changing the `go_router` location.

**Tech Stack:** Flutter, Dart, go_router, flutter_test

## Global Constraints

- Do not change voice, todo, idea, database, or AI behavior.
- Keep the current warm color palette and drawer content.
- Opening takes about 260 ms; closing/navigation takes about 170 ms.
- Remove the old per-route fade and slide transition.

---

### Task 1: Lock the drawer motion in widget tests

**Files:**
- Modify: `test/app_shell_test.dart`

**Interfaces:**
- Consumes: `IdeaCaptureApp`, `app-drawer-menu-button`, and drawer destination keys.
- Produces: assertions for `app-pushed-content`, `app-content-fade-overlay`, and close-before-navigation behavior.

- [ ] Add a widget test that opens the drawer, advances the animation, and asserts the page moves right while the fade overlay appears.
- [ ] Add a widget test that taps a destination and asserts the drawer closes before the target route is visible.
- [ ] Run `C:\flutter\bin\flutter.bat test test\app_shell_test.dart` and confirm the new assertions fail because the push shell does not exist.

### Task 2: Implement the push drawer shell

**Files:**
- Create: `lib/src/widgets/app_drawer_scope.dart`
- Modify: `lib/src/widgets/page_header.dart`
- Modify: `lib/src/app.dart`

**Interfaces:**
- Consumes: `AppDrawerScope.open(context)` from `PageHeader`.
- Produces: `_AppShellState.openDrawer()`, `_AppShellState.closeDrawer()`, and close-before-navigation destination handling.

- [ ] Add an inherited scope that exposes the shell open callback.
- [ ] Change `PageHeader` to invoke the scope instead of `Scaffold.openDrawer()`.
- [ ] Convert `_AppShell` to a stateful animated `Stack` with sliding drawer, translated content, fade overlay, tap-to-close barrier, and guarded destination navigation.
- [ ] Replace `CustomTransitionPage` routes with `NoTransitionPage` so the shell animation is the only transition.
- [ ] Run `C:\flutter\bin\flutter.bat test test\app_shell_test.dart` and confirm all shell tests pass.

### Task 3: Regression verification

**Files:**
- Verify only.

**Interfaces:**
- Consumes: completed app shell.
- Produces: analyzer, test, and Android debug build evidence.

- [ ] Run `C:\flutter\bin\flutter.bat analyze`.
- [ ] Run `C:\flutter\bin\flutter.bat test`.
- [ ] Run `C:\flutter\bin\flutter.bat build apk --debug --android-skip-build-dependency-validation`.
