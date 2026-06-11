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
- Toolchain preferences flow from `programs.dashvim.toolchain.preferProjectTools` into `config/languages/toolchain.nix`, which overrides active LSP commands and known formatter/linter commands with resolver scripts at Nix module priority 90. TypeScript's `tsserver_path` is resolved in `config/languages/lsp.nix` so the lazy plugin package metadata remains intact. Angular TypeScript support is loaded as the `@angular/language-service` tsserver plugin through `typescript-tools.nvim`; standalone Angular LS is reserved for Angular template buffers.
- Roslyn preferences flow from `programs.dashvim.lsp.special.roslyn` into `roslyn.nvim` setup options. The default keeps recursive file watching `"off"` so Roslyn and Neovim do not create broad watchers, and DashVim sends targeted `workspace/didChangeWatchedFiles` notifications when C# project files are saved. Users can opt into `"auto"` or `"roslyn"` only when full external file watching is more important than watcher safety.
- Shared dependencies are collected in `lib/dependencies.nix` and reused by flake packages and Home Manager integration.
- Opencode theme generation uses the configured Base16 colorscheme and optional accent color, then writes generated JSON files through `lib/opencode-config.nix`.

## Architecture Decisions

- Flake-first development: builds, package outputs, dependencies, and generated docs are expected to work through `flake.nix`.
- Functional Nix modules: configuration is composed from small Nix modules and functions instead of object-oriented abstractions.
- Shared opencode generation: wrapped opencode and Home Manager use `lib/opencode-config.nix` to avoid divergent config generation.
- Base16 color contract: UI themes and opencode colors derive from a Base16-compatible palette, with `accentColor` overriding `base0D` when set.
- Global agent instructions: `AGENTS.md` is included in root opencode config, the wrapped opencode instruction paths, and Home Manager deployed opencode instructions. It requires architecture, UI, code guidelines, technical debt, and testing docs to stay current.
- Project tool preference is enabled by default: known LSPs, formatters, and linters first look for a project/shell executable that differs from DashVim's pinned fallback, preserving reproducibility when a project does not provide a tool.
- Angular language ownership is split to avoid duplicate TypeScript LSP results: `typescript-tools.nvim` owns JavaScript/TypeScript buffers and loads Angular's tsserver plugin, while standalone `ngserver` owns `htmlangular` buffers and TypeScript references in Angular projects so references include external templates.

## Tradeoffs

- Generated opencode configs are reproducible, but users must rebuild or redeploy after changing generated inputs.
- `programs.dashvim.opencode.config` can override generated opencode config keys, which is flexible but can replace defaults like `instructions` if users set the same key.
- The module surface is broad and convenient, but changes to defaults can affect many language/editor features at once.
- Project-aware tool resolution depends on Neovim seeing the project shell `PATH` before tools start. LSPs may need restart after entering a shell late.
- Recursive Roslyn file watching may consume significant inotify resources or watch too high a directory such as a home folder. DashVim avoids that by default, but files created outside Neovim may still require opening/saving the file or restarting the LSP before Roslyn refreshes project state.
