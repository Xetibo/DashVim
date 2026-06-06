# Testing

DashVim currently uses a flake-first verification strategy. Prefer the smallest command that covers the changed area, then use package builds for broader confidence.

## Current Strategy

- Use Nix evaluation to catch module, package, and generated-config errors early.
- Use Alejandra from the flake for Nix formatting checks.
- Use `git diff --check` to catch whitespace errors before handoff.
- Build package outputs when changes affect runtime packaging, dependencies, or generated wrappers.
- Build docs when changing documentation generation or option documentation.
- Evaluate generated opencode config when changing opencode integration.
- For project toolchain resolver changes, evaluate package outputs and build the default package to catch missing package attributes, option conflicts, and generated wrapper errors. If new files are not yet tracked by Git, direct Nix expressions may be needed to verify the resolver before flake builds can see those files.

## Common Commands

- `git diff --check`
- `nix run .#format -- --check <nix-files>`
- `nix eval .#packages.x86_64-linux.default.name`
- `nix eval .#packages.x86_64-linux.docs.name`
- `nix build .#default`
- `nix build .#docs`

For opencode config changes, evaluate the generated config where practical. Example shape:

```sh
nix eval --json --impure --expr '<expression returning opencodeFiles.opencodeConfig>'
```

## Known Gaps

- No dedicated unit test suite is documented for Lua config, custom plugins, or interactive Neovim flows.
- No dedicated integration test harness is documented for Home Manager activation.
- Manual smoke testing may still be needed for keybindings, UI behavior, and opencode runtime behavior after Nix evaluation succeeds.

## Expectations

- Report which checks were run in the final handoff.
- If a useful check cannot be run, state why.
- Prefer reproducible flake commands over ad hoc local tooling.
