# Developer Workflows in Google Antigravity

Riri is fully prepared for agentic development inside **Google Antigravity** (public preview, launched November 2025). The repository utilizes specialized agents, local tools, and structured checklists to let developer-agents work collaboratively with human programmers.

---

## Setting Up Antigravity for Riri

1. **Launch Antigravity**: Open the root `riri` directory in your IDE.
2. **Set Development Mode**: Ensure you are in **Review-driven development** mode (via bottom bar status or settings). This gives you control, prompting you for command authorization (`flutter pub run build_runner build`, `git push`, etc.) before they execute.
3. **Load Dart & Flutter MCP Server**: 
   - Open the Agent Panel (`Ctrl + L` / `Cmd + L`).
   - Go to `... > MCP Servers > Manage MCP Servers > MCP Store`.
   - Search for **Dart** and install it. This gives the agent direct, LSP-level diagnostic awareness of your Flutter project, enabling rapid auto-correction.

---

## Agentic Development Workflows

We provide pre-configured Agent instructions inside the `.agents/skills/` directory. You can direct Antigravity agents to execute workflows autonomously:

### 1. Taglish Copywriting & Tuning
- **Agent File**: `.agents/skills/riri_copywriter.json`
- **Command prompt**:
  > *"Antigravity, generate 15 new humorous reminder lines for Malupit mode inside core/notifications/personas.dart following the copywriter spec."*
- **What it does**: The agent loads the persona rules, generates context-appropriate template rows, inserts them cleanly, and executes the unit tests.

### 2. Feature Refactoring
- **Agent File**: `.agents/skills/riri_refactor.json`
- **Command prompt**:
  > *"Antigravity, add a new 'habit tracker' feature. Scaffold the dashboard item and wire it to Drift database tables following our repository patterns."*
- **What it does**: The agent scaffolds directory folders under `lib/features/`, appends the SQLite columns in `riri_database.dart`, runs code generation, and hooks the streams reactive path to Riverpod providers.
