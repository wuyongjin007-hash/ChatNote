# Todo Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make each todo checkbox toggle a persisted completed state and render completed todos with muted, struck-through text.

**Architecture:** Reuse the existing `todos.status` column. Expose status through `EntryListItem`, add a focused update method through DAO/database/repository, and let the todo list refresh after a card toggles its state.

**Tech Stack:** Flutter, Dart, Riverpod, Drift, SQLite, flutter_test.

## Global Constraints

- Do not change the database schema.
- Do not change other page layouts or todo grouping.
- Completion must be reversible.

---

### Task 1: Persist todo completion

- [ ] Add a failing database test for updating and reloading `completed`.
- [ ] Add `status` to `EntryListItem` and todo query mapping.
- [ ] Add `updateTodoStatus(String id, String status)` through DAO, database, and repository.
- [ ] Run the database test.

### Task 2: Toggle and style completed todos

- [ ] Add a failing widget test for toggling, persistence, check icon, muted text, and title strike-through.
- [ ] Refresh the todo list after status changes.
- [ ] Make the checkbox reversible and apply completed styling.
- [ ] Run targeted tests, analyze, all tests, and a debug APK build.
