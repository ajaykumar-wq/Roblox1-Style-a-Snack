# Roblox Game Project

This project is set up for collaborative development with Antigravity using Roblox Studio's built-in Model Context Protocol (MCP) server.

## Project Structure

```
├── docs/                 # Game design documents and architecture notes
├── src/
│   ├── client/           # Client scripts (StarterPlayerScripts)
│   ├── server/           # Server scripts (ServerScriptService)
│   └── shared/           # Shared modules and constants (ReplicatedStorage)
├── .gitignore            # Git ignore rules for Roblox files
└── README.md
```

## Antigravity & Roblox Studio Integration

Antigravity communicates directly with your active Roblox Studio session using the official **Roblox Studio MCP Proxy**.

### Linking Steps:
1. Open **Roblox Studio** and open/create a place (e.g., standard Baseplate or your game place).
2. Open the **Assistant** window in the top-right toolbar.
3. Click the `⋯` (three dots menu) on the Assistant panel and choose **Manage MCP Servers**.
4. Enable **Enable Studio as MCP server**.
5. Once active, the MCP proxy automatically links Antigravity to your running Studio session, enabling real-time script editing, hierarchy inspection, asset creation, and playtesting.
