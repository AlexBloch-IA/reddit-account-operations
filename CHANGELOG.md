# Changelog

All notable changes to this skill are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this skill adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/AlexBloch-IA/reddit-account-operations/releases/tag/v1.0.0
