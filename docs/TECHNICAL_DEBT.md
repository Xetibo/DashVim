# Technical Debt

This file tracks known issues, limitations, deferred work, and cleanup items that agents and developers should account for when changing DashVim.

## Known Items

- README keybinding documentation says it may be outdated. Verify default keymaps in code before changing or relying on README keybinding tables.
- `programs.dashvim.opencode.config` is merged after generated defaults. If a user sets `instructions`, it can replace generated instruction paths such as `AGENTS.md` and bundled skills.
- Generated opencode files are reproducible but not hot-reloaded. Wrapped opencode and Home Manager users must rebuild or redeploy, then restart opencode after config inputs change.
- Home Manager deployment for `opencode/themes/dashvim.json` uses `lib.mkDefault`; user-managed files or higher-priority config can still override DashVim's generated theme/background behavior.
- The `programs.dashvim` option surface is broad. Default changes can affect many editor, language, formatter, and opencode behaviors at once.
- Automated testing is currently Nix-focused. No separate unit/integration test suite is documented for Lua plugin behavior or interactive Neovim workflows.
- `programs.dashvim.toolchain.preferProjectTools` covers known DashVim/nvf LSP, formatter, and linter names. Custom direct `vim.lsp.servers`, conform formatter, or nvim-lint linter names still need explicit command configuration until a public extension map exists.
- `programs.dashvim.lsp.special.roslyn.filewatching` defaults to `"off"` to prevent Roslyn or Neovim from recursively watching too much of the filesystem. DashVim adds a scoped client-side watcher (`vim._watch`) over the solution dir with churn directories excluded (`bin`/`obj`/`.git`/`node_modules`/`.vs`/`.roslyn-cache`/`.generated`), reconciling creates against a known-file set so externally-created project files are delivered as `Created`. This uses the internal underscore-prefixed `vim._watch` API (the same subsystem Neovim's own LSP watcher uses); it is wrapped in `pcall` and silently degrades to save-time-only notifications if that internal API changes. Watch depth/scope is bounded by the resolved solution root (`/` is refused), so a `broadSearch` miss or a top-level solution still never watches a home folder.
- `typescript-tools.nvim` does not expose a first-class plugin probe path option, so DashVim patches its generated process arguments to make Nix-provided `@angular/language-service` discoverable by tsserver. Revisit this if upstream adds `tsserver_plugin_probe_locations` or equivalent.

## Maintenance Rules

- Add newly discovered issues here when they are not fixed in the same change.
- Remove or update entries when debt is fixed or no longer accurate.
- Link debt to concrete files, options, or commands when possible.
