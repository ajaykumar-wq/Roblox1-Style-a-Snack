# 🔄 Game Changes & Updates Tracker
### Project: Style a Snack (Roblox1) | Repository: [sajaytmpc/Roblox1-Style-a-Snack](https://github.com/sajaytmpc/Roblox1-Style-a-Snack.git)

> **Notion Import Tip**: In Notion, create a **Database (Table or Timeline view)** with the columns defined below, or import this document directly using Notion's *Import Markdown* tool.

---

## Database Schema Overview

| Version | Release Title | Release Date | Type | Subsystems Impacted | Commit Hash | QA Status | Deployment Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **v0.1.1** | GDD Alignment & Flow Upgrade | 2026-10-25 | `Feature` `Polish` `GDD Spec` | Round, Warmup, Data, UI, Creator | `3a04f01` | Passed ✅ | Live in Staging |
| **v0.1.0** | Stage 1 Single-Player Core Loop | 2026-10-25 | `Major Feature` `Architecture` | All Services & Controllers | `01f92ba` | Passed ✅ | Live in Staging |
| **v0.0.1** | Initial Luau Architecture & Scaffolding | 2026-10-24 | `Infrastructure` | Directory Structure & Starter Scripts | `ce3f4aa` | Passed ✅ | Staging Base |

---

## Detailed Release Entries

---

### 📦 Release v0.1.1 — Prototype GDD Alignment & Gameplay Flow Upgrade
- **Release Date**: October 25, 2026
- **Git Commit**: `v0.1.1`
- **Deployment Status**: 🟢 Active in Development & Staging
- **QA Signoff**: Verified against Prototype GDD (Oct 24/25, 2026) (Pass ✅)

#### 🌟 Highlights
- **60-Second First Minute Flow**: Orchestrated exact timeline (Spawn 0-5s, Creator 5-25s, Warm-up Decorate 25-50s, Judging 50-60s, First Score at 1:00 with 20 Sparkles).
- **Meet Your Snackimal Creator (`UICreatorModal.luau`)**: 3-step creation (Family, Look/Flavor, Curated Name) plus big "Surprise Me!" button.
- **Controls Card ("Three Things to Know") (`UIControlsCardModal.luau`)**: Walk, Decorate, Undo guide shown on first Decorate tap and accessible via Map ➔ Help.
- **Auto-Dealt Theme with "Skip Once Today" (`UIThemeChoice.luau`)**: Drumroll theme reveal, 3-second countdown auto-start, and daily skip allowance.
- **Three Snackimal Judges**: Integrated Madame Macaron, Coach Pretzel, and DJ Boba voices & feedback into `ServerJudgeService` and `UIResultsHUD`.
- **DataService Fixes**: Fixed player key indexing bug; added daily skip tracking and creator profile persistence.

### 📦 Release v0.1.0 — Stage 1 Single-Player Core Loop
- **Release Date**: October 25, 2026
- **Git Commit**: [`01f92ba`](https://github.com/sajaytmpc/Roblox1-Style-a-Snack/commit/01f92ba73c2bc61655c89c0de238160537e92693)
- **Deployment Status**: 🟢 Active in Development & Staging
- **QA Signoff**: Verified in Test Run `TR-001` (Pass ✅)

#### 🌟 Highlights
- Complete single-player gameplay loop: Warmup ➔ Theme Selection ➔ Snack Decorating ➔ Server Judging & AI Rivals ➔ Podium Showcase ➔ Economy Rewards.
- 5 Boardwalk landmarks with interactive proximity prompts and hidden collector stickers.
- Bakery Oven creature hatching system with pity counter and rarity tiers.
- 6-level player progression tree with tool and feature unlocks.
- Complete modular client UI stack with 10 custom controller scripts.

#### 🛠️ Subsystems & Code Changes
1. **Core Round Loop (`src/server/StyleASnack/Services/RoundService.luau`)**:
   - Implemented state machine: `Intermission` ➔ `ThemeReveal` ➔ `Decorating` ➔ `ServerJudge` ➔ `RunwayShowcase` ➔ `Podium` ➔ `Intermission`.
   - Dynamic round durations (60s warmup, configurable standard rounds).
   - Graceful fallback when only 1 player is connected (single-player solo testing mode).

2. **Server-Side Scoring (`src/server/StyleASnack/Services/ServerJudgeService.luau`)**:
   - 100-point rubric with strict mathematical breakdown:
     - **Palette Adherence (40 pts)**: Validates swatches match occasion palette.
     - **Coverage (30 pts)**: Validates decorated surface area across 4 regions (`head`, `body`, `back`, `tail`).
     - **Tool Variety (20 pts)**: Rewards layered tool usage (Icing, Sprinkle, Sticker, Drizzle, Pattern).
     - **Occasion Bonus (10 pts)**: Bonus matching theme criteria.
   - Star rating conversion (1 to 5 Stars).

3. **AI Rival Competitors (`src/server/StyleASnack/Services/RivalService.luau`)**:
   - Generates simulated competitor snack creations when player plays solo.
   - Distinct NPC personality archetypes (e.g., *Chef Macaron*, *Sprinkle Sandy*, *Baguette Bob*) with simulated scores and randomized decoration styles.

4. **Warmup & Onboarding (`src/server/StyleASnack/Services/WarmupService.luau`)**:
   - 60-second tutorial warmup round for newcomers.
   - Guided step-by-step icing tutorial ensuring players understand the 4 body regions.

5. **Bakery Oven Hatching (`src/server/StyleASnack/Services/OvenService.luau`)**:
   - Hatch snack animal species (`croissant_cat`, `donut_pup`, `taco_turtle`, etc.).
   - Rarity distribution: Common (60%), Uncommon (25%), Rare (10%), Epic (4%), Mythic (1%).
   - Built-in bad-luck pity counter guaranteeing rare drop within 10 hatches.

6. **Coastal Exploration & 5 Landmarks (`src/server/StyleASnack/Services/ExplorationService.luau`)**:
   - Landmark 1: *Lighthouse* (Hidden Star Sticker)
   - Landmark 2: *Ferris Wheel* (Hidden Balloon Sticker)
   - Landmark 3: *Candy Stand* (Hidden Heart Sticker)
   - Landmark 4: *Fishing Dock* (Hidden Fish Sticker)
   - Landmark 5: *Tide Pools* (Hidden Shell Sticker)

7. **Client UI & Interaction Suite (`src/client/StyleASnack/Controllers/`)**:
   - `UIController.luau`: Master UI dispatcher and HUD orchestrator.
   - `DecorateController.luau`: 3D snack interaction, region raycasting, and tool application.
   - `UIThemeChoice.luau`: Theme and occasion announcement screen.
   - `UIResultsHUD.luau`: Runway score breakdown, star animations, and podium display.
   - `UIOvenModal.luau`: Animated oven baking and hatching interface.
   - `UIMapModal.luau`: Boardwalk map with landmark tracker.
   - `UIIndexModal.luau`: Creature species collection compendium.
   - `ViewController.luau`: Smooth camera transitions between exploration, studio dressing, and runway podium.
   - `AudioController.luau`: Sound effects for icing, sprinkles, fanfare, and timer ticks.

8. **Configuration & Network Layer (`src/shared/StyleASnack/`)**:
   - `Remotes.luau`: Type-safe remote event and remote function bridge.
   - `SpeciesConfig.luau`, `ThemeConfig.luau`, `DecorationConfig.luau`, `EconomyConfig.luau`, `ProgressionConfig.luau`, `ExplorationConfig.luau`.

---

### 📦 Release v0.0.1 — Initial Project Scaffolding
- **Release Date**: October 24, 2026
- **Git Commit**: [`ce3f4aa`](https://github.com/sajaytmpc/Roblox1-Style-a-Snack/commit/ce3f4aa)
- **Deployment Status**: Baseline
- **QA Signoff**: Verified

#### 🌟 Highlights
- Scaffolded standard Luau Roblox project structure (`src/client`, `src/server`, `src/shared`).
- Configured `.gitignore` for Roblox binary `.rbxl` and temporary caches.
- Integrated Antigravity Roblox Studio MCP protocol support.

---

## Change Template for Future Updates

Copy this template into Notion for every new release or patch:

```markdown
### 📦 Release v[X.Y.Z] — [Release Title]
- **Release Date**: [YYYY-MM-DD]
- **Git Commit**: [commit-hash-link]
- **Deployment Status**: Draft | In Staging | Live
- **QA Signoff**: [Link to Test Report TR-###]

#### 🌟 Highlights
- Summary of the 2-3 most impactful changes

#### 🚀 New Features & Enhancements
- Feature 1 description
- Feature 2 description

#### ⚖️ Balance & Economy Adjustments
- Adjustments to Sparkle currency or rewards

#### 🐛 Bug Fixes & Optimizations
- Fix 1: Issue resolved
- Fix 2: Performance improvement

#### ⚠️ Breaking Changes / Migration Notes
- Note any DataStore profile format changes or remote signature changes
```
