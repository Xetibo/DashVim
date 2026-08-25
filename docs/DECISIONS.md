# Decisions

## 2026-08-10 — Angular/TS LSP ownership + scoped Roslyn watcher

- Angular (`ngserver`) owns every Angular template buffer — `filetypes = ["html" "htmlangular" "typescript" "typescriptreact"]` in `config/languages/lsp.nix`. On `html`/`htmlangular` it is the sole template provider and neuters any vanilla HTML LSP (fixes the LS not firing when the `html`→`htmlangular` flip fails). Inside Angular projects (root marker `angular.json`/`nx.json`) it also attaches to `typescript`/`typescriptreact` as a references-only companion so `.ts` references include usages in external `.html` templates; its `on_attach` disables its own non-reference providers on TS/TSX.
- `typescript-tools.nvim` fully owns ts/js/tsx/jsx (completion, diagnostics, hover, etc.). It gives up `referencesProvider` inside Angular projects (its `on_attach` sets it false under `angular.json`/`nx.json`) because ngserver owns references there. In non-Angular projects typescript-tools serves references itself. This pairing restores `.ts`→`.html` usage references that were lost when ngserver was scoped off ts/tsx.
- Roslyn watchers: keep `filewatching = "off"` (disables Roslyn/Neovim broad watchers) and add a scoped client-side watcher in `luaConfigRC.dashvim-roslyn-file-change-notifications` using `vim._watch.watchdirs` rooted at the solution dir, `exclude_pattern` for `bin`/`obj`/`.git`/`node_modules`/`.vs`/`.roslyn-cache`/`.generated`, `include_pattern` for `**/*.{cs,csproj,sln,slnx,slnf,props,targets}`. It reconciles watchdirs' mislabeled "Changed" creates against a known-file set → delivers `Created`(1) for externally-created files (issue2/op2) and constrains scope + excludes churn dirs (issue3/op1&4). Started on roslyn `LspAttach`, cancelled on `LspDetach`; root `/` is refused; whole watcher wrapped in `pcall` so it degrades to save-time-only sends if the internal API changes.

## 2026-07-06 — Default opencode plugin switched to oh-my-openagent

- Changed `programs.dashvim.opencode.plugin` default list in `modules/default.nix`.
- Replaced `"micode"` with `"oh-my-openagent"`.
- Kept other defaults unchanged: `"@slkiser/opencode-quota"` and `"@tarquinen/opencode-dcp@latest"`.
- Rationale: align DashVim's default opencode integration with the oh-my-openagent plugin flow for agent/category model routing.

## 2026-07-07 — oh-my-openagent model mode (copilot vs free)

- Added `programs.dashvim.opencode.modelMode` option in `modules/default.nix` (enum: `"copilot"` | `"free"`).
- Created `opencode/oh-my-openagent-copilot.jsonc` — all 10 agents + 8 categories use `github-copilot/*` models only.
- Created `opencode/oh-my-openagent-free.jsonc` — all agents/categories use `opencode/*` free models only; `hephaestus` is disabled (requires GPT-5.5, no free equivalent).
- `hm/opencode.nix` deploys the selected config to `~/.config/opencode/oh-my-openagent.jsonc` via `xdg.configFile`.
- Enforcement: zero cross-contamination between providers — every agent/category model field is explicitly overridden.
- Free model assignments: `deekseek-v4-flash-free` for primary reasoning, `north-mini-code-free` for coding/quick, `mimo-v2.5-free` for visual/multimodal (only free model with image input), `nemotron-3-ultra-free` for large context.

## 2026-07-07 — Runtime mode switching via opencode-nvim plugin

- Refactored `hm/opencode.nix` to deploy **both** `oh-my-openagent-copilot.jsonc` and `oh-my-openagent-free.jsonc` (instead of only the selected one).
- The active `oh-my-openagent.jsonc` is now managed at runtime by the `opencode-nvim` Lua plugin, not by Nix.
- Added `:OpenCodeAgentMode {copilot|free}` command to `opencode-nvim` plugin (`init.lua`).
- `M.set_mode(mode)` copies the selected source config to `oh-my-openagent.jsonc`, kills the running opencode terminal, and notifies the user.
- `M.setup()` initializes the active config from the Nix `default_model_mode` on first run (if absent).
- `config/editor/opencode.nix` passes `config'.opencode.modelMode` as `default_model_mode` setupOpt.
- `modelMode` Nix option still controls the default; runtime switching no longer requires a rebuild.

## 2026-07-08 — Per-session mode isolation (no shared file writes)

- `M.set_mode()` is now purely in-memory — no writes to `~/.config/opencode/oh-my-openagent.jsonc` or `.opencode_mode` marker.
- `start_terminal()` creates `/tmp/opencode-nvim-{uuid}/opencode/` with symlinks to shared global configs and a copy of the mode-specific `oh-my-openagent-{mode}.jsonc`.
- opencode launched with `XDG_CONFIG_HOME` pointing at the temp dir → fully isolated per Neovim session.
- `prepare_session_config()` fallback chain: current_mode → default_mode → copilot.
- No marker file: mode resets to Nix default on Neovim restart. This is intentional — the default is configured in Nix, not persisted per-session.
- Removed `detect_mode()`, `mode_marker()`, and all shared file I/O from `init.lua`. Plugin went from ~222 to ~185 lines.
- Rationale: two concurrent Neovim/opencode instances writing to the same `~/.config/opencode/oh-my-openagent.jsonc` would clash; per-session temp dirs eliminate the clash entirely.

## 2026-07-07 — Added firefox-debugadapter Nix derivation

- Created `lib/firefox-debug-adapter.nix` using `buildNpmPackage` from `firefox-devtools/vscode-firefox-debug` `v2.15.0`.
- Follows the `vscode-js-debug` packaging pattern in nixpkgs.
- Uses placeholder hashes (`lib.fakeHash`) that are replaced on first build.
- `postPatch` uses `jq` to ensure a webpack build script exists.
- `postInstall` creates `$out/bin/firefox-debug-adapter` wrapper running `node dist/adapter.bundle.js`.

## 2026-07-07 — Added Firefox DAP adapter

- Updated `config/lua/dap.lua` to register `dap.adapters["firefox"]`.
- Adapter is executable-based with `command = "firefox-debug-adapter"`.
- Placement is between `pwa-chrome` and `coreclr` adapter definitions.
- Existing adapter and configuration blocks were intentionally left unchanged.

## 2026-07-07 — Added workspace Firefox launch template

- Added `.vscode/launch.json` with a Firefox launch configuration targeting `http://localhost:4200`.
- Configuration uses Firefox debug adapter shape (`type = "firefox"`, `request = "launch"`, `reAttach = true`).
- Source mapping uses `pathMappings` (`url`/`path`) and intentionally does not use Chrome-only `sourceMapPathOverrides`.

## 2026-07-07 — Added firefox-debugadapter to shared dependencies

- Updated `lib/dependencies.nix` to define `firefoxDebugAdapter = pkgs.callPackage ./firefox-debug-adapter.nix { };` in the `let` block.
- Added `firefoxDebugAdapter` to the dependency list directly after `vscode-js-debug` in the DAP adapter section.
- Existing dependency ordering and entries were left unchanged.

## 2026-07-08 — Review mode for agent-generated code changes

- Added `config/editor/opencode/lua/opencode/review.lua` — review module with scratch-buffer-based code review for agent changes.
- Comment model: mode-based — any text the user inserts into a review buffer IS a review comment. No special syntax or markers needed.
- File source: git changes — `git diff --cached --name-only`, `git diff --name-only`, `git ls-files --others --excluded-standard` (staged, unstaged, untracked).
- Buffer layout: one scratch buffer per changed file, `buftype=nofile`, content loaded from disk, original lines stored in `vim.b[bufnr].review_original` for diff comparison.
- Highlighting: `OpenCodeReviewComment` highlight group (warm yellow-tinted `guibg=#3d3522`) applied via extmarks on lines that differ from original. Refreshed on `TextChanged`/`InsertLeave` autocmds.
- Handoff: review JSON written to `.omo/review-<session-id>.json`. Sent to opencode terminal via `nvim_chan_send` if the terminal is running; otherwise user is notified of the file path.
- Commands: `:OpenCodeReview` (start session), `:OpenCodeReviewComplete` (finalize and handoff).
- SCRAPPED 2026-07-08: scratch buffer approach had bugs — "buffer already in memory" collisions, broken line-comparison highlighting on insertions, no diff overview.

## 2026-07-08 — Review mode redesign: DiffviewOpen + direct file edits (SCRAPPED)

- Replaced scratch-buffer approach with DiffviewOpen-based review flow.
- `:OpenCodeReview` opened `DiffviewOpen` and stored baseline file contents.
- **Comment model**: user edits files directly in the working tree. `vim.diff()` detected changes.
- SCRAPPED same day: editing working tree files conflates review annotations with actual code changes. Files become dirty with both agent changes and review comments mixed together.

## 2026-07-08 — Review mode redesign v2: explicit comment entry

- Replaced file-diff model with explicit comment entry via `:OpenCodeReviewComment`.
- Flow: `:OpenCodeReview` → DiffviewOpen (visual diff browsing). User navigates to a line, runs `:OpenCodeReviewComment`, types comment text at prompt. Comments stored in memory (`M.comments[abs_path][line]`).
- `:OpenCodeReviewComplete` collects in-memory comments, writes `.omo/review-*.json`, sends to agent. No working tree files read or modified during comment collection.
- No baseline storage, no `vim.diff()`, no git file-list dependency for the comment flow.
- `:OpenCodeReviewComment` uses `vim.fn.expand("%:p")` to resolve the file path from the current buffer and `vim.fn.line(".")` for line number. Works from any buffer (Diffview or plain file buffer).
- **REVIEW mode indicator** in `lualine_a` (mode section), keyed on `vim.g.in_review_session`. Mode component's `fmt` is mutated to return "REVIEW" during sessions, preserving default mode display otherwise.

## 2026-07-08 — Applied review comment cleanup in docs/src/README.md

- Processed review file `.omo/review-20260708-140242.json`.
- Removed placeholder line `test` from `docs/src/README.md` (line 5 in review context).
- Scope intentionally minimal: no behavior/code-path changes, documentation text cleanup only.

## 2026-08-13 — nvf bump: rust lsp.package removed, ts renamed to typescript/tsx

- nvf commit a213644c removed `vim.languages.rust.lsp.package`. The toolchain rust-analyzer override now sets `vim.lsp.servers.rust-analyzer.cmd` instead.
- `vim.languages.ts` no longer exists in nvf; split into `typescript` (ts/js) and `tsx` (react/tsx). DashVim `lspServers` defaults updated accordingly, both with `lsp.enable = false` (typescript-tools.nvim owns the TS LSP).
- Full `nix eval` of `.#packages.x86_64-linux.default` succeeds after both changes.
## 2026-08-25 — avante.nvim as review handoff target

- Added `config/editor/avante.nix`: avante.nvim from nixpkgs (`vimPlugins.avante-nvim`, includes prebuilt Rust binary) with `plenary-nvim` + `nui-nvim` in startPlugins.
- Avante is lazy-loaded on its commands only (`cmd = [...]`): zero startup cost and no startup API-key prompt when unused.
- New review handoff: `:OpenCodeReviewAvante` / `<leader>ov` (`review.lua:complete_avante`) reuses comment collection + `.omo/review-*.json` writing, then calls `avante.api.ask({ question = ... })`. Session stays alive on handoff failure so `<leader>oe` (opencode) remains a fallback.
- nvf's `lzn-auto-require` auto-loads opt plugins on require; the explicit `lazy.load` call in `complete_avante` is belt-and-suspenders.
- Verified: `nix build .#default` passes; headless smoke test confirms `require("avante.api")`, `:AvanteAsk` registration, and `:OpenCodeReviewAvante` all work in the built package.
## 2026-08-25 — avante.nvim provider/model + opencode-parity instructions

- Default model: GitHub Copilot `gpt-5.6-terra` (`provider = "copilot"`, `use_response_api = true`, context_window 1048576, max_tokens 128000).
- Copilot auth needs no extra plugin: avante reads the OAuth token already present in `~/.config/github-copilot/{hosts,apps}.json` (written by copilot.lua/copilot.vim). If the stored refresh token is expired, a one-time re-auth is required.
- opencode parity for instructions: opencode always loads `~/.opencode/AGENTS.md` + all `~/.opencode/skills/*/SKILL.md` (opencode.json `instructions`). Avante equivalent: Nix builds `agentic.avanterules` from the SAME repo sources (`AGENTS.md`, `.opencode/skills/*/SKILL.md` — dynamic readDir, auto-picks up new skills) into a store dir wired via `rules.global_dir`. Avante injects it into every agentic-mode system prompt (path.lua find_rules). Project-root AGENTS.md is additionally read natively by avante.
- Divergence vs opencode: avante's rules take the FIRST found per mode (project `.avante/rules/agentic.avanterules` overrides global); opencode merges project + global. Injection covers agentic mode only (avante default).
