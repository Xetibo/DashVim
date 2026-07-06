# UI Guidelines

DashVim's UI is a terminal Neovim interface configured through `nvf`, plus an opencode TUI theme generated from the same color palette.

## Libraries And Frameworks

- Neovim configuration is built with `nvf`.
- Editor UI features are provided by plugins configured under `config/editor/`, including dashboard, telescope, file tree, statusline, mini, git, miscellaneous editor integrations, and opencode-nvim.
- Documentation UI is built with `mdbook` through `docs/default.nix`.
- Opencode TUI colors are generated as `dashvim.json` by `lib/opencode-config.nix`.

## Look And Feel

- Prefer cohesive terminal-first UI that works in standard terminal emulators and Neovide.
- Keep visual defaults compact and keyboard-driven.
- Preserve existing DashVim navigation conventions and leader-key patterns when adding UI interactions.
- Avoid visual noise in editor surfaces; prioritize readable buffers, diagnostics, completion menus, and search results.

## Color Patterns

- Use Base16 palette keys as the shared color contract.
- Default palette is Catppuccin-like, with `base00` as background, `base05` as primary text, `base0D` as primary/accent blue, `base0E` as secondary purple, `base0C` as cyan accent, `base0B` as success green, `base09` as warning peach, and `base08` as error red.
- Use `programs.dashvim.accentColor` when the primary accent should differ from `base0D`.
- Keep opencode theme colors aligned with the Neovim palette unless a feature has a clear reason to diverge.
- Opencode TUI backgrounds (`background`, `backgroundPanel`, `backgroundElement`, and diff background fields) should use `base00` so the TUI surface matches Neovim's background instead of using transparent/`none` values.

## Do's

- Reuse configured theme colors instead of hardcoding unrelated colors.
- Keep UI modules small and grouped by feature under `config/editor/` or the relevant `config/` subtree.
- Update this file when adding components, layouts, themes, colors, interaction patterns, or visual rules.
- Document important keybinding changes in user-facing docs when they affect default workflows.

## Don'ts

- Do not introduce a second unrelated color system.
- Do not add UI defaults that only work in graphical environments unless there is a terminal-safe fallback.
- Do not replace existing navigation/keybinding conventions without a clear migration reason.
- Do not add decorative UI elements that reduce readability or diagnostic clarity.
