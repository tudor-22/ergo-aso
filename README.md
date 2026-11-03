# Ergo ASO

**Full-funnel App Store Optimization for iOS apps, as an OpenAI Codex skill.**

Developed by [Tudor Iustin](https://tudoriustin.com).

Built for [OpenAI Codex](https://developers.openai.com/codex), with
Codex-native setup and install and a translation engine that runs on Codex
itself.

It takes an iOS app from "ready to submit" to a fully optimized, fully
localized App Store presence, end to end:

1. **Keyword research** — popularity/difficulty-driven, intent-matched, per
   market. Decides what your name, subtitle, and keyword field say.
2. **Store metadata in up to 50 locales** — keyword-led name and subtitle,
   adapted (never invented) keyword fields, descriptions that translate by
   meaning. Reviewed by automated checks, not by eye.
3. **Localized screenshots** — your background mockups plus translated
   headings burned in by a bundled renderer (Playwright + per-script Noto
   fonts, RTL handled, auto-fit).
4. **Worldwide pricing** — pick a model (uniform, GNI bands, Big Mac index,
   Netflix index) and it's applied per territory via the App Store Connect
   API, with read-back verification.
5. **In-app localization** — your actual UI strings, translated with a
   detector suite that catches the bugs fluent output hides (format-specifier
   drift, wrong-sense domain words, script contamination, register drift).
6. **Submission checklist** — every field the App Store Connect API can set
   gets set and verified; everything it can't becomes an explicit
   manual-steps list instead of a silent gap.

No signup, no SaaS. You bring your own App Store Connect API key, and
translations run on Codex by default (or your own DeepSeek / OpenAI-compatible
key if you prefer).

## Install

Clone the repo and run the installer:

```bash
git clone https://github.com/tudor-22/ergo-aso
cd ergo-aso
./install.sh
```

This copies the skill to `~/.agents/skills/ergo-aso`, where Codex discovers
user-level skills. Restart Codex (or open a new session) afterwards.

Other install targets:

```bash
./install.sh --project            # only the current project: ./.agents/skills/ergo-aso
./install.sh --dest ~/my-skills   # any skills directory
```

Re-running `./install.sh` updates an existing install in place and keeps any
renderer dependencies and fonts you've already downloaded.

### As a Codex plugin

The repo is also a Codex plugin marketplace
(`.agents/plugins/marketplace.json` → `plugins/ergo-aso`). Add the repo as a
marketplace from Codex's plugin settings, then enable **Ergo ASO**.

## Use

Open Codex in your app's repo and say what you want:

```
do the ASO for my app
```

…or any slice of it: "find keywords for my calorie tracker", "localize my App
Store page", "localize my screenshots", "set worldwide prices", "localize the
app itself", "get my listing ready for submission". Codex loads the skill on
its own from the description; you can also invoke it explicitly with
`$ergo-aso`.

First run walks you through a short setup wizard:

- **App Store Connect API key** (App Store Connect → Users and Access →
  Integrations → Team Keys). Stored in `~/.ergo-aso/`, chmod 600, never in a
  repo, never printed.
- **Translation engine** — Codex itself (default, zero setup), DeepSeek, or
  any OpenAI-compatible API.
- **Keyword data source** — an ASO tool with popularity/difficulty data
  (Astro's MCP is the best-supported; add it with `codex mcp add`), or an
  honest degraded mode without one.

## Screenshot mockups

Bring your own App Store screenshot backgrounds, designed in any tool:

1. Put your app screenshots inside device frames (iPhone, iPad, Apple Watch).
2. Pick your background colors; leave the top band empty — the renderer burns
   the localized heading there.
3. Export each frame as PNG named `iphone_1..N.png` / `ipad_1..N.png` into
   your project folder, and the screenshots phase takes it from there.

## Requirements

Nothing up front — each phase checks its own prerequisites
(`scripts/check_setup.sh` prints exactly what's missing and the fix command),
and you only need the tools for the phases you actually use:

| You want | You need |
|---|---|
| Keyword research | nothing (an ASO data tool with popularity/difficulty makes it much stronger) |
| Metadata generation | nothing |
| Metadata / screenshot upload | `fastlane` ≥ 2.234.0 (`brew install fastlane`) |
| Screenshot rendering | `node` — one-time `npm install`, `npx playwright install chromium`, ~55 MB font download |
| Pricing + submission checklist | `ruby` (ships with macOS) |
| In-app localization | Xcode command-line tools — it rebuilds your app to verify translations |

Assumes macOS, which is where iOS apps get built anyway. Upload goes through
fastlane because it's the community standard — but the skill writes plain
`fastlane/metadata/<locale>/` layout files, so if you deliver with something
else, everything up to the upload step still works as-is.

Codex needs permission to run shell commands and reach the network for the
App Store Connect API and the one-time renderer setup; approve those when
prompted, or run in a mode that allows them.

## What it costs

Nothing beyond what you already pay for Codex, and — only if you choose the
DeepSeek engine — roughly **$0.50 per app** for a full ~400-string × 40-locale
in-app cascade. The App Store Connect API is free.

## Design principles

- **Fan out, then verify.** Every localization pass covers all chosen locales
  at once and is reviewed by automated detectors plus targeted spot-checks. A
  human can't review 40 languages, and reviewing one proves nothing about the
  other 39.
- **Read-back or it didn't happen.** Every API write is verified with a GET.
  Everything the API can't do lands in an explicit manual-steps list.
- **Intent over volume.** A keyword is worth ranking for only when the person
  typing it wants *your* app.

## Repo layout

```
.agents/plugins/marketplace.json     # Codex marketplace entry
plugins/ergo-aso/.codex-plugin/      # plugin manifest
plugins/ergo-aso/skills/ergo-aso/    # the skill: SKILL.md, reference/, scripts/, renderer/
install.sh                           # copies the skill into a Codex skills directory
```

## Author

Built and maintained by [Tudor Iustin](https://tudoriustin.com).

## License

Copyright © 2026 Tudor Iustin. Licensed under Apache2.0 (SEE LICENSE)
The renderer downloads Google Fonts (DM Sans, Noto Sans family) at setup time;
those are OFL-licensed and not redistributed here.
