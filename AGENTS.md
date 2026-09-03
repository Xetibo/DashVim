# Agent Instructions

## Project Docs

- Before code changes, read `docs/ARCHITECTURE.md`, `docs/UI.md`, `docs/CODE_GUIDELINES.md`, `docs/TECHNICAL_DEBT.md`, and `docs/TESTING.md` when they exist.
- If one of those files is missing, create it in `docs/` with current known facts before making related code changes.
- Update `docs/DECISIONS.md` for LLM specific continuity
- Update `docs/ARCHITECTURE.md` after adding or changing core functionality, module structure, public interfaces, or architecture decisions.
- Update `docs/UI.md` after adding or changing UI components, layouts, themes, colors, interaction patterns, or visual rules.
- Update `docs/CODE_GUIDELINES.md` when adding or changing conventions that future code should follow.
- Update `docs/TECHNICAL_DEBT.md` when discovering, adding, fixing, or intentionally deferring known issues, limitations, or cleanup work.
- Update `docs/TESTING.md` when adding, removing, or changing test strategy, verification commands, checks, or CI expectations.
- Important: Do not write component specific information into these files, only add important information into them. 
  For decicions and low impact information use DECISIONS.md

`docs/ARCHITECTURE.md` should document architecture decisions, current structure, module boundaries, important data flow, and known tradeoffs.

`docs/UI.md` should document UI guidelines and rules, including:

- UI library or framework in use, if any.
- General look and feel.
- Color patterns.
- Do's and don'ts.

`docs/CODE_GUIDELINES.md` should document code style, testing expectations, formatting rules, naming conventions, and repository-specific patterns.

`docs/TECHNICAL_DEBT.md` should list known issues, limitations, deferred work, and cleanup items that agents and developers should take into account.

`docs/TESTING.md` should explain the current testing strategy, expected verification commands, and known gaps in test coverage.

## Nix Compatibility

- Always check for `flake.nix` before changing code.
- If `flake.nix` exists, use it for development, formatting, tests, builds, and dependency checks where practical.
- If `flake.nix` is missing, create one before adding project tooling or dependencies.
- Keep software Nix-compatible in general. Prefer reproducible tooling, pinned inputs, and commands that work from the flake.
- Docker containers should generally be generated with Nix unless a Dockerfile already exists or explicit instructions say not to use Nix.

## Code Guidelines

- Prefer functional approaches over object-oriented designs where practical.
- Keep changes small and aligned with existing project style.
- Only add comments for code that is not self-explanatory.
