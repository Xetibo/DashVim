# Testing

DashVim currently uses a flake-first verification strategy. Prefer the smallest command that covers the changed area, then use package builds for broader confidence.

## Current Strategy

- Use Nix evaluation to catch module, package, and generated-config errors early.
- Use Alejandra from the flake for Nix formatting checks.
- Use `git diff --check` to catch whitespace errors before handoff.
- Build package outputs when changes affect runtime packaging, dependencies, or generated wrappers.
- For agent plugin changes, build the agent-enabled `default` and `minimal` outputs and smoke-test providers with headless Neovim.
- Run `nix develop -c python3 tests/codex-bridge.py ./result/bin/nvim` after building each agent-enabled output. This local MCP integration test starts two Neovim instances and checks both launchers' configuration, unsaved reads, buffer edits, diagnostics, unchanged disk content before saving, native saves, undo after saving, and socket isolation. It requires permission to bind local Unix sockets; no model requests or authentication are used.
- Build docs when changing documentation generation or option documentation.
- Evaluate generated opencode config when changing opencode integration.
- For project toolchain resolver changes, evaluate package outputs and build the default package to catch missing package attributes, option conflicts, and generated wrapper errors. If new files are not yet tracked by Git, direct Nix expressions may be needed to verify the resolver before flake builds can see those files.

## Common Commands

- `git diff --check`
- `nix run .#format -- --check <nix-files>`
- `nix eval .#packages.x86_64-linux.default.name`
- `nix eval .#packages.x86_64-linux.docs.name`
- `nix build .#default`
- `nix build .#minimal`
- `nix build .#docs`

## Headless Angular LSP smoke test

After `nix build .#packages.x86_64-linux.default` (refreshes `./result`), with a
fixture project rooted at an `angular.json`:

- Filetype (must print `htmlangular`, before any LSP attaches):
  `./result/bin/nvim --headless <root>/src/app/app.component.html -c 'lua print(vim.bo.filetype)' -c 'qa!'`
- Attach + ownership on a `.ts` buffer (expect `angular refs=true def=false`,
  `typescript-tools refs=false def=true`):
  `./result/bin/nvim --headless <root>/src/app/app.component.ts -c 'lua vim.wait(60000, function() return #vim.lsp.get_clients({bufnr=0}) >= 2 end) for _, c in ipairs(vim.lsp.get_clients({bufnr=0})) do print(c.name .. " refs=" .. tostring(c.server_capabilities.referencesProvider) .. " def=" .. tostring(c.server_capabilities.definitionProvider)) end' -c 'qa!'`
- Template goto-definition needs installed `@angular/core` in the fixture;
  `vim.lsp.buf_request_sync(0, "textDocument/definition", ...)` on an
  interpolation should return a `LocationLink` into the component `.ts`.

For opencode config changes, evaluate the generated config where practical. Example shape:

```sh
nix eval --json --impure --expr '<expression returning opencodeFiles.opencodeConfig>'
```

## Known Gaps

- Lua config and interactive Neovim flows have no general unit test suite; the Codex MCP bridge has a focused headless integration test.
- No dedicated integration test harness is documented for Home Manager activation.
- The bridge test compares ACP provider environment JSON (`CODEX_CONFIG`) with direct CLI overrides. It starts the MCP server directly, not an authenticated ACP model session, so it cannot establish that the adapter delivers all settings and tools to a live model. CLI parsing alone does not validate ACP configuration transport.
- Manual smoke testing may still be needed for keybindings, UI behavior, and opencode runtime behavior after Nix evaluation succeeds.

## Expectations

- Report which checks were run in the final handoff.
- If a useful check cannot be run, state why.
- Prefer reproducible flake commands over ad hoc local tooling.
