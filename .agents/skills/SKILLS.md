# Skills Index

This file indexes the project-local skills. `.claude/skills/<skill-name>/`
contains thin discovery pointers; canonical content lives under
`.agents/skills/`.

## Project setup

| Skill | Use when |
|---|---|
| [initialize-project](initialize-project/SKILL.md) | The user invokes `/init`, `/init <project-name>`, `$initialize-project`, or asks to initialize a cloned template. |

## Optional `uc-apx`

| Skill | Use when |
|---|---|
| [install-uc-apx](install-uc-apx/SKILL.md) | `INSTALL_UC_APX=true` and the user wants to verify/install the optional CLI and synchronize its upstream skills project-locally. |

The generated uc-apx skill payload is not part of this repository. See the
[optional workflow](../workflows/uc-apx.md) for use and fallback behavior.

## APEX and SQLcl workflows

| Skill | Use when |
|---|---|
| [apex-background](apex-background/SKILL.md) | Writing or debugging APEX PL/SQL in automations, workflow activities, human task actions, or background execution chains (session state, binds, substitutions). |
| [apex-session-context](apex-session-context/SKILL.md) | SQL/PL/SQL outside a normal page request (SQLcl, scheduler job, automation) reads task/workflow views or calls workflow APIs. |
| [apex-workflow-lifecycle](apex-workflow-lifecycle/SKILL.md) | Importing or moving an app with live workflow/task instances, changing automations, diagnosing a missing schedule, or running bulk workflow/task operations. |
| [apexlang-export-debugging](apexlang-export-debugging/SKILL.md) | APEXLANG (.apx) or READABLE_YAML exports fail with ORA-01403 in `WWV_META_META_DATA`. |
| [optimizing-apex-task-inboxes](optimizing-apex-task-inboxes/SKILL.md) | Task inboxes are slow from repeated task API/view calls or task-count/action lookups. |
| [safeguarding-apexlang-text-messages](safeguarding-apexlang-text-messages/SKILL.md) | Localizing, bulk converting, reviewing, or repairing APEXlang `textMessages`. |
| [sqlcl-script-path-debugging](sqlcl-script-path-debugging/SKILL.md) | Nested SQLcl scripts load an unexpected file, or relative SPOOL/include paths misbehave. |

## Browser inspection

| Skill | Use when |
|---|---|
| [chrome-devtools-mcp](chrome-devtools-mcp/SKILL.md) | Inspecting or interacting with a web app through the persistent Chrome DevTools MCP daemon (`tools/chrome_mcp_daemon.py`; see [`docs/CHROME_DEVTOOLS_MCP.md`](../../docs/CHROME_DEVTOOLS_MCP.md)). |

## `sqlcl-mcp-r0/` — SQLcl MCP at restriction level 0

One skill; see [`.agents/skills/sqlcl-mcp-r0/SKILL.md`](sqlcl-mcp-r0/SKILL.md).
Use whenever an agent operates Oracle SQLcl MCP with explicit `-R 0` — SQL,
PL/SQL, SQLcl commands, scripts, filesystem/OS commands, APEX, ORDS, Git,
Liquibase, diagnostics, or client configuration.

## `superpowers/` — general development workflow

Vendored from the [superpowers](https://github.com/obra/superpowers) skill
library (MIT License — see [`superpowers/LICENSE`](superpowers/LICENSE)).
General software-engineering process, not APEX/Oracle-specific. Start with
`using-superpowers`.

| Skill | Use when |
|---|---|
| [using-superpowers](superpowers/using-superpowers/SKILL.md) | Starting any conversation — establishes how to find and use skills before any other action. |
| [brainstorming](superpowers/brainstorming/SKILL.md) | Before any creative work — new features, components, functionality, or behavior changes. |
| [writing-plans](superpowers/writing-plans/SKILL.md) | You have a spec or requirements for a multi-step task, before touching code. |
| [test-driven-development](superpowers/test-driven-development/SKILL.md) | Implementing any feature or bugfix, before writing implementation code. |
| [systematic-debugging](superpowers/systematic-debugging/SKILL.md) | Any bug, test failure, or unexpected behavior, before proposing fixes. |
| [using-git-worktrees](superpowers/using-git-worktrees/SKILL.md) | Starting feature work that needs isolation, or before executing an implementation plan. |
| [executing-plans](superpowers/executing-plans/SKILL.md) | You have a written implementation plan to execute with review checkpoints. |
| [subagent-driven-development](superpowers/subagent-driven-development/SKILL.md) | Executing a plan's independent tasks via fresh subagents in the current session. |
| [dispatching-parallel-agents](superpowers/dispatching-parallel-agents/SKILL.md) | 2+ independent tasks with no shared state or sequential dependency. |
| [requesting-code-review](superpowers/requesting-code-review/SKILL.md) | Completing a task or major feature, or before merging, to verify it meets requirements. |
| [receiving-code-review](superpowers/receiving-code-review/SKILL.md) | Acting on code review feedback — rigor and verification, not reflexive agreement. |
| [verification-before-completion](superpowers/verification-before-completion/SKILL.md) | About to claim work is complete/fixed/passing, before committing or opening a PR. |
| [finishing-a-development-branch](superpowers/finishing-a-development-branch/SKILL.md) | Implementation is done and tests pass — deciding how to integrate the work. |
| [writing-skills](superpowers/writing-skills/SKILL.md) | Creating or editing a skill, or verifying one works before deployment. |
| [diagnosing-superpowers](superpowers/diagnosing-superpowers/SKILL.md) | A superpowers session went wrong (repeated work, ignored plans, skill did not fire) and you need to know why, or want a maintainer bug report. |
