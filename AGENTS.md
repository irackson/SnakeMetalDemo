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

---

> _Tip:_ Whenever you add a new agent in the Codex UI, copy its name, secret requirements, and setup script here so your whole team can see at a glance what lives in your sandbox.
