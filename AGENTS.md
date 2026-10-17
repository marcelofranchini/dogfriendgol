# AGENTS.md

Project-wide instructions for AI coding agents working in this repository.

<!-- BEGIN superpowers-bootstrap (generated from .github/skills/using-superpowers/SKILL.md - do not edit) -->

<EXTREMELY_IMPORTANT>
You have superpowers.

**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'skill' tool:**

---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are Superpowers' most common process skills, but the rule holds for any of them.

- "Let's build X" → brainstorming first, then implementation skills.
- "Fix this bug" → systematic-debugging first, then domain skills.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## User Instructions

User instructions (AGENTS.md, CLAUDE.md, GEMINI.md, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.

</EXTREMELY_IMPORTANT>

<!-- END superpowers-bootstrap -->

## Tool mapping (OpenCode)

Superpowers skills speak in action language. In OpenCode these map to:

- "Create a todo" / "mark complete" → `todowrite`
- "Dispatch a subagent" → `task` tool with `subagent_type: "general"` (or `"explore"` for codebase exploration)
- "Invoke a skill" → OpenCode's native `skill` tool
- "Read a file" → `read`
- "Create/edit/delete a file" → `apply_patch`
- "Run a shell command" → `bash`
- "Search file contents" / "find files" → `grep`, `glob`
- "Fetch a URL" → `webfetch`

## Spec-Driven Development (Spec Kit)

This project uses Spec Kit. Invoke these as OpenCode commands:

```
/speckit.constitution   Establish project principles (once per project)
/speckit.specify        Create the feature specification
/speckit.clarify        (optional) De-risk ambiguous areas
/speckit.plan           Create the technical implementation plan
/speckit.tasks          Generate dependency-ordered tasks
/speckit.analyze        (optional) Cross-artifact consistency check
/speckit.implement      Execute the tasks
/speckit.converge       Assess codebase vs artifacts, append remaining work
```

Artifacts live under `.specify/` and `specs/`.

## Working with Superpowers

Superpowers skills live in `.agents/skills/` — a cross-runtime location that
both OpenCode and VS Code Copilot Chat read natively (no symlinks). Use the
`skill` tool to list and load them.

The core workflow: **brainstorming → writing-plans → (subagent-driven-development | executing-plans) → test-driven-development → requesting-code-review → finishing-a-development-branch**.

## Execution rule (determined): Spec Kit + Superpowers

When running `/speckit.implement` (or `/speckit-implement`), Superpowers MUST be
used to assist. This is a fixed rule, not optional.

- Spec Kit defines **what** to build (`tasks.md`); Superpowers defines **how**.
- `/speckit.implement` does NOT invoke Superpowers automatically. The agent MUST
  read and apply the relevant skills explicitly during execution.

| Moment | Superpowers skill to invoke |
|---|---|
| Before writing any test code | `test-driven-development` (RED → GREEN) |
| A test fails / unexpected behavior | `systematic-debugging` |
| Before declaring a task complete | `verification-before-completion` (run and show real output) |
| At the end, before merge | `requesting-code-review` |
