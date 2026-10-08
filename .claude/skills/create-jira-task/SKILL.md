---
name: create-jira-task
description: Use when the user describes a scenario, bug, feature, or piece of work and asks to create, file, log, or raise a Jira ticket/task/issue/bug for it — before calling any Atlassian MCP issue-creation tool.
---

# Create Jira Task

## Overview

Turns a described scenario or task into a well-formed Jira issue via the Atlassian MCP tools.
Core risk: fabricating project keys, issue types, or fields that were never confirmed against the
real Jira instance — always discover them live, never guess.

## When to Use

- User says "create a Jira ticket for X", "log a bug about Y", "file a task for Z", or pastes a bug
  report / feature idea and asks it to be tracked.
- NOT for updating/transitioning an existing ticket (use `editJiraIssue` / `transitionJiraIssue`
  directly) and NOT for turning an *existing* ticket into implementation work (that's the reverse
  direction — see the `flutter-create-task` skill).

## Workflow

1. **Resolve access.** If Atlassian MCP tools aren't available/authorized, tell the user to connect
   it via claude.ai connector settings and stop. Never fabricate a ticket without live tool access.

2. **Resolve the project.** If the user didn't name a project (key or name), call
   `getVisibleJiraProjects` and ask which one applies — don't assume or reuse a project key from a
   past conversation without confirming it still matches.

3. **Resolve the issue type.** Call `getJiraProjectIssueTypesMetadata` for that project. Infer a
   reasonable default from the scenario (bug report → Bug, new capability → Task/Story) but if it's
   genuinely ambiguous, ask rather than guess.

4. **Check required fields.** Call `getJiraIssueTypeMetaWithFields` for the chosen project + issue
   type. Custom/required fields (e.g. epic link, story points, custom dropdowns) vary per project —
   don't submit a payload missing a field the schema marks required, and don't invent values for
   fields the scenario doesn't speak to.

5. **Check for duplicates (when it's cheap to).** If the scenario resembles something that might
   already be tracked, a quick `searchJiraIssuesUsingJql` is worth it. If a likely duplicate turns
   up, surface it and confirm with the user before creating a new issue anyway.

6. **Draft the issue** from the scenario, don't just paste it verbatim:
   - **Summary**: short, specific, imperative (e.g. "Cart total doesn't update after item removed
     offline"), not the full scenario text.
   - **Description**: structured — context/problem, expected vs. actual (for bugs) or goal (for
     tasks/stories), acceptance criteria if the scenario implies clear done-conditions. Don't invent
     acceptance criteria the scenario doesn't support.
   - **Assignee**: only set if the user named someone — resolve name/email to an account ID with
     `lookupJiraAccountId` first; never guess an account ID.
   - **Priority/labels/epic link**: only set what the user specified or what's unambiguous from
     context; leave the rest to Jira defaults.
   - If the scenario actually describes several distinct pieces of work, ask whether the user wants
     one issue or several before splitting.

7. **Confirm before creating.** Creating a Jira issue is a visible, shared-system action. Show the
   drafted summary/description/type/project as a short preview and get explicit confirmation before
   calling `createJiraIssue` — unless the user's own message already gave explicit go-ahead to just
   create it (e.g. "just create the ticket, don't ask").

8. **Create and report back.** Call `createJiraIssue`. Report the resulting issue key and a link back
   to the user. If the user mentioned this relates to/blocks another issue, offer `createIssueLink`
   (check `getIssueLinkTypes` for the right link type) rather than assuming "relates to".

## Quick Reference — Atlassian MCP tools

| Tool | Purpose |
|---|---|
| `getVisibleJiraProjects` | List projects the user can file into — resolve project key |
| `getJiraProjectIssueTypesMetadata` | List valid issue types for a project |
| `getJiraIssueTypeMetaWithFields` | Get required/available fields for a project+issue-type pair |
| `lookupJiraAccountId` | Resolve a name/email to an account ID before setting assignee |
| `searchJiraIssuesUsingJql` | Check for likely duplicates before filing |
| `createJiraIssue` | Create the issue once fields are confirmed |
| `createIssueLink` / `getIssueLinkTypes` | Link the new issue to a related one |
| `addCommentToJiraIssue` | Add extra context after creation if the user provides more later |

## Common Mistakes

- Guessing a project key or issue type instead of calling the discovery tools — breaks silently if
  the project's scheme differs from what was assumed.
- Pasting the user's raw scenario text as the summary instead of writing a concise title.
- Setting assignee/priority/labels the user never mentioned.
- Creating the issue without a confirmation step when the user only *described* a scenario and
  didn't explicitly say to go ahead and file it.
- Treating a multi-part scenario as one issue without checking whether it should be split.
