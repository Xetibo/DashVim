# Code Guidelines

## General

- Prefer small, focused changes that match existing Nix style.
- Prefer functional composition through Nix modules and functions over object-oriented patterns.
- Keep public options in `modules/default.nix` documented with useful descriptions and examples.
- Keep implementation modules grouped by feature under `config/`, `lib/`, `hm/`, and `modules/`.
- Add comments only when code is not self-explanatory or when documenting a non-obvious tradeoff.

## Nix

- Check for `flake.nix` before changing code and use it for development commands where practical.
- Keep new tooling and dependencies reproducible through the flake.
- Prefer pinned flake inputs or existing package sets over ad hoc downloads.
- Keep Docker/container support Nix-generated unless a Dockerfile already exists or explicit instructions say not to use Nix.
- Use `alejandra` for Nix formatting, available as the flake `format` package.
- Keep project tool resolver runtime logic in tracked Rust source under `lib/toolchain/`; Nix should wire package metadata and generated launchers, not embed large resolver programs in strings.
- Keep plugin-backed LSP behavior with large runtime tradeoffs configurable under `programs.dashvim.lsp.special.*` instead of hard-coding environment-specific defaults.

## Testing And Verification

- Use `docs/TESTING.md` as the source of truth for current test strategy and expected checks.
- Run the smallest useful Nix command for the change, such as evaluating generated config, building a package, or running formatter checks.
- For opencode config changes, evaluate generated `opencodeConfig` where practical and preserve the schema field.
- For module changes, verify option evaluation or relevant package builds where practical.
- State any verification that could not be run and why.

## Documentation

- Read `docs/ARCHITECTURE.md`, `docs/UI.md`, this file, `docs/TECHNICAL_DEBT.md`, and `docs/TESTING.md` before related code changes.
- Create missing required docs files before making related changes.
- Update `docs/ARCHITECTURE.md` for core functionality, module structure, public interfaces, or architecture decisions.
- Update `docs/UI.md` for UI components, layouts, themes, colors, interaction patterns, or visual rules.
- Update `docs/TECHNICAL_DEBT.md` when discovering, adding, fixing, or intentionally deferring known issues, limitations, or cleanup work.
- Update `docs/TESTING.md` when test strategy, verification commands, checks, or CI expectations change.
- Update this file when repository conventions change.
