# Decisions

## 2026-10-02 — Standalone agent seed + Codex global config

- Added `lib/standalone-agent.nix`: builds the `~/.config/agents/agentic.md` seed from repo sources (`AGENTS.md` + all `.opencode/skills/*/SKILL.md`, currently caveman + compact-context, auto-picks up new skills like avante's reader). Per user choice, opencode instructions were replaced (not appended): HM, wrapped, and repo-root `opencode.json` now list only `~/.config/agents/agentic.md`.
- Added `hm/agents.nix` + `home.activation.agenticSeed` (gated on `opencode.enable || agent.enable`): seeds the shared file copy-if-missing (user-editable afterwards, `chmod u+rw`) and symlinks standalone Codex global instructions (`~/.codex/AGENTS.md`, symlink-if-missing per user choice) at it. Nix never overwrites either destination; existing `~/.codex/config.toml` (trust levels etc.) is untouched. Editor-hosted Codex (agentic.nvim, 99) keeps scoped `lib/codex-editor.nix` instructions and does not read this file.
- `lib/env.nix` wrapped opencode also seeds the shared file at runtime when missing, so `nix run` without Home Manager still works.
- Verified: `nix eval` of seed content (7112 bytes, both skills), generated opencode instructions, and activation script; `nix eval .#packages.x86_64-linux.default.name`; sandboxed copy/symlink rerun test (edits preserved); `alejandra` format + `git diff --check`. No `nix build` or bridge test run (heavy).

## 2026-10-01 — Save direct Codex buffer edits

- User confirmed live MCP editing works and requested that edited buffers be saved. Replaced the shared leave-unsaved instruction with a native `nvim_buf_call` / `noautocmd update` save after editing each named file buffer. This saves existing buffer content too, preserves undo, skips write autocommands under the no-validation policy, and reports failures without forcing writes. Only edited buffers are saved; 99 visual replacements remain owned by 99.
- Updated bridge coverage to include explicit native saving and undo after saving. Tests/builds were not run in this editor session. Rebuild/redeploy and restart the provider to load the new generated instructions.

## 2026-10-01 — Pass ACP configuration through CODEX_CONFIG

- Inspected the installed `@agentclientprotocol/codex-acp` 1.13.1 adapter: its ACP entry point ignores CLI `-c` arguments and reads session overrides from JSON in `CODEX_CONFIG`. The installed Neovim config already contained the intended arguments, so rebuilding the previous configuration alone would not fix missing MCP tools, editor instructions, or bundled Caveman/Compact Context content.
- Agentic now supplies the shared settings and per-editor MCP server through its provider environment. 99 still passes CLI overrides directly to `codex exec`. Both use the same socket and server settings helper; no global Codex configuration is changed.
- Updated the bridge test to compare ACP environment JSON with CLI settings. Its earlier CLI parser check did not exercise the ACP adapter and therefore missed this mismatch. No tests or builds were run for this correction; an authenticated ACP session remains unverified. Rebuild/redeploy and restart the editor/provider to pick up the fix.

## 2026-10-01 — Linked buffer edit attempt

- This session exposed no Neovim MCP tools and shell discovery found no running Neovim process. Added a test line to `test.md` on disk; live buffer synchronization could not be confirmed.

## 2026-10-01 — Existing Neovim MCP bridge for Codex

- Added [linw1995/nvim-mcp](https://github.com/linw1995/nvim-mcp), pinned at `986be68135a05ebdb727e73e609ffda0bbbbfdf6` as a source-only flake input. `lib/nvim-mcp.nix` builds its Rust server with DashVim's existing nixpkgs toolchain and upstream Cargo.lock; no runtime downloads or second Rust toolchain input.
- `config/editor/codex-bridge.nix` packages the upstream Lua module and DashVim's small launcher helper. `dashvim.codex-bridge.args` opens one private temporary RPC socket per Neovim process, reuses it for both hosts, and passes a required stdio MCP server using `--connect <exact-socket>`. No global MCP config, project auto-discovery, or TCP listener. The socket closes on editor exit.
- Both Codex ACP and 99 use that helper. Native MCP `read` with buffer IDs sees unsaved contents; `exec_lua` exposes Neovim's buffer editing and undo APIs, and the bridge supplies LSP navigation/diagnostic tools. Instructions prefer these tools, require conflict checks, preserve dirty buffers, and leave saving to the user. 99 visual replacements still go through 99's response contract; vibe uses live-buffer edits.
- Editor-scoped launch flags disable Codex shell/unified-exec tools; MCP formatting/import-organization tools are filtered out. No-validation policy also covers process execution through `exec_lua`. This is an editor behavior policy, not a Lua security sandbox. Direct MCP edits do not use ACP patch previews.
- `tests/codex-bridge.py` exercises the actual built MCP server and live Neovim instances over stdio/Unix RPC, without a model call. It also verifies generated ACP/CLI arguments agree and retain Caveman/no-validation instructions.
- Verified: default and minimal packages build; both pass the live bridge test, including Codex CLI configuration parsing, unsaved reads/edits, diagnostics, undo, unchanged disk content, and two-instance isolation. Nix formatting and whitespace checks pass. No authenticated model request was made.

## 2026-10-01 — Codex editor policy and bundled skills

- `lib/codex-editor.nix` reuses the tracked Caveman and Compact Context skills for both Codex hosts via `-c developer_instructions=...`. Caveman is active for prose; Compact Context is on request. No global config/home writes or runtime plugin downloads; standalone Codex is unaffected.
- Both hosts instruct Codex to stay within the editor request, skip all validation, avoid autonomous workflows, and never perform shell-based edits. Read-only shell discovery is a fallback when supplied context/native readers are insufficient. This is behavioral policy, not a security sandbox.
- agentic.nvim uses direct native `apply_patch`, which pinned codex-acp exposes and reports through ACP tool/diff events. Do not advertise fictional buffer tools: the pinned client explicitly disables ACP `fs` and the adapter has no corresponding filesystem forwarding. Unsaved-buffer conflicts must be preserved, not overwritten.
- 99's packaged Codex provider loads generated launch args and a pinned CLI path from `99.codex-config`. Visual replacements remain code-only for 99 to apply; search/vibe retain location records. The CLI owns TEMP_FILE through `--output-last-message`, so instructions explicitly prevent the model from writing that file itself and then overwriting it with a final prose summary.
- Codex launch configuration follows the official [developer_instructions reference](https://developers.openai.com/codex/config-reference/). User-supplied `agent.config` and `ninetyNine.providerExtraArgs` retain their existing override behavior.
- Verified both agent-enabled flake outputs build, both pass headless provider/config smoke checks, and generated CLI instruction arguments parse as TOML with exact text round-tripping. Formatting and whitespace checks pass. Live model behavior was not exercised.

## 2026-10-01 — Codex CLI and ACP agent options via nixpkgs

- Agent-enabled environments carry `pkgs.codex` and `pkgs.codex-acp` along with the existing GitHub Copilot CLI and OpenCode. The flake sets its intended `agent.enable = true` on the actual default module (rather than only in a local value), passes each output's agent flag to its wrapper, and gates agentic.nvim on that flag. No new flake input or ad hoc runtime download.
- 99's pinned upstream providers do not include Codex; install `config/editor/codex-provider.lua` in the plugin and register it when setup options are evaluated so the existing provider picker can discover it. The CLI writes its final message to 99's expected temp file; default model is `gpt-5.3-codex`. A null `ninetyNine.model` now means use the selected provider's default, except OpenCode retains its working `opencode/big-pickle` override.
- `agent.variant = "codex"` selects the existing agentic.nvim `codex-acp` adapter; `codex-acp` command is pinned to the nixpkgs binary, while the Copilot-only initial model remains scoped to Copilot. Existing provider switchers keep OpenCode and Copilot available; users authenticate with Codex separately.

## 2026-09-18 — markdown-preview.nvim via Nix (`programs.dashvim.markdownPreview`)

- New `programs.dashvim.markdownPreview` subtree in `modules/default.nix` (after the agent block): `enable` (default true), `port`/`theme`/`browser` (g:mkdp_port/theme/browser), `autoStart` false / `autoClose` true / `combinePreview` false, `filetypes` `[markdown]`, `extraConfig` (attrsOf anything, overrides generated globals). Wired in `config/editor/markdown-preview.nix` (imported from `config/editor/default.nix`); also removed stale `mkdp_auto_start=true` from `config/base.nix`, which would have collided and hijacked the browser on every markdown buffer.
- Server provisioning: pinned nixpkgs only ships a bare `buildVimPlugin` (no server). Upstream `app/install.sh` downloads a pkg-bundled node binary from releases; the Nix store is read-only so the plugin can never self-install — `config/editor/markdown-preview.nix` builds it instead: release tarball v0.0.10 + plugin src rev `a923f5fc`, binary placed at the contract path `app/bin/markdown-preview-linux`.
- The binary is opaque to patching, proven empirically: patchelf corrupts it (rewritten headers shift pkg's embedded payload offsets → prelude SyntaxError), and an explicit-loader wrapper breaks it differently (pkg locates its snapshot via /proc/self/exe, which then points at the loader → "Pkg: Error reading from file"). Two more hidden contracts found by testing: `app/index.js` chdirs into `process.execPath` stripped by `/(markdown-preview.nvim.*?app).+?$/`, so the binary must live under a `markdown-preview.nvim.../app/...` store path; and the server resolves `out/404.html` relative to cwd, so the derivation carries the full app tree (out/, _static, pages, server.js). Final shape: pristine binary + app tree in one derivation (`dontStrip`, `dontPatchELF`), executed through a `buildFHSEnv` bubble (glibc, gcc.cc.lib, zlib) so `/lib64/ld-linux` exists and the binary keeps its exe identity.
- `<leader>mm` (normal mode, gated on `useDefaultKeybinds`, confirmed free) maps to `:MarkdownPreviewToggle` — native start/stop toggle; second toggle stops preview and server. Verified headless against the built package: command exists, keymap resolves, toggle serves the preview page (`/page/1` → 200; `/` → 404 is normal upstream routing), server dies with the session.
- Caveat: the FHS bubble needs user namespaces; fixed-output hashes involved are the plugin src, server tarball, and (transitively) the FHS env inputs.

## 2026-09-17 — Angular LSP wiring rewritten from scratch (`config/languages/angular.nix`)

- Supersedes the 2026-08-10 static split-ownership model. All Angular LSP concerns now live in `config/languages/angular.nix`: corrected `ngserver` cmd, race-free filetype detection, and an `LspAttach` reconciler. `config/languages/lsp.nix` keeps only the `typescript-tools.nvim` plugin patch + `tsserver_path`; its Angular server block, TS references give-up, and stale commented `ts-ls` block are gone. The `BufEnter *.html` filetype hack in `config/autocmds.nix` and `config/luaFunctions.nix` are deleted.
- Root causes fixed: (1) filetype was set on `BufEnter` from the git-root cwd — too late, raced LSP attach, missed `nx.json`; now `vim.filetype.add` pattern on `.*%.html` runs during `BufRead` from the file's own dir upward over `angular.json`/`nx.json`, before any LSP attaches. (2) The custom cmd passed the same malformed probe list for both flags; now `--tsProbeLocations` gets `<node_modules>/typescript`-shaped entries and `--ngProbeLocations` gets `node_modules`-shaped entries (mirroring the nixpkgs wrapper), project `node_modules` first, Nix store fallbacks second, nonexistent paths skipped via `fs_stat`. (3) `--angularCoreVersion` was always passed even when empty, disabling ngserver's own version handling (upstream issue #3859); now omitted unless `DashVimAngular.core_major` resolves a major from installed `node_modules/@angular/core/package.json` (preferred, exact) or the `package.json` range. (4) Static root-guessing split ownership replaced by a reconciler that decides from actually-attached clients: when `angular` is present in an Angular project, `typescript-tools` yields `referencesProvider` (single references source, no doubles); angular is neutered to references-only on `typescript`/`typescriptreact` and the vanilla `html` client alone is neutered on template buffers (tailwind and other companions untouched). If angular fails to start, typescript-tools keeps references (graceful degradation).
- Verified end-to-end with the built package: `*.component.html` in an `angular.json` root opens as `htmlangular` pre-attach with the `angular` client attached; plain `.html` outside stays `html`; on `.ts` buffers capabilities settle to `angular refs=true def=false`, `typescript-tools refs=false def=true`; `textDocument/definition` on `{{ title }}` in a template resolves to the `title` field in the component `.ts` (real project with installed `@angular/core` 22 + TS 5.9).

## 2026-09-09 — ThePrimeagen/99 via Nix, gated on agent.enable

- Added `programs.dashvim.agent.ninetyNine` subtree in `modules/default.nix` covering all 99 `setup` opts (provider enum, model, providerExtraArgs, tmpDir, mdFiles, displayErrors, autoAddSkills, logger.*, completion.*, inFlight.*, extraConfig override). Null-typed options pass through to 99 defaults instead of forcing values.
- `config/editor/ninetynine.nix` builds 99 with `buildVimPlugin` (pinned rev `c174224`), `setupModule = "99"`, gated on `agent.enable && agent.ninetyNine.enable`. Lua-only values (provider table, logger level, default log path) use `lib.mkLuaInline`; pure Nix config stays in the module.
- Keybinds on `<leader>n` in `config/keybinds.nix` (`nV` vibe in normal mode, `nv` visual in visual mode only, plus search/open/logs/stop/clear/model/provider), with `+99` whichKey group. All gated on the same flags so no dead maps exist when agents are off.

## 2026-09-03 — Copilot ACP project-document deployment

- `hm/default.nix` deploys the OpenCode continuity documents (`DECISIONS.md`, `ARCHITECTURE.md`, `UI.md`, `CODE_GUIDELINES.md`, `TECHNICAL_DEBT.md`, and `TESTING.md`) beside `.github/copilot-instructions.md`, directly under `.github/`.
- `hm/copilot-instructions.md` provides a single shell command that reads each deployed document into Copilot's context before code changes.
- Rationale: keep Copilot ACP's repository guidance aligned with the instruction set used for OpenCode without requiring access to the original DashVim checkout.

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
## 2026-08-26 — csharpier formatter: explicit args override for CSharpier 1.x CLI

- Symptom: `Formatter 'csharpier' error: Unrecognized command or argument 'csharpier'.`
- Root cause: conform.nvim's built-in csharpier def targets the legacy `dotnet <csharpier.dll>` wrapper (`command = "dotnet"; args = {"csharpier", "--write-stdout"}`). DashVim's toolchain overrides only `command` (nix resolver passthrough → nixpkgs `csharpier` 1.3.0); conform merges user config over built-in per-key, so the stale built-in `args` survived and produced `<csharpier 1.x> csharpier --write-stdout`, which the System.CommandLine-based 1.x CLI rejects.
- Fix: `lib/toolchain.nix` formatters map now redefines the full `csharpier` entry with explicit `args = ["format" "--write-stdout" "--stdin-path" "$FILENAME"]`. conform placeholder syntax is shell-style `$FILENAME` (no braces) — `${FILENAME}` is passed through literally and made CSharpier throw `ArgumentNullException (directoryPath)` before the correction. Other formatters unchanged (command-only override still fine for them).
- Rejected: conform `pipe-files` subcommand — long-running multi-file protocol, unusable for conform's stdin mode.
- Verified via nix eval of `lib/toolchain.nix` formatters + direct CLI stdin test; resolver passthrough unchanged.
## 2026-09-09 — pin editor TypeScript stack to typescript_5 (5.9.3)

- nixpkgs unstable `typescript` is now 7.x (Go-native: `tsc` binary only, no `tsserver.js`/`tsserverlibrary.js`, no JS API). `typescript-tools.nvim` and `ngserver` both spawn tsserver under node, so `config/languages/lsp.nix` `pinnedTsserverPath`/`typescriptRoot` now point at `pkgs.typescript_5` (5.9.3, classic JS layout — verified `tsserver.js` exists in the store path).
- CLI/toolchain `tsc` fallback (`lib/toolchain.nix`) intentionally stays on TS 7; editor-vs-CLI version skew is benign since `preferProjectTools` (default `true`) resolves project-local TS first.
- Native `tsc --lsp` migration deferred: no tsserver plugin mechanism means losing `@angular/language-service`, styled, effect, and eslint plugins in TS buffers; Microsoft itself advises Angular projects to keep old-TS editor support. Revisit when Angular LS supports TS 7 or `typescript_5` leaves nixpkgs.
## 2026-09-09 — 99 OpenCode default model: opencode/big-pickle

- Symptom: every 99 query failed with "OpenCodeProvider make_query failed: process exit code: 1".
- Root cause: 99's hardcoded OpenCode default model `opencode/claude-sonnet-4-5` is not a valid model id (`opencode run` fails with `ProviderModelNotFoundError: Model not found: opencode/claude-sonnet-4-5`; verified via `--print-logs`). DashVim's `ninetyNine.model` defaulted to null, falling through to the broken upstream default.
- Fix: `ninetyNine.model` now defaults to `opencode/big-pickle` (verified `opencode run --agent build -m opencode/big-pickle` exits 0). Other providers' upstream defaults untouched.
