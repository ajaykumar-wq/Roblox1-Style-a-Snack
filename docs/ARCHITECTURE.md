# 🏗️ Style a Snack - System Architecture & Technical Specification

## 1. System Overview

**Style a Snack** is built on a clean, decoupled, client-server Luau architecture optimized for Roblox Studio Model Context Protocol (MCP) and Rojo development workflows.

```
                           +---------------------------+
                           |   Roblox Server Engine    |
                           +-------------+-------------+
                                         |
                                         v
                      +-------------------------------------+
                      |       ServerScriptService           |
                      | src/server/StyleASnack/MainServer   |
                      +------------------+------------------+
                                         |
         +-----------------+-------------+-------------+-----------------+
         |                 |                           |                 |
         v                 v                           v                 v
+-----------------+ +---------------+           +---------------+ +---------------+
|  RoundService   | | WarmupService |           | ServerJudge   | | RivalService  |
| (Game Loop SM)  | |  (Tutorial)   |           | (Rubric/Stars)| | (NPC Rivals)  |
+-----------------+ +---------------+           +---------------+ +---------------+
         |                 |                           |                 |
         +-----------------+-------------+-------------+-----------------+
                                         |
                                         v
                      +-------------------------------------+
                      |           DataService               |
                      |   Profile & Sparkle Ledger Store    |
                      +------------------+------------------+
                                         |
                                         | RemoteEvents & RemoteFunctions
                                         | (ReplicatedStorage.Remotes)
                                         v
                      +-------------------------------------+
                      |         StarterPlayerScripts        |
                      | src/client/StyleASnack/MainClient   |
                      +------------------+------------------+
                                         |
         +-----------------+-------------+-------------+-----------------+
         |                 |                           |                 |
         v                 v                           v                 v
+-----------------+ +---------------+           +---------------+ +---------------+
|  UIController   | | DecorateCtrl  |           | ViewController| | AudioController|
| (HUD & Modals)  | | (3D Dressing) |           | (Camera SM)   | | (SFX & BGM)   |
+-----------------+ +---------------+           +---------------+ +---------------+
```

---

## 2. Server Architecture (`src/server/StyleASnack/Services`)

| Service | Primary Responsibility | Key Functions / Methods |
| :--- | :--- | :--- |
| **`RoundService.luau`** | Manages round lifecycle state machine (`Intermission`, `ThemeReveal`, `Decorating`, `Judging`, `Runway`, `Podium`). | `startLoop()`, `advanceState()`, `submitEntry()`, `getRoundTimeRemaining()` |
| **`WarmupService.luau`** | Manages the 60-second guided single-player introductory round for first-time players. | `startWarmup(player)`, `onWarmupComplete(player)` |
| **`ServerJudgeService.luau`** | Evaluates snack submissions using a strict 100-point rubric (Palette, Coverage, Variety, Occasion). | `scoreEntry(layers, occasionId, paletteId, toolCount)` |
| **`RivalService.luau`** | Generates simulated NPC snack competitors when playing in single-player or low-player lobbies. | `generateRivalEntries(count, themeId)` |
| **`ExplorationService.luau`** | Coordinates the 5 boardwalk landmarks, proximity prompts, and hidden sticker collection. | `initLandmarks()`, `collectSticker(player, landmarkId)` |
| **`OvenService.luau`** | Manages creature baking, rarity rolling, pity counters, and duplicate conversions. | `hatchCreature(player)` |
| **`EconomyService.luau`** | Awards Sparkles, handles tool shop purchases, and enforces transaction rate-limits. | `awardSparkles()`, `deductSparkles()` |
| **`DataService.luau`** | Player profile persistence, progression rank, unlocks, and immutable transaction audit ledger. | `loadProfile()`, `saveProfile()`, `unlockTool()` |
| **`AnalyticsService.luau`** | Telemetry tracking for round completion, drop-off, and popularity metrics. | `trackEvent(player, eventName, attributes)` |

---

## 3. Client Architecture (`src/client/StyleASnack/Controllers`)

| Controller | Primary Responsibility |
| :--- | :--- |
| **`UIController.luau`** | Master UI orchestrator; displays countdowns, modals, and HUD overlays. |
| **`DecorateController.luau`** | Handles mouse/touch input on 3D snack models, raycasts to body regions, and layer management. |
| **`ViewController.luau`** | Smooth camera state transitions (e.g. standard character follow, close-up studio dress, runway fly-by). |
| **`AudioController.luau`** | Plays dynamic SFX for icing squirts, sprinkle rattles, countdown chimes, and victory fanfares. |
| **`UIThemeChoice.luau`** | Displays the current theme and color palette swatches. |
| **`UIResultsHUD.luau`** | Animated breakdown of judges' score cards, stars, and podium rankings. |
| **`UIOvenModal.luau`** | Interactive bakery oven interface with heat gauge and hatch animation. |
| **`UIMapModal.luau`** | Boardwalk map highlighting discovered landmarks and sticker checklist. |
| **`UIIndexModal.luau`** | Compendium of discovered and unlocked snack animal species. |

---

## 4. Shared Configuration & Network (`src/shared/StyleASnack`)

- **`Network/Remotes.luau`**: Defines all `RemoteEvents` and `RemoteFunctions` used between client and server.
- **`Config/SpeciesConfig.luau`**: Definitions for snack species (`Croissant Cat`, `Donut Pup`, `Taco Turtle`, etc.), rarities, and body regions (`head`, `body`, `back`, `tail`).
- **`Config/ThemeConfig.luau`**: 12 Occasions (Beach Day, Royal Gala, Space Camp, etc.) and color swatches.
- **`Config/DecorationConfig.luau`**: Tool definitions (Icing, Sprinkle, Sticker, Drizzle, Pattern, Accessory) and layer limits (max 12).
- **`Config/ProgressionConfig.luau`**: 6-level progression tree with level requirements and tool unlocks.
- **`Config/ExplorationConfig.luau`**: Landmark coordinates, clues, and hidden sticker IDs.
- **`Config/EconomyConfig.luau`**: Sparkle costs, hatch prices, and reward formulas.
