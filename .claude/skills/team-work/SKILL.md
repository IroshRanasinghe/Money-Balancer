---
name: team-work
description: Run a coding task or project as a coordinated agent team instead of solo - a Tech Lead plans workstreams, Architects design, Developers implement, QA tests, and Reviewers verify, looping fixes until clean. Use when the user asks to run something "as a team", "as a real team", wants an agentic team / tech-lead-led pipeline, wants multiple workstreams built concurrently, or invokes /team-work.
---

# Team Work

Runs a task/project through a real multi-agent team via the `Workflow` tool,
built on top of this repo's `flutter-*` agent types in `.claude/agents/` (the
same ones `flutter-tech-lead` / `flutter-boss-agent` dispatch one at a time),
fanned out **concurrently per workstream** instead of one agent doing
everything sequentially.

**You act as the Tech Lead.** You are not a subagent in this workflow - you
call it, you watch it run, and you own the final report to the user. The
workflow does the planning/design/build/QA/review legwork; synthesizing and
communicating the outcome is your job, not the workflow's.

## Run (agent path)

Calling `Workflow` here is genuine multi-agent orchestration, which normally
requires explicit user opt-in - invoking this skill (by name or via
`/team-work`) **is** that opt-in, so call it directly without asking again:

```
Workflow({
  scriptPath: ".claude/workflows/team-work.js",
  args: { task: "<the full task/project description>", maxRounds: 2 }
})
```

- `args.task` (required) - hand it the user's request verbatim plus any
  context you already gathered (constraints, files involved, acceptance
  criteria). The workflow's Tech Lead-planning step only sees what you put
  here.
- `args.maxRounds` (optional, default `2`) - how many implement -> QA ->
  review loops a single workstream gets before the workflow gives up on it
  and returns the last (failing) verdict for you to handle. Raise it for a
  gnarlier task; the workflow's own internal Tech Lead step is also told to
  keep workstream count small (1-5), so total agent count stays roughly
  `1 + workstreams * (1 + rounds * 3)` - mind this session's workflow-size
  guideline (`/config` shows/raises it).

## What happens inside

1. **Plan** - one agent, playing Tech Lead, reads `args.task` and splits it
   into 1-5 workstreams with non-overlapping file/area scope, each tagged with
   a `kind` (`feature` / `ui` / `layout-fix`). A small task correctly comes
   back as a single workstream - the planner is told not to invent
   parallelism that isn't there.
2. Each workstream then runs **Design -> (Build -> QA -> Review) loop**
   independently, via `pipeline()` - so workstream A can be mid-review while
   workstream B is still being built. No barrier between them.
   - **Design**: `flutter-architect-agent` - plans the approach, doesn't write code.
   - **Build**: picked by the workstream's `kind` - `flutter-feature-developer-agent`
     (`feature`), `flutter-ui-developer-agent` (`ui`), or
     `flutter-layout-fix-agent` (`layout-fix`) - implements (or fixes, on round 2+).
   - **QA**: `flutter-qa-agent` - `flutter analyze`, existing tests, the
     applicable `docs/POS_Order_Flow_Test_Scenarios.md` scenarios, and a
     `run-codezync-pos` Windows run for UI changes (Windows host only). Writes
     new tests only if the task explicitly asks for them; never edits `lib/`.
   - **Review**: `flutter-code-review-agent` - checks correctness, convention-fit,
     and scope creep against this repo's `flutter-code-review` checklist.
   - If QA and Review both pass, the loop stops early; otherwise it retries
     (dev gets the QA/review feedback) up to `maxRounds`.
3. The workflow returns `{ plan, workstreams: [{ workstream, design,
   devSummary, qa, review }, ...], transcript }` - raw structured data, not a
   report. `transcript` is every agent turn in completion order
   (`{ label, agentType, prompt, response }`).

## After the workflow returns

You write the report. Read each workstream's final `qa`/`review` verdict and
tell the user, per workstream: what shipped, whether it's actually
mergeable (`qa.pass && review.pass`), and for anything still failing after
`maxRounds`, what's wrong and what you (Tech Lead) recommend next -
another round, a scope change, or manual follow-up. Don't dump the raw JSON
on the user.

Then write `transcript` into the task's agent log
(`docs/<TICKET-KEY>/<TICKET-KEY>_agent_log.md`, chat-style per `docs/CPK-203/`):
one `## Session N — <date> — team-work: <purpose>` heading, then each entry as
a `**You (dispatching \`<agentType>\`):**` turn with the exact prompt and a
`**\`</agentType>\`:**` turn with the full response, both blockquoted, labelled
with the entry's `label`. Keep the summary doc short and cross-link the log.

## Gotchas

- **All workstreams edit the same working tree by default** - no
  `isolation: 'worktree'` is used, so this mirrors a real team on one shared
  branch, not one branch per person. The Plan step's whole job is preventing
  file-scope collisions between concurrent developers; if a task can't be
  cleanly split that way (e.g. everything touches one shared file), expect
  the planner to correctly fall back to a single workstream. For a large or
  risky project, create a worktree yourself first (`superpowers:using-git-worktrees`)
  and run `/team-work` from inside it rather than relying on per-agent isolation.
- **Agent types are wired by name** in `.claude/workflows/team-work.js`
  (`agentType` on each `run()` call, plus `DEVELOPER_BY_KIND`). Renaming or
  removing a file in `.claude/agents/` breaks the workflow until those names
  are updated too. Only the Plan step runs as a plain agent, since the
  session calling the workflow is the real Tech Lead.
- **Only one reviewer per round** (`flutter-code-review-agent`) to keep agent
  count down. For architecture-heavy work, run `flutter-architect-agent` on
  the final diff yourself after the workflow returns.
- **A workstream that still fails after `maxRounds`** doesn't retry forever -
  the loop returns the last failing `qa`/`review` verdict as-is. That's a
  deliberate cost cap, not a bug; surface it to the user rather than looping
  the whole workflow again blindly.
- **`agent()` calls without `schema` return failed items as `null`** inside
  `pipeline()` - the script already filters and logs how many workstreams
  were dropped outright (as opposed to merely failing review) if that
  happens.
