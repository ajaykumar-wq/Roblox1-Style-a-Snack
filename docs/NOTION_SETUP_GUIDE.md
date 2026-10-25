# Notion Workspace Architecture & Setup Guide
## Roblox Game: Style a Snack (Roblox1)

This guide provides the complete blueprint for setting up your **Notion Project Hub** to track game updates, feature changes, roadmap milestones, and QA test reports. It is optimized to work seamlessly alongside this GitHub repository ([Roblox1-Style-a-Snack](https://github.com/ajaykumar-wq/Roblox1-Style-a-Snack.git)).

---

## 1. Notion Workspace Architecture Overview

```
📁 Style a Snack - Game Hub (Master Page)
│
├── 📊 Dashboard & Quick Metrics (Rollups & Live Status)
├── 🔄 Game Changes & Release Notes Tracker (Database)
├── 📋 Feature Roadmap & Sprint Backlog (Database)
├── 🧪 QA Test Reports & Bug Tracker (Database)
├── 🎨 Game Design Document (GDD) & Asset Registry
└── ⚙️ Luau Service & Remote Architecture Reference
```

---

## 2. Database 1: Game Changes & Release Notes Tracker

This database acts as the single source of truth for all version bumps, live hotfixes, balance patches, and client/server script updates.

### 2.1 Properties Schema

| Property Name | Property Type | Options / Format | Description |
| :--- | :--- | :--- | :--- |
| **Release / Change Name** | Title | Text (e.g., `v0.1.0 - Stage 1 Core Loop`) | Main release identifier |
| **Version** | Select | `v0.1.0`, `v0.2.0`, `v1.0.0-rc`, `Hotfix` | Semantic version string |
| **Release Type** | Multi-select | `Major Feature`, `Balance`, `Bugfix`, `UI Polish`, `Audio`, `Performance` | Categorization tag |
| **Status** | Status | `Draft` ➔ `In Staging` ➔ `Roblox Live` ➔ `Archived` | Deployment lifecycle |
| **Release Date** | Date | `YYYY-MM-DD` | Date deployed to Roblox place |
| **Commit / Git Ref** | Text / URL | E.g., `commit 01f92ba` or GitHub Commit Link | Linked commit from git log |
| **Affected Subsystems** | Multi-select | `RoundService`, `WarmupService`, `ServerJudgeService`, `DecorateController`, `UIController`, `DataService`, `ExplorationService`, `OvenService` | Luau architecture components |
| **QA Signoff** | Relation | Relation to **QA Test Reports** | Linked passing test run |
| **Breaking Changes** | Checkbox | `true` / `false` | DataStore migration or remotes breaking change |

### 2.2 Recommended Database Views
1. **Changelog Timeline View**: Grouped by Year/Month showing historical release cadence.
2. **Current Sprint Board**: Kanban board grouped by `Status` (`Draft`, `In Staging`, `Roblox Live`).
3. **Public Patch Notes View**: Gallery view filtered by `Status = Roblox Live` for copying into Discord announcements and Roblox game descriptions.

---

## 3. Database 2: Feature Roadmap & Sprint Backlog

Tracks upcoming features, level progression additions, mini-games, tools, species expansions, and landmark discoveries.

### 3.1 Properties Schema

| Property Name | Property Type | Options / Format | Description |
| :--- | :--- | :--- | :--- |
| **Task / Feature Name** | Title | Text (e.g., `Implement Drizzle Tool Bezier Mesh`) | Task description |
| **Phase / Milestone** | Select | `Stage 1: Single-Player Core`, `Stage 2: Multiplayer Runway`, `Stage 3: Economy & UGC`, `Stage 4: World Events` | Milestone grouping |
| **Priority** | Select | `🔴 P0 - Blocker`, `🟠 P1 - High`, `🟡 P2 - Medium`, `🟢 P3 - Low` | Urgency rank |
| **Status** | Status | `Backlog` ➔ `Designing` ➔ `In Development` ➔ `Ready for QA` ➔ `Done` | Development pipeline |
| **Domain** | Multi-select | `Server Scripting`, `Client UI`, `3D Modeling/Mesh`, `VFX/Audio`, `Balance/Config` | Discipline |
| **Script Targets** | Text | E.g., `src/server/StyleASnack/Services/RoundService.luau` | File path in repo |
| **Estimated Effort** | Number | Hours / Story Points | Work estimation |
| **Acceptance Criteria** | Text / Checklist | Markdown checklist of definition-of-done | Verification requirements |
| **Linked Test Run** | Relation | Relation to **QA Test Reports** | QA validation record |

### 3.2 Recommended Database Views
1. **Milestone Kanban**: Grouped by `Status` and sub-grouped by `Phase / Milestone`.
2. **Developer Matrix**: Table view grouped by `Domain` showing active assignments.
3. **P0/P1 Priority View**: Filtered for high-priority items blocking release.

---

## 4. Database 3: QA Test Reports & Bug Tracker

Maintains strict verification logs for single-player runs, multiplayer stress tests, device compatibility checks (PC/Mobile/Tablet), and bug reports.

### 4.1 Properties Schema

| Property Name | Property Type | Options / Format | Description |
| :--- | :--- | :--- | :--- |
| **Report ID & Title** | Title | Text (e.g., `TR-001: Stage 1 Single-Player Loop Verification`) | Unique test run identifier |
| **Test Category** | Select | `Smoke Test`, `Full Regression`, `Economy Audit`, `Device Compatibility`, `Server Stress` | Testing scope |
| **Result** | Status | `Passed ✅`, `Passed with Warnings ⚠️`, `Failed ❌`, `Blocked 🛑` | Final evaluation |
| **Date Tested** | Date | `YYYY-MM-DD` | Timestamp of run |
| **Roblox Studio / Place Version** | Text | E.g., `Studio Place v14 / Git 01f92ba` | Place version ID |
| **Platform** | Multi-select | `Studio PlaySolo`, `Windows Client`, `Mac Client`, `iOS Mobile`, `Android`, `Console` | Target hardware |
| **Tester** | Person / Text | Name or handle of tester | QA lead |
| **Critical Bugs Found** | Number | Count of P0/P1 issues | Bug count |
| **Linked Release** | Relation | Relation to **Game Changes Tracker** | Version being certified |

### 4.2 Sub-table: Bug Ticket Schema

When logging an issue inside a Test Report page:

```
[BUG-###] Brief Bug Summary
• Severity: Blocker | Critical | Major | Minor | Cosmetic
• Environment: Roblox Studio 0.69x / Windows 11
• Script Location: e.g., src/client/StyleASnack/Controllers/DecorateController.luau:214
• Steps to Reproduce:
  1. Open OvenModal
  2. Click Hatch with Sparkle < 50
  3. Inspect console output
• Expected Behavior: Friendly error sound & "Not enough Sparkle" prompt
• Actual Behavior: Modal freezes or throws silent nil indexing
• Studio Console Output: [Paste stack trace]
• Verification: Retested on Git Commit <hash>
```

---

## 5. Step-by-Step Notion Setup Instructions

### Step 1: Create the Main Page
1. Open Notion and click **+ New Page**.
2. Title it: `🍰 Style a Snack - Project HQ`.
3. Add an icon (e.g. 🥐 or 🍰) and a cover image featuring your boardwalk / pastry art.

### Step 2: Import Markdown Templates
You can directly import the ready-to-use templates created in this repo:
- **Game Changes Tracker**: Import [`docs/GAME_CHANGES_TRACKER.md`](file:///d:/personal/AI-Projects/roblox%20game/docs/GAME_CHANGES_TRACKER.md)
- **Feature Roadmap**: Import [`docs/FEATURE_ROADMAP_TRACKER.md`](file:///d:/personal/AI-Projects/roblox%20game/docs/FEATURE_ROADMAP_TRACKER.md)
- **QA Test Reports**: Import [`docs/TEST_REPORTS_TRACKER.md`](file:///d:/personal/AI-Projects/roblox%20game/docs/TEST_REPORTS_TRACKER.md)

*To import directly into Notion:*
1. In Notion, click the `...` menu in the top right corner.
2. Select **Import** ➔ **Markdown & CSV**.
3. Select any of the files in `docs/`. Notion automatically parses headings, checklists, and tables!

### Step 3: Link Notion with GitHub
1. In your Notion Hub page, add a **GitHub Embed**:
   Type `/github` and paste your repository link:
   `https://github.com/ajaykumar-wq/Roblox1-Style-a-Snack.git`
2. Configure GitHub webhooks or GitHub Actions (via Notion Unofficial/Official integration) to automatically log commits into your `Game Changes` database.
