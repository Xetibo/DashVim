# Architecture

DashVim is a Nix flake that builds and distributes a Neovim configuration based on `nvf`. The flake exposes runnable packages, generated documentation, and reusable NixOS/Home Manager modules.

## Structure

- `flake.nix` is the main entry point. It wires inputs with `flake-parts`, defines supported systems, dev shells, packages, and exported modules.
- `modules/default.nix` defines the public `programs.dashvim` option surface, including colors, keybind toggles, LSP defaults, formatter defaults, opencode integration, and code companion settings.
- `lib/default.nix` calls `inputs.nvf.lib.neovimConfiguration` and passes DashVim options into the `config/` module tree through `extraSpecialArgs`.
- `config/default.nix` imports the Neovim configuration modules for base settings, theme, keybinds, editor features, language support, custom config, and user-provided `additionalConfig`.
- `config/languages/toolchain.nix` injects project-aware command resolvers for known DashVim/nvf LSPs, formatters, and linters when `programs.dashvim.toolchain.preferProjectTools` is enabled; `config/languages/lsp.nix` handles the TypeScript server path special case inside the owning plugin definition.
- `config/languages/lsp.nix` also owns plugin-backed LSP setup such as `typescript-tools.nvim` and `roslyn.nvim`; Roslyn file watching, targeted file-change notifications, broad solution search, and target locking are controlled through `programs.dashvim.lsp.special.roslyn.*`.
- `lib/env.nix` creates the runnable environment by combining the generated Neovim package, optional wrapped opencode package, and shared CLI/runtime dependencies.
- `lib/opencode-config.nix` generates opencode theme, TUI config, opencode config JSON, and bundled skills/commands for both wrapped opencode and Home Manager deployments.
- `lib/toolchain.nix` builds a Rust resolver and per-tool launch symlinks that prefer a different executable from the active Neovim `PATH` and fall back to DashVim's pinned Nix executable.
- `hm/default.nix` adapts DashVim for Home Manager and NixOS-style module consumers.
- `hm/opencode.nix` deploys opencode config files, skills, commands, and shared instructions into the user's home when opencode integration is enabled.
- `docs/default.nix` builds mdbook documentation from module options.

## Data Flow

- Users set `programs.dashvim.*` options through the exported module.
- Module options flow into `lib/default.nix` as `config'` and become inputs to the `config/` nvf module tree.
- The nvf output creates the Neovim package used by `lib/env.nix` and `lib/mkPkg.nix`.
- Toolchain preferences flow from `programs.dashvim.toolchain.preferProjectTools` into `config/languages/toolchain.nix`, which overrides active LSP commands and known formatter/linter commands with resolver scripts at Nix module priority 90. TypeScript's `tsserver_path` is resolved in `config/languages/lsp.nix` so the lazy plugin package metadata remains intact. Angular TypeScript support is loaded as the `@angular/language-service` tsserver plugin through `typescript-tools.nvim`; standalone Angular LS (`ngserver`) serves Angular template buffers and, inside Angular projects, TS/TSX references so they include external template usages.
- Roslyn preferences flow from `programs.dashvim.lsp.special.roslyn` into `roslyn.nvim` setup options. The default keeps recursion watch mode `"off"` (Roslyn is advertised LSP dynamic registration, so its native recursive watcher stays inactive). DashVim supplements this with a scoped, client-side watcher (`vim._watch`) rooted at the Roslyn solution dir with build/churn directories excluded (`bin`/`obj`/`.git`/`node_modules`/`.vs`/`.roslyn-cache`/`.generated`) and file extensions restricted to project files. It reconciles creates that the watch layer mislabels as "Changed" against a known-file set so externally-created project files still reach Roslyn as `Created`, alongside the targeted `workspace/didChangeWatchedFiles` notifications DashVim still sends when C# project files are saved in Neovim. Users can opt into `"auto"` or `"roslyn"` only when full external file watching is more important than watcher safety.
- Shared dependencies are collected in `lib/dependencies.nix` and reused by flake packages and Home Manager integration; DAP debug adapters (`vscode-js-debug` for Chrome/Node, `firefox-debugadapter` for Firefox) are built from source there.
- Opencode theme generation uses the configured Base16 colorscheme and optional accent color, then writes generated JSON files through `lib/opencode-config.nix`.
- Wrapped opencode sets `OPENCODE_CONFIG`, `OPENCODE_CONFIG_DIR`, and `OPENCODE_TUI_CONFIG`, and force-copies the generated `dashvim` theme into `$XDG_CONFIG_HOME/opencode/themes` at runtime so theme updates are applied consistently.

## Architecture Decisions

- Flake-first development: builds, package outputs, dependencies, and generated docs are expected to work through `flake.nix`.
- Functional Nix modules: configuration is composed from small Nix modules and functions instead of object-oriented abstractions.
- Shared opencode generation: wrapped opencode and Home Manager use `lib/opencode-config.nix` to avoid divergent config generation.
- Default opencode plugin stack now includes `oh-my-openagent` (via `programs.dashvim.opencode.plugin`) instead of `micode`, keeping plugin selection configurable through module options.
- Base16 color contract: UI themes and opencode colors derive from a Base16-compatible palette, with `accentColor` overriding `base0D` when set.
- Opencode background contract: `dashvim` theme background-related fields use `base00` (not `none`) so opencode TUI background matches Neovim's base background.
- Global agent instructions: `AGENTS.md` is included in root opencode config, the wrapped opencode instruction paths, and Home Manager deployed opencode instructions. It requires architecture, UI, code guidelines, technical debt, and testing docs to stay current.
- Runtime mode switching (copilot vs free) uses per-session temp config dirs: the Lua plugin creates `/tmp/opencode-nvim-{uuid}/opencode/` with symlinks to global configs and a mode-specific `oh-my-openagent.jsonc`, then launches opencode with `XDG_CONFIG_HOME` overridden. No shared file writes — zero clash between concurrent Neovim sessions.
- Review module (`opencode.review`) uses `DiffviewOpen` for visual diff browsing and explicit `:OpenCodeReviewComment` command for adding annotations. `:OpenCodeReview` opens `DiffviewOpen` and sets `vim.g.in_review_session = true` for statusline mode detection. User runs `:OpenCodeReviewComment` on any line to type a comment (stored in memory keyed by absolute path + line number). `:OpenCodeReviewComplete` collects in-memory comments, writes `.omo/review-*.json`, and sends the file path to the opencode terminal. No working tree files are modified during review. No scratch buffers, no baseline storage, no `vim.diff()`.
- Project tool preference is enabled by default: known LSPs, formatters, and linters first look for a project/shell executable that differs from DashVim's pinned fallback, preserving reproducibility when a project does not provide a tool.
- Angular/TypeScript LSP ownership is split to avoid duplicate results while keeping template-aware features: `typescript-tools.nvim` owns JavaScript/TypeScript/TSX buffers (completion, diagnostics, hover, etc. via its tsserver + Angular tsserver plugins). Standalone `ngserver` owns every Angular template buffer (both the stock `html` filetype and the `htmlangular` marker) and, inside Angular projects (`angular.json`/`nx.json` root marker), attaches to `typescript`/`typescriptreact` as a references-only companion so that `.ts` references include usages in external `.html` template files. ngserver's `on_attach` neuters any vanilla HTML LSP on template buffers (sole template provider) and disables its own non-reference providers on TS/TSX buffers (typescript-tools stays primary); typescript-tools likewise gives up `referencesProvider` in Angular projects to avoid double-served references.

## Tradeoffs

- Generated opencode configs are reproducible, but users must rebuild or redeploy after changing generated inputs.
- `programs.dashvim.opencode.config` can override generated opencode config keys, which is flexible but can replace defaults like `instructions` if users set the same key.
- The module surface is broad and convenient, but changes to defaults can affect many language/editor features at once.
- Project-aware tool resolution depends on Neovim seeing the project shell `PATH` before tools start. LSPs may need restart after entering a shell late.
- Recursive Roslyn file watching may consume significant inotify resources or watch too high a directory such as a home folder. DashVim avoids that by default with a scoped watcher that excludes churn directories and roots at the solution dir. Residual gaps: files created outside Neovim in brand-new directories are caught by the watcher, but because `vim._watch` is an internal underscore-prefixed API, the whole watcher is wrapped in `pcall` and silently degrades to save-time notifications if that API changes.
