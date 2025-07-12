# Agents

A catalog of our Codex/ChatGPT agents, their purpose, setup, and how to invoke them.

## 🐍 Snake Metal Builder

- **Purpose:** Compile & run the Metal-based Snake demo.
- **Setup:**

  - Base Image: `universal` (Ubuntu 24.04 + Node.js + Python)
  - Secrets: `OPENAI_API_KEY`
  - Setup Script:

  ```bash
  # installs OpenAI SDK, Swift toolchain, etc.
  npm install openai
  apt-get update && apt-get install -y swift
  ```

- **How to run:**
  1. `swiftc -sdk "$(xcrun --sdk macosx --show-sdk-path)" -framework Cocoa -framework Metal -framework MetalKit main.swift -o SnakeMetalDemo`
  2. `./SnakeMetalDemo`

## 🤖 Codex Refactoring Agent

- **Purpose:** Auto-refactor Swift shaders or TypeScript API calls.
- **Prompt snippet:**
  > “You’re a Swift expert: update this Metal shader to support dynamic grid sizes without recompiling the entire pipeline…”

## 🧪 Test Runner Agent

- **Purpose:** Run unit & integration tests.
- **Setup tweaks:**

  - Grants internet **Off** after setup (tests are all local).
  - Installs test runner: `npm install jest` or `pip install pytest`.

- ## 🤖 CI Orchestrator Agent

- **Purpose:**

  1. Pushes/updates `.github/workflows/macos.yml`
  2. Triggers a `workflow_dispatch` on `macos-latest`
  3. Polls the run status until completion
  4. Downloads and surfaces the build logs for further fixes

- **Plugin requirements:**

  - GitHub plugin enabled
  - PAT with `repo` + `workflow` scopes

- **Workflow file:**
  `.github/workflows/macos.yml` (trigger: `workflow_dispatch`)

- **Typical tool calls:**

  1. `createOrUpdateFile` → upload/update your macos.yml
  2. `createWorkflowDispatchEvent` → kick off the build
  3. `listWorkflowRuns` → wait for `status: completed`
  4. `downloadWorkflowRunLogs` → fetch logs

- **Usage:**
  1. Generate or revise code in the Codex sandbox
  2. Ask the agent to update `macos.yml` (if needed)
  3. Dispatch and poll the workflow via GitHub API
  4. Paste back any errors for Codex to fix

---

> _Tip:_ Whenever you add a new agent in the Codex UI, copy its name, secret requirements, and setup script here so your whole team can see at a glance what lives in your sandbox.
