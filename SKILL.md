---
name: reddit-account-operations
description: Operating doctrine for Reddit account automation — careful, helpful, non-spam contributor pattern with role separation, post qualification, quotas, anti-spam triggers and recovery. Use this for any scheduled Reddit activity (cron, agent, recurring task) where account safety, sub-mod tolerance and long-term reputation matter more than raw output.
---

# Reddit Account Operations

This skill is the operating doctrine for every Reddit automation run on a brand, professional or personal account.

**The goal is not to comment fast. The goal is to operate Reddit like a careful, helpful human contributor: stable browser, correct context, useful action, no spam, no reputational risk.**

Drop-in for any niche (legal, medical, software, finance, creator, ecommerce). Replace the placeholders in section 0 with your own values.

---

## 0. Configure for your brand

Before running anything, fill these placeholders in your local copy or your agent's memory:

| Placeholder | Example | Your value |
|---|---|---|
| `<BRAND_NAME>` | "Acme Studio" | — |
| `<BRAND_DOMAIN>` | "acme.studio" | — |
| `<REDDIT_USERNAME>` | "u/AcmeAlex" | — |
| `<BROWSER_PROFILE>` | "reddit-live" | — |
| `<BROWSER_PORT>` | "9223" | — |
| `<NICHE_KEYWORDS>` | "retrait permis OR contester amende" | — |
| `<TARGET_SUBS>` | "r/conseiljuridique, r/AskFrance" | — |
| `<WORKSPACE_DIR>` | "~/.openclaw/workspace/reddit-<brand>" | — |

All shell snippets below assume an [OpenClaw](https://openclaw.ai) browser CLI bound by CDP, but the doctrine works with any browser-automation stack (Playwright, Puppeteer, Chrome MCP). Swap the CLI calls for your own.

---

## 1. Browser architecture

### Physical profile

A single browser profile is used per account:

- `<BROWSER_PROFILE>` (CDP direct, attached to `http://127.0.0.1:<BROWSER_PORT>`)

User data dir: `~/.openclaw-browser-profiles/<BROWSER_PROFILE>`.

Use it through the OpenClaw browser CLI:

```bash
openclaw browser --browser-profile <BROWSER_PROFILE> status
openclaw browser --browser-profile <BROWSER_PROFILE> tabs
openclaw browser --browser-profile <BROWSER_PROFILE> navigate https://www.reddit.com/
openclaw browser --browser-profile <BROWSER_PROFILE> snapshot --limit 160
openclaw browser --browser-profile <BROWSER_PROFILE> click <ref>
openclaw browser --browser-profile <BROWSER_PROFILE> type <ref> "text"
openclaw browser --browser-profile <BROWSER_PROFILE> press Enter
openclaw browser --browser-profile <BROWSER_PROFILE> evaluate --fn "<async function>"
```

`evaluate --fn` is the primary API tool: it runs JS in the active tab and returns the function's value as JSON. Use it for `/api/me.json`, `/api/comment`, `/api/submit`, `/api/selectflair`, `/r/<sub>/rising.json`, `/search.json`.

### Roles (mental separation, single physical profile)

#### Role: `red-post`

Account cockpit. Use for direct account action.

Use for:
- original informative posts (text/self)
- replies on threads
- inbox/notifications check
- profile checks
- karma snapshots
- flair application

Default page: `https://www.reddit.com/user/<REDDIT_USERNAME without u/>`

Mental model: act as the account. Protect it. Do not clutter it.

#### Role: `red-engage`

Search and discovery radar. Use to find what deserves action.

Use for:
- keyword searches across target subs
- monitoring rising/new posts in target subreddits
- finding qualified candidates for replies
- competitor observation
- trend discovery

Default page:
`https://www.reddit.com/search/?q=<NICHE_KEYWORDS_URL_ENCODED>&type=link&t=day&sort=new`

Mental model: discover, qualify, decide. Do not post impulsively from discovery.

#### Role: `red-stealth`

Quiet maintenance bay. Use for low-noise maintenance.

Use for:
- subscribing to relevant subreddits
- saving posts for later study
- reading without interacting
- sub-state observation (flair requirements, karma requirements, mod messages)

Default page: `https://www.reddit.com/`

Mental model: maintain quietly. No noisy engagement.

### Operational law

- `red-post` = act as the account
- `red-engage` = discover what to react to
- `red-stealth` = maintain quietly
- stability matters more than speed
- after every run, navigate back to the role's default page (resting state)

Never collapse all workflows into chaotic browsing.

---

## 2. Login verification (run first on every cron)

```bash
openclaw browser --browser-profile <BROWSER_PROFILE> status
openclaw browser --browser-profile <BROWSER_PROFILE> evaluate --fn "async () => { const d = await (await fetch('/api/me.json',{credentials:'include'})).json(); return {name: d.data?.name || null, link_karma: d.data?.link_karma ?? null, comment_karma: d.data?.comment_karma ?? null, total_karma: d.data?.total_karma ?? null, modhash: !!d.data?.modhash}; }"
```

- If `status` is `stopped`: report the blockage in your recap channel and stop. Do not attempt to relaunch Chrome from inside a cron — that's a user-side action.
- If `name` is `null`: login expired. Stop and report.

---

## 3. Phase gating (karma)

Reddit's spam filters and most sub auto-mods judge new accounts harshly. Run in two phases:

- **Phase A** (karma < 100): only karma-builder + ops crons run. Any brand-mentioning cron must check karma at start and abort with `"phase A, karma=X, skip"` if karma < 100.
- **Phase B** (karma ≥ 100): all crons authorized.

Always read `<WORKSPACE_DIR>/memory/reddit-karma-log.md` at start (last line = current state) AND verify via `/api/me.json`.

A Daily Metrics Recap cron appends a snapshot every night and pings your alert channel explicitly when karma crosses 100 for the first time.

---

## 4. Qualification of a post for reply

A post is repliable only if **all** of:

- Age ≤ 24h (use `created_utc`)
- Comment count < 200
- Score positive (≥ 1, accept controversial-but-genuine)
- Not flagged `removed` or `locked`
- Question is a real question in your domain (not a vent, not a meme, not a request for free work)
- No more than 1 expert-like reply already in top 10 comments (check for domain markers in flairs/body)
- Subreddit is not in freeze state (see `reddit-subs-state.md`)
- Your account has not interacted with this thread before (`reddit-reply-log.md`)
- Phase A: no domain-expert reply at all — only general helpful Phase A comments in Phase A subs.

If any check fails: skip. Document why in the recap.

---

## 5. Reply templates

### Phase A (karma builder, NO brand mention)

- 1-3 sentences, conversational, genuinely helpful
- Match the sub's tone
- Never expert-grade advice (medical, legal, financial)
- Never link to anything
- Never sign with anything that hints at a profession

Example structure:
```
[Direct answer or empathy hook]. [One concrete tip from common sense]. [Soft close optional].
```

### Phase B (brand-aware, expert)

Default mode = **pedagogical**, not promotional.

Structure:
```
[Acknowledge the situation in 1 sentence, neutral tone.]

[General rule / framework in 2-3 sentences. Cite a source only if essential. No promise.]

[Concrete next step the OP can take themselves: deadline, document to gather, official portal, command to run.]

[Optional: if the case is complex, mention that a specialist can review the OP's situation. No brand name in the comment body.]
```

Brand link policy:
- Allowed at most **once per reply**, only as a trailing line: `"I wrote about the procedure here if you want to dig: [link to a relevant blog article]"`
- Link only to a relevant content page on `<BRAND_DOMAIN>` — never the homepage, never a contact page in a reply
- Never link in the same reply that gives personalized advice — split: rule of the field in the body, generic resource in the trailing line
- Never mention the brand by name in the reply text. The username profile already signals it for curious readers.

Forbidden in any reply:
- "Contact me", "DM me", phone numbers, email addresses
- Promises ("you will win", "it's certain", "guaranteed results")
- Quoting specific past client/customer cases
- Asking the OP to DM you

---

## 6. Informative post structure (regular cadence, e.g. Tue + Fri)

Target sub: pick one from `<TARGET_SUBS>` based on:
1. Sub karma requirement satisfied
2. Sub freeze state (skip if frozen)
3. Topic relevance (consult `reddit-ideas.md` and rotate)
4. Last 14 days have NOT seen you post in that sub (cross-check `reddit-post-log.md`)

Format:
```
Title: [Question-form or "Guide:" prefix, ≤ 100 chars]

Body (markdown):
**Context** : [1 paragraph framing the problem people face]

**The rule / framework** : [2-3 paragraphs of plain-language explanation: sources, deadlines, mechanics]

**What to do concretely**:
1. [Action 1]
2. [Action 2]
3. [Action 3]

**Takeaway** : [1 paragraph summary]

---
*For a detailed walkthrough, I wrote a full article here: [link to blog on <BRAND_DOMAIN>]. I don't take case-specific questions in public comments — for a precise situation a 1:1 review works better.*
```

The closing block is the only explicit reference to the brand. Keep it short, factual, no marketing language.

Apply flair if the sub requires one. If no relevant flair exists, skip the sub.

---

## 7. Quotas (hard limits)

| Action | Limit |
|--------|-------|
| Replies / 24h (Phase B) | 3 max |
| Replies / Reply Pass run | 1-2 max |
| Informative posts / week | 2 max |
| Informative posts / day | 1 max |
| Subscribes / week | 5 max |
| Actions in same sub | min 6h apart |
| Actions globally | min 30 min apart |
| Karma builder comments / run | 1-2 max |
| Karma builder comments / day | 3 max |

Quota tracking: read `reddit-reply-log.md` and `reddit-post-log.md` at start of every run, count entries with timestamps in the last 24h / 7d, abort early if quotas already met.

---

## 8. Anti-spam triggers (words and patterns to avoid)

### Comment/post content

| Avoid | Use instead |
|-------|-------------|
| "DM me", "contact me" | (just don't ask) |
| `<BRAND_NAME>` in the comment body | (no brand name in body) |
| "free consultation", "free first call" | (no marketing) |
| Phone number, email | (never) |
| Emojis | (most professional/legal/medical subs are sober) |
| All caps for emphasis | (use italics/bold sparingly) |
| Multiple external links | max 1 link per reply/post |
| bit.ly / shorteners | always use full `<BRAND_DOMAIN>` URL |

### Behavioral triggers

- Same content cross-posted < 7 days apart → spam detection
- ≥ 2 links in a single comment → auto-removed
- New account (karma < 100) posting in large subs → auto-removed
- Replying within 60s of post creation → looks bot-like, wait ≥ 5 min
- Same opening phrase across multiple replies → flagged
- > 3 actions in 30 min → temporary rate limit

---

## 9. Sub state management

File: `<WORKSPACE_DIR>/memory/reddit-subs-state.md`

For each sub, track:
- Last action timestamp (any reply or post)
- Last 5 actions and their outcome (live / removed / locked)
- Karma requirement observed
- Flair required (yes/no/list)
- Freeze state (yes if 2 last actions were removed → unfreeze date = removal date + 7 days)
- Mod messages received (any DM from /r/[sub] mods → flag for human review)

Update at the end of every run that touched the sub.

---

## 10. Recovery & blockers

| Issue | Action |
|-------|--------|
| `status: stopped` | Report in recap: "Chrome <BROWSER_PROFILE> stopped, user action required (relaunch Chrome on port <BROWSER_PORT>)". Stop. |
| `name: null` from /api/me.json | Report login expired. Stop. |
| HTTP 429 | Stop the run, report "rate limited", wait next scheduled run. |
| HTTP 403 on POST | Likely modhash expired — re-fetch from /api/me.json once, retry once. If still 403: report and stop. |
| Captcha / challenge page | Stop. Never attempt to solve. Report for user action. |
| `result.json.errors` contains `RATELIMIT`, `DOMAIN_BANNED`, `BAD_CAPTCHA`, `SUBREDDIT_NOEXIST`, `USER_BLOCKED` | Translate the error in the recap, do not retry, freeze the sub if it's a sub-level error. |
| Comment posted but not visible in user profile after 5 min | Possible shadowban. Flag for human verification (open profile in incognito). |
| Post removed by automod < 30 min after publish | Auto-freeze sub for 7 days. Append to `reddit-learnings.md`. |
| `evaluate` returns null with no error | Page is not on reddit.com → navigate first, retry once. |

---

## 11. Mandatory recap (alert channel + memory)

At the end of each cron:

**Alert channel (Telegram / Slack / Discord) — final run message**:
```
[Job name] — [status: ok|partial|blocked|skipped]
Public actions: [list short OR "no post/reply"]
Links: [URLs of new comments/posts]
Karma: link_karma=X comment_karma=Y total=Z
Blockers: [text OR "—"]
Next action: [1 line]
```

**Memory** — append to `<WORKSPACE_DIR>/memory/reddit-recaps.md`:
```
## YYYY-MM-DD HH:MM TZ — <job-id> — status: <status>
- Job: <description>
- Phase: A|B
- Karma: link=X comment=Y total=Z
- Actions: <list or "no action — reason">
- Subs touched: <list>
- Links: <URLs>
- Blockers: <text or "—">
- Next useful action: <1 line>
```

If no action was taken: say so clearly (`no post/reply/follow/subscribe performed, reason`).

---

## 12. Memory files inventory

Located at: `<WORKSPACE_DIR>/memory/`

| File | Purpose | Update cadence |
|------|---------|----------------|
| `reddit-recaps.md` | Per-run logs (mandatory append) | Every cron run |
| `reddit-post-log.md` | Informative posts (sub, URL, date, score) | Each informative post run |
| `reddit-reply-log.md` | Replies sent (thread URL, comment URL, sub, date, removed?) | Each reply pass |
| `reddit-karma-log.md` | Daily karma snapshot + phase | Daily Metrics Recap |
| `reddit-subs-state.md` | Per-sub freeze, flair, karma req | After any sub-touching action |
| `reddit-ideas.md` | Content backlog for informative posts | Weekly Planning + ad hoc |
| `reddit-learnings.md` | Patterns observed (what got upvoted / removed) | Weekly Planning + ad hoc |

---

## 13. Account identity guardrails

This account exists to be **useful in public** with the brand as a *background* signal.

- The username should be intentionally neutral — do not advertise the brand in the handle
- Profile bio: a short generic line, no firm name, no contact info
- Never reply to a DM that asks for expert-grade advice — direct the person to the brand contact page via a standard polite reply
- Never share private case details, names, or numbers
- Never reuse strict templates from your CRM / case management as Reddit content
- Never promise an outcome
- Never charge or solicit payment via Reddit

If anyone DMs about hiring you: reply once with a neutral line (`"the studio takes inquiries via <BRAND_DOMAIN>/contact"`) and stop.

---

## 14. Phase A → Phase B transition

When the Daily Metrics Recap detects `total_karma ≥ 100`:

1. Append to `reddit-karma-log.md`: `YYYY-MM-DD - karma=X - PHASE_B_THRESHOLD_REACHED`
2. Send a distinct alert: `🎉 Reddit karma ≥ 100 — enable Phase B (jobs.json: keyword-monitor-* + reply-pass-* + informative-post-* + subscribe-growth — flip enabled=true)`
3. Do NOT auto-flip the crons (manual user action — reduces risk of premature B-phase posting)

Once Phase B is enabled by the user:
- First week: 1 reply/day max (not the full 3) — soft ramp
- Keep karma builder running for 2 more weeks in parallel
- Once total_karma ≥ 250: disable karma builder, keep only Phase B crons

---

## 15. Stability discipline

- Read the UI before clicking
- One click → verify with a snapshot
- Do not stack clicks
- Close stale tabs at the end of every run
- Return to the role's default page when done
- Never silently fake a successful action — always verify via API or UI confirmation

**Better silence than spam. Better a blockage report than a fake success.**
