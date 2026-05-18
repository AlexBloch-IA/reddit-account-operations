# Changelog

All notable changes to this skill are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this skill adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] — 2026-05-18

### Added

- **Section 9 — Human-like posting flow (anti-CAPTCHA)** (new). Documents the reliable path to publish posts through Reddit's reCAPTCHA Enterprise Invisible gate on `/api/submit`. Covers the full flow (pre-flight, navigate, scroll, slow-type title + body, review pause, re-snapshot, click Publish), recommended exit codes, the `LC_NUMERIC` macOS trap that silently disables dwells (`fr_FR.UTF-8` → `0,123` → `sleep` rejects → typing becomes instant → captcha fires), localized UI-label handling, and when to re-test after Reddit UI changes.
- **§3 Manual override (advanced)** sub-section. How to force Phase B before karma ≥ 100 by appending a `phase=B (manual override)` line to `reddit-karma-log.md`, with the risk acknowledgement that auto-freeze on 2 removals still applies.
- README "What's in the box" lists the new v1.2.0 highlights (zero-outgoing-link policy, human-like flow).

### Changed

- **§5 Reply templates — Brand link policy** tightened from "max 1 trailing link" to **ZERO outgoing links to `<BRAND_DOMAIN>` in any reply**. Indirect signaling only. This is the change that, in practice, decides whether your account survives a year on Reddit.
- **§6 Informative post structure — Closing block** rewritten: now an indirect role mention only (no name, no URL, no contact info). The phrase "single brand URL = automod removal in legal/medical/financial subs" added as the rationale.
- **§8 Anti-spam triggers — Comment/post content** table updated: explicit row for "Any URL on `<BRAND_DOMAIN>`" (with subdomains and shorteners) → **never**, in any reply or post. URL shorteners (bit.ly/tinyurl) explicitly banned as Reddit spam-flags them directly.
- Sections 9-17 renumbered to 10-18 to accommodate the new Section 9. Cross-references in §3 and §17 (First-run checklist) updated.

### Unchanged

- Sections 0, 1, 2, 4, 7 (Quick config YAML, Browser architecture, Login verification, Reply qualification, Quotas) are byte-identical to v1.1.0.
- The doctrine's core (3 roles, phased karma posting, hard quotas, recovery patterns, memory files, mandatory recap) is unchanged.

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

[1.2.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.2.0
[1.1.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.1.0
[1.0.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.0.0
