# Changelog

All notable changes to this skill are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this skill adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-05-18

### Added

- **Quick config (YAML)** block in Section 0 — drop-in `config.yaml` for agents that read structured config.
- **Compatibility table** in Section 0 — install paths for Claude Code, OpenClaw, ClawHub, Cursor / Copilot CLI, and generic LLM agents.
- **Section 16 — First-run checklist**: 9-item checklist before enabling any cron, plus a bash one-liner to init the 7 memory files.
- **Section 17 — FAQ**: 6 questions (OpenClaw requirement, multi-account, niche subs, shadowban detection, parallel crons, suspension handling).
- `init-memory.sh` script shipped with the GitHub repo — interactive or non-interactive memory dir bootstrap; idempotent.

### Changed

- README badges updated to v1.1.0.

### Unchanged (no breaking changes)

- Sections 1-15 (the core doctrine) are byte-identical to v1.0.0. Existing crons keep working without modification.

## [1.0.0] — 2026-05-18

### Added

- Initial release.
- Three-role mental model (`red-post` / `red-engage` / `red-stealth`) for any Reddit account.
- Karma-phased posting: Phase A (no brand mention until karma ≥ 100) → Phase B.
- Reply qualification rules: age, score, mods, expert-duplicate check, sub freeze state.
- Hard quotas calibrated under spam-filter thresholds (replies/day, posts/week, time-between-actions).
- Anti-spam triggers, both content (banned phrases, single-link rule) and behavioral (no <60s reply, no >3 actions / 30 min).
- Sub state tracking with auto-freeze on repeated removals.
- Full recovery playbook (`status:stopped`, HTTP 429, 403, captcha, shadowban suspicion, automod removals).
- Memory file inventory for stateful agents.
- Mandatory recap pattern (alert channel + memory).
- `install.sh` for one-command install into Claude Code or OpenClaw skills directories.

[1.1.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.1.0
[1.0.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.0.0
