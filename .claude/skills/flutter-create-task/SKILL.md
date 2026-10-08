---
name: flutter-create-task
description: Kick off Flutter development from a Jira ticket in the CPK project (https://codezync.atlassian.net/jira/software/c/projects/CPK/boards/90). Given a ticket key or URL, retrieve its details, work out the branch situation, identify which lib/features/ areas it touches, and load implementation context grounded in this repo's Clean Architecture + BLoC conventions. Use when the user says "start task CPK-23", "work on this Jira ticket", "create task for this ticket", or pastes a codezync.atlassian.net Jira issue and wants to begin Flutter work.
---

# Flutter Task Kickoff (CodeZync POS)

Turn a Jira ticket into a ready-to-implement Flutter session: ticket understood,
branch situation resolved, affected feature(s) identified, and project-specific
risks surfaced before any code gets written.

## Role

Approach every ticket as a **senior Flutter architect**, not just an implementer
— and hold that framing for the rest of the session, not just this kickoff:

- **Analysis**: Don't stop at restating the ticket. Work out what it implies for
  this project's Clean Architecture (domain -> data -> presentation) and
  `flutter_bloc` stack — which feature(s) under `lib/features/` it touches, which
  layer owns the change, and any offline/sync/DI implications — before the user
  has to ask.
- **Communication**: Brief like you're talking to another engineer who already
  knows this codebase — lead with the tradeoff and the affected files, not a
  tutorial on Clean Architecture. Stay concise.
- **Coding standards**: Anything touched for this ticket follows `CLAUDE.md` and
  the project's other skills (`flutter-clear-architecture`,
  `flutter-networking-errors`, `flutter-offline-sync`, `flutter-bloc-discipline`,
  `flutter-routing-auth`, `flutter-design-system`, `flutter-testing-strategy`,
  `flutter-di-bootstrap`) — this Role section adds architectural framing on top,
  it doesn't replace them.

## Workflow

### 1. Retrieve the ticket

- Extract the ticket key from the input (parse it out of a URL like
  `https://codezync.atlassian.net/browse/CPK-23` if needed). This project's live
  Jira project is **CPK**, tracked on
  [board 90](https://codezync.atlassian.net/jira/software/c/projects/CPK/boards/90).
  You may still see older `COPO-*` and `INT-97` keys in git history — those are
  from before the project was renamed/consolidated to CPK; don't create new work
  under those keys.
- Use the Atlassian MCP tools to retrieve the full issue: call
  `getAccessibleAtlassianResources` first if the cloudId for `codezync.atlassian.net`
  isn't already known this session, then `getJiraIssue`. Collect key, title, type,
  description, acceptance criteria, status, priority, assignee, epic, linked
  issues, attachments, and design links.
- If the Atlassian MCP isn't authorized in this session, tell the user it needs
  to be connected via their claude.ai connector settings (or `/mcp`), and stop.
  Do not invent ticket content.
- If the issue can't be found, ask the user to confirm the key.

### 2. Resolve the branch situation

- Run `git status` and `git log --oneline -15` first.
- This repo does **not** use per-ticket branches. History shows long-lived,
  descriptively-named dev branches (`dev-refector+pairing+login`, `dev+responsive`,
  `dev+nuwan`, `dev-UIUpdateV2+firebse`, etc.) with commits for many different
  ticket keys landing directly on whichever branch is currently active — there is
  no `CPK-23`-style branch anywhere in history.
- **Default to working directly on the current branch.** Do not create a new
  branch for this ticket unless the user explicitly asks for one.
- If uncommitted changes are present, report them and ask whether to carry them
  over, stash them, or stop, before doing anything else — don't assume they're
  unrelated to this ticket.
- `main` is the base/release branch (`origin/HEAD -> origin/main`); everything
  else is a working branch. If the user asks for a dedicated branch, there's no
  established ticket-key naming convention to follow (existing branch names are
  free-form) — ask what name they want rather than inventing one.

### 3. Confirm the project and affected feature(s)

- This is the CodeZync POS Flutter app (offline-first restaurant/retail POS,
  Android/iOS primary, landscape-locked). Confirm the working directory looks
  right (`pubspec.yaml` with `name: codezync_pos`) rather than searching for
  other repos.
- Match the ticket's description/acceptance criteria against
  `lib/features/<feature>/` (e.g. `cashier`, `session`, `Orders`, `menu`, `cart`,
  `table`, `terminal`, `auth`, `login`, `item_customization`, `payment_details_panel`,
  `receipt`, `user`, `location`, `assign_a_waiter`, `change_table`, `coins`,
  `navigation_drawer`, `appbar`) or a `lib/core/` concern (`network`, `database`,
  `hive_storage`, `storage`, `sync`, `router`, `di`, `error`, `design_system`,
  `permissions`).
- If the ticket is genuinely new functionality with no existing feature match,
  say so explicitly — don't force it into an unrelated existing feature folder.

### 4. Load implementation context

Summarize the ticket for the session (title, type, description, acceptance
criteria, priority, status, links, dependencies), then assess it against this
project's real stack — **Flutter, Clean Architecture per feature
(`domain`/`data`/`presentation`), `flutter_bloc`, `dartz` `Either<Failure, T>`,
`get_it` DI, `go_router`, Dio, sqflite/Hive/flutter_secure_storage**. This is not
a native Android/Java project — don't frame anything in Gradle/Dagger/RxJava/MVVM
terms.

- Identify the layer(s) the ticket touches: a new/changed entity, use case,
  repository, datasource, BLoC event/state, screen, or DI/routing wiring. Load
  `flutter-clear-architecture` for the concrete pattern to follow.
- Check existing entities/use cases/repositories/BLoCs in the target feature
  before proposing new ones — and check the *sibling* feature's directory
  naming (`repository` vs `repositories`, `usecase` vs `usecases`) since this
  repo is not internally consistent on that.
- Pull in the relevant deeper skill based on what the ticket touches: a new API
  call or error case -> `flutter-networking-errors`; anything cache/queue/
  connectivity-related -> `flutter-offline-sync`; a new screen or rapid-fire UI
  events -> `flutter-bloc-discipline`; a new route or anything terminal-pairing/
  login-related -> `flutter-routing-auth`; new UI/dialogs/colors ->
  `flutter-design-system`; wiring a new class into GetIt or app bootstrap ->
  `flutter-di-bootstrap`; adding tests -> `flutter-testing-strategy`.
- Call out project-specific concerns that are relevant: offline behavior (this
  app must keep working without connectivity — does this ticket need a local
  cache or pending-write queue?), landscape-locked tablet/phone layout, terminal
  pairing/session-token state, and whether the change affects the
  `features/auth` vs `features/login` (PIN re-auth) split.
- For UI tickets, identify states to design: loading, loaded, empty, error, and
  BLoC event -> state mapping. For data work, identify source(s) of truth and
  offline fallback behavior.
- State the main tradeoffs and open questions concisely. Do not begin
  implementation until enough context exists to make a sound change.

### 5. Establish the implementation baseline

- Use standard Flutter tooling — there's no custom build/CI script in this repo:
  `flutter pub get`, `flutter analyze`, `flutter test` (or `flutter test
  test/widget_test.dart` for the one existing test), `dart format lib`.
- Note `.env` prerequisites if the ticket touches networking (`BASE_URL`,
  `AUTH_URL`, `S3_BUCKET_NAME`, `S3_REGION` — file isn't committed, don't expose
  its contents).
- Before declaring the work complete: run `flutter analyze` (and `flutter test`
  if relevant tests exist/were added), and use the commit convention
  `[CPK-XX] [FR] <verb>: <subject>` (e.g. `[CPK-23] [FR] feat: ...`,
  `[CPK-23] [FR] fix: ...`) — **every commit in this repo's history uses the
  `[FR]` tag**, regardless of whether the change is a feature, fix, or refactor
  (the verb after the colon carries that distinction, e.g. `feat:`/`fix:`/
  `refactor:`). There's no precedent for a `[BF]` or `[DOC]` tag here — if the
  user wants a different tag for a bug ticket, confirm with them rather than
  inventing one that doesn't match this repo's actual history.
- Confirm the Jira ticket has been updated with status/comment as appropriate.

### 6. Standing reminders

At the end of this kickoff, explicitly tell the user the two standing rules
below apply for the rest of the task — don't just leave them implicit:

- No `git commit`/`git push` will happen without an explicit ask each time.
- Before the task is considered done, the Jira ticket's status/comments should
  be confirmed updated — flag it if it hasn't been.

## Standing Rules

- Keep the work scoped to the ticket and match this repo's existing Clean
  Architecture + `flutter_bloc` conventions — don't introduce a different state
  management approach or bypass the use-case/repository layering documented in
  `flutter-clear-architecture`.
- Apply SOLID/DRY/YAGNI pragmatically; favor clear, testable code over
  speculative generalization.
- Never commit or push without an explicit request each time — this matters
  more than usual here, since work defaults to landing directly on a shared
  working branch rather than an isolated per-ticket branch.
