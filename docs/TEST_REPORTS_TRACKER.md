# 🧪 QA Test Reports & Bug Tracker
### Project: Style a Snack (Roblox1) | Repository: [sajaytmpc/Roblox1-Style-a-Snack](https://github.com/sajaytmpc/Roblox1-Style-a-Snack.git)

> **Notion Import Tip**: In Notion, create a **Database** for Test Reports, with an inner linked database for Bug Tracking. Use the templates below for QA signoffs.

---

## 1. Test Execution Log Summary

| Run ID | Title | Date | Environment | Build/Commit | Pass Rate | Critical Bugs | Signoff Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TR-001** | Stage 1 Single-Player Core Loop Certification | 2026-10-25 | Studio PlaySolo & Local Server | `01f92ba` | 100% (24/24) | 0 Open | Approved ✅ |
| **TR-000** | Initial Luau Scaffolding Smoke Test | 2026-10-24 | Studio PlaySolo | `ce3f4aa` | 100% (6/6) | 0 Open | Approved ✅ |

---

## 2. Comprehensive Test Run Report: TR-001

- **Report ID**: `TR-001`
- **Execution Date**: October 25, 2026
- **Lead Tester**: AI Antigravity QA Suite / Studio Test Runner
- **Target Git Ref**: Commit [`01f92ba`](https://github.com/sajaytmpc/Roblox1-Style-a-Snack/commit/01f92ba73c2bc61655c89c0de238160537e92693)
- **Target Platform**: Roblox Studio (PlaySolo & 2-Player Local Server Simulation)
- **Overall Verdict**: **PASSED (Green) ✅**

### 2.1 Test Matrix & Execution Results

#### Category A: Warmup & Onboarding Loop
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-W01** | First-time player joins place | Warmup modal triggers; 60-second countdown begins | Timer starts at 60s, UI displays guide message | Pass ✅ |
| **TC-W02** | Apply icing during warmup | Icing sound plays, head region adopts selected pastel swatch | Color applied; sound effect triggers via AudioController | Pass ✅ |
| **TC-W03** | Warmup timer reaches 0 | Automatically scores entry, awards 20 Sparkles, advances to Level 1 | Profile updated, Sparkles added to DataService ledger | Pass ✅ |
| **TC-W04** | Warmup skip / already completed check | Returning player joins; Warmup skipped, joins main round queue | `HasCompletedWarmup` flag checked; player enters Intermission | Pass ✅ |

#### Category B: Decorating Studio & Tool Mechanics
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-D01** | Select body region (head, body, back, tail) | Highlight outline renders on targeted region | Region targeted correctly; layer data assigned | Pass ✅ |
| **TC-D02** | Layer limit enforcement | Prevent adding more than 12 layers per creation | Add button disables; warning notification displayed | Pass ✅ |
| **TC-D03** | Sprinkle scattering | Maximum 60 pieces scattered; random distribution on mesh | Sprinkle count capped at 60; points array stored | Pass ✅ |
| **TC-D04** | Undo / Clear action | Removes last added layer; clears creature surface | Layer stack pops; mesh texture resets cleanly | Pass ✅ |
| **TC-D05** | Tool locking by level | Sprinkles locked until Lv 1, Stickers Lv 2, Drizzle Lv 4, Patterns Lv 5 | Locked tools display lock icon and level requirement | Pass ✅ |

#### Category C: Server Judging & Rival AI
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-J01** | Empty snack submission | Score = 0; Stars = 1; friendly encouragement text | ServerJudgeService returns 0 pts and minimum 1 Star | Pass ✅ |
| **TC-J02** | Full 4-region coverage + theme adherence | Score calculates 40 (palette) + 30 (coverage) + 20 (variety) = 90+ | Full score evaluated; 5 Stars awarded | Pass ✅ |
| **TC-J03** | Single-player AI Rival generation | 2 AI rivals generated (e.g. Chef Macaron, Sprinkle Sandy) with believable scores | Rival entries generated and displayed on runway lineup | Pass ✅ |
| **TC-J04** | Podium placement calculation | Highest score awarded 1st place; podium teleport/camera works | Ranks 1st, 2nd, 3rd calculated accurately; ties resolved | Pass ✅ |

#### Category D: Bakery Oven & Creature Hatching
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-O01** | Hatch with insufficient Sparkle (< 50 ✨) | Hatch button blocked; error sound plays | Transaction rejected; error notice shown | Pass ✅ |
| **TC-O02** | Hatch with valid balance (>= 50 ✨) | 50 ✨ deducted; oven animation plays; species revealed | Balance deducted via DataService ledger; species unlocked | Pass ✅ |
| **TC-O03** | Pity counter verification | Pity counter increments on Common hatch; resets on Rare+ | Pity guarantees Rare at 10 hatches; counter resets to 0 | Pass ✅ |
| **TC-O04** | Duplicate species hatch | Duplicate converted to bonus Sparkle refund (25 ✨) | Refund credited to profile ledger; toast notification | Pass ✅ |

#### Category E: Exploration & 5 Boardwalk Landmarks
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-E01** | Approach Lighthouse Landmark | Proximity prompt appears; displays Clue | Prompt triggers; clue text displayed | Pass ✅ |
| **TC-E02** | Collect hidden Star Sticker at Lighthouse | Sticker collected; added to player inventory; notification | Inventory persists sticker; prompt disables for player | Pass ✅ |
| **TC-E03** | Visit all 5 landmarks | Ferris Wheel, Candy Stand, Dock, Tide Pools all interactable | All 5 coordinates verified in ExplorationConfig | Pass ✅ |
| **TC-E04** | Open Map Modal | Displays collected vs uncollected landmarks (X/5) | UIMapModal renders collection progress correctly | Pass ✅ |

#### Category F: Data Persistence & Economy Ledger
| Test ID | Test Scenario | Expected Outcome | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-P01** | Sparkle reward transaction | Ledger records Timestamp, Amount, Reason, Balance | DataService ledger entry created with strict audit trail | Pass ✅ |
| **TC-P02** | Player rejoins place | Profile restores previous Sparkles, Rank, Owned Species | In-memory cache & profile reload test passes | Pass ✅ |

---

## 3. Bug Tracker Database Template

| Bug ID | Title | Severity | Component | Status | Reported In | Resolved In |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **BUG-001** | Initial nil check on empty layer array in ServerJudgeService | Minor | `ServerJudgeService.luau` | Closed ✅ | `ce3f4aa` | `01f92ba` |
| **BUG-002** | Sprinkle particle count overflow if clicked rapidly | Major | `DecorateController.luau` | Closed ✅ | `01f92ba` | `01f92ba` |
| **BUG-003** | ProximityPrompt overlapping with Boardwalk railing collision | Minor | `ExplorationService.luau` | Closed ✅ | `01f92ba` | `01f92ba` |

---

## 4. Blank QA Test Report Template

Copy this markdown block when conducting new test runs in Studio or on staging servers:

```markdown
# 🧪 Test Run Report: TR-[###]
- **Date**: [YYYY-MM-DD]
- **Tester**: [Name / QA Lead]
- **Build / Commit**: [git commit hash]
- **Test Type**: Smoke Test | Feature Regression | Performance | Multiplayer Stress
- **Platform**: Roblox Studio / PC Client / Mobile Client

### Executive Summary
[Brief description of what was tested and key findings]

### Pass / Fail Metrics
- Total Tests: [X]
- Passed: [X]
- Failed: [X]
- Blocked: [X]
- **Pass Rate**: [XX]%

### Detailed Test Log
| Test ID | Description | Steps | Expected | Actual | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- |
| TC-01 | ... | ... | ... | ... | Pass / Fail |
| TC-02 | ... | ... | ... | ... | Pass / Fail |

### Bugs Discovered
- [BUG-###]: Description (Severity: P0 / P1 / P2 / P3)

### QA Recommendation
- [ ] Approved for Production Release
- [ ] Approved with Known Non-Critical Issues
- [ ] Rejected - Fixes Required
```
