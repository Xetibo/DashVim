# Technical Debt

This file tracks known issues, limitations, deferred work, and cleanup items that agents and developers should account for when changing DashVim.

## Known Items

- README keybinding documentation says it may be outdated. Verify default keymaps in code before changing or relying on README keybinding tables.
- `programs.dashvim.opencode.config` is merged after generated defaults. If a user sets `instructions`, it can replace generated instruction paths such as `AGENTS.md` and bundled skills.
- Generated opencode files are reproducible but not hot-reloaded. Wrapped opencode and Home Manager users must rebuild or redeploy, then restart opencode after config inputs change.
- The `programs.dashvim` option surface is broad. Default changes can affect many editor, language, formatter, and opencode behaviors at once.
- Automated testing is currently Nix-focused. No separate unit/integration test suite is documented for Lua plugin behavior or interactive Neovim workflows.
- `programs.dashvim.toolchain.preferProjectTools` covers known DashVim/nvf LSP, formatter, and linter names. Custom direct `vim.lsp.servers`, conform formatter, or nvim-lint linter names still need explicit command configuration until a public extension map exists.

## Maintenance Rules

- Add newly discovered issues here when they are not fixed in the same change.
- Remove or update entries when debt is fixed or no longer accurate.
- Link debt to concrete files, options, or commands when possible.
