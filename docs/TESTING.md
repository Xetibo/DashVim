# Testing

DashVim currently uses a flake-first verification strategy. Prefer the smallest command that covers the changed area, then use package builds for broader confidence.

## Current Strategy

- Use Nix evaluation to catch module, package, and generated-config errors early.
- Use Alejandra from the flake for Nix formatting checks.
- Use `git diff --check` to catch whitespace errors before handoff.
- Build package outputs when changes affect runtime packaging, dependencies, or generated wrappers.
- For agent plugin changes, build the agent-enabled `default` and `minimal` outputs and smoke-test providers with headless Neovim.
- Run `nix develop -c python3 tests/codex-bridge.py ./result/bin/nvim` after building each agent-enabled output. This model-free test checks both transports and strict Codex parsing, native bounded/batched tools, unsaved contents, source-less diagnostics, atomic conflicts, save failures, saves without hooks, undo, new files, workspace confinement, model-cache fallback, instance isolation, and multiple RPC clients. It requires local Unix sockets but no authentication.
- Run `nix develop -c python3 tests/codex-latency-test.py` for synthetic rollout correlation, parallel-call timing, privacy, filtering, and incomplete-log handling.
- Run `./result/bin/nvim --headless -c 'lua local ok, err = pcall(dofile, "tests/agentic-review.lua"); if not ok then print(err); vim.cmd("cquit 1") end' -c 'qa!'` for agent review/session changes. It checks packaged keymaps and statusline, inline comments without source edits, JSON handoff after session readiness, failure retention, newest-project-session selection, and upstream restore cancellation with a stubbed ACP provider; no authentication is needed. `-l` skips normal startup, so use `-c` to exercise the packaged configuration.
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

## Opt-in Codex latency benchmarks

After building, run `nix develop -c python3 tests/codex-benchmark.py ./result/bin/nvim --samples 3`.
This sends authenticated model requests using the normal Codex home (`codex login`), in temporary editor/Git fixtures. It exercises ACP questions and saved edits, 99 code-only responses, and unchanged documentation fixtures. It does not change existing user source files. Use `--models <ids...>` to compare account-supported models, `--hosts acp` or `--hosts 99` to isolate a host, and `--keep-fixtures` to retain debug logs. Multiple models can take several minutes; allow enough command time.

Run `nix develop -c python3 tests/codex-latency.py <session-id...>` for existing rollout metrics, or use `--since <ISO-timestamp>`. Reports include total/first-token times, approval count/time, tool count/execution/wait, context tokens, medians, and p95/max. They omit prompts, source text, and tool arguments. Overlapping tool wait intervals are counted once. `--codex-home` selects an alternate home in both scripts.

Provisional small-fixture targets: question median below 15 seconds and focused edit median below 30 seconds. These are service-dependent measurements, not model-free CI thresholds. Compare repeated runs and slow cases; historical user tasks and synthetic fixtures are not identical workloads.

## Known Gaps

- Lua config and interactive Neovim flows have no general unit test suite; the Codex MCP bridge has a focused headless integration test.
- No dedicated integration test harness is documented for Home Manager activation.
- Local tests cannot establish model-side behavior or service latency. The opt-in benchmark exercises live ACP sessions and 99 CLI responses, but not the full interactive widget path.
- Manual smoke testing may still be needed for keybindings, UI behavior, and opencode runtime behavior after Nix evaluation succeeds.

## Expectations

- Report which checks were run in the final handoff.
- If a useful check cannot be run, state why.
- Prefer reproducible flake commands over ad hoc local tooling.
