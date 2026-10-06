"""Exercise the packaged MCP bridge against two live, unsaved Neovim buffers."""

import contextlib
import json
import os
from pathlib import Path
import queue
import subprocess
import sys
import tempfile
import threading
import time
import tomllib


def launch(stack, command, **kwargs):
    proc = subprocess.Popen(command, **kwargs)

    def stop():
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()

    stack.callback(stop)
    return proc


class MCP:
    def __init__(self, proc, initialize=True):
        self.proc = proc
        self.messages = queue.Queue()
        self.next_id = 0

        def read():
            for line in proc.stdout:
                self.messages.put(json.loads(line))
            self.messages.put(None)

        threading.Thread(target=read, daemon=True).start()
        if initialize:
            self.request("initialize", {
                "protocolVersion": "2025-03-26",
                "capabilities": {},
                "clientInfo": {"name": "dashvim-smoke", "version": "1"},
            })
            self.send({"method": "notifications/initialized"})

    def send(self, message):
        self.proc.stdin.write(json.dumps({"jsonrpc": "2.0", **message}) + "\n")
        self.proc.stdin.flush()

    def request(self, method, params, allow_error=False):
        self.next_id += 1
        self.send({"id": self.next_id, "method": method, "params": params})
        while True:
            message = self.messages.get(timeout=20)
            assert message is not None, "MCP exited before responding"
            if message.get("id") == self.next_id:
                if "error" in message and allow_error:
                    return message
                assert "error" not in message, message
                return message["result"]

    def tool(self, name, **args):
        result = self.request("tools/call", {"name": name, "arguments": args})
        assert not result.get("isError"), result
        return result["content"][0]["text"]


def start_editor(stack, binary, root, index):
    directory = root / str(index)
    directory.mkdir()
    source = directory / "buffer.txt"
    source.write_text("saved on disk\n")
    ready = directory / "ready.json"
    script = directory / "start.lua"
    script.write_text(f"""
vim.cmd.edit(vim.fn.fnameescape({json.dumps(str(source))}))
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {{"unsaved editor {index}"}})
vim.diagnostic.set(vim.api.nvim_create_namespace("bridge-test"), buf, {{
  {{ lnum = 0, col = 0, message = "existing diagnostic", source = "bridge-test", severity = vim.diagnostic.severity.WARN }},
  {{ lnum = 0, col = 0, message = "source-less diagnostic", severity = vim.diagnostic.severity.INFO }}
}})
vim.api.nvim_create_autocmd("BufWritePre", {{ buffer = buf, callback = function() error("Save hooks must not run") end }})
require("99")
require("agentic")
local acp = require("agentic.config").acp_providers["codex-acp"]
local provider = require("99.codex-provider")
local original_home = vim.env.CODEX_HOME
vim.env.CODEX_HOME = {json.dumps(str(directory / 'catalog'))}
vim.fn.mkdir(vim.env.CODEX_HOME, "p")
local models
provider.fetch_models(function(value) models = value end)
assert(models[1] == provider._get_default_model())
vim.fn.writefile({{'{{"models":[{{"slug":"cached-test-model","visibility":"list"}},{{"slug":"hidden-test-model","visibility":"hide"}}]}}'}}, vim.env.CODEX_HOME .. "/models_cache.json")
provider.fetch_models(function(value) models = value end)
assert(vim.tbl_contains(models, "cached-test-model"))
assert(not vim.tbl_contains(models, "hidden-test-model"))
vim.env.CODEX_HOME = original_home
local command = provider:_build_command("code only", {{
  model = "gpt-5.3-codex", tmp_file = "/tmp/result with spaces"
}})
vim.fn.writefile({{vim.json.encode({{acp = acp.env.CODEX_CONFIG, cli = command, buffer = buf,
  mode = acp.default_mode, model = acp.initial_model, effort = acp.default_thought_level,
  acp_command = acp.command}})}}, {json.dumps(str(ready))})
""")
    log = stack.enter_context((directory / "editor.log").open("w"))
    proc = launch(stack, [binary, "--headless", "-i", "NONE", "-c", f"luafile {script}"],
                  cwd=directory, stdout=log, stderr=log,
                  env={**os.environ, "XDG_STATE_HOME": str(directory / "state"),
                       "XDG_CACHE_HOME": str(directory / "cache")})
    deadline = time.monotonic() + 20
    while not ready.exists():
        assert proc.poll() is None, (directory / "editor.log").read_text()
        assert time.monotonic() < deadline, (directory / "editor.log").read_text()
        time.sleep(0.05)
    data = json.loads(ready.read_text())
    data["editor_process"] = proc

    def settings(args):
        return tomllib.loads("\n".join(args[i + 1] for i, arg in enumerate(args) if arg == "-c"))

    acp, cli = json.loads(data["acp"]), settings(data["cli"])
    assert acp["mcp_servers"] == cli["mcp_servers"]
    assert data["cli"][-1] == "code only"
    assert data["cli"][5] == "/tmp/result with spaces"
    assert data["mode"] == "agent", "Workspace-write mode must be explicit"
    assert data["model"] == "gpt-6.1-sol"
    assert data["effort"] == "low"
    for config in (acp, cli):
        assert config["features"] == {"shell_tool": False, "unified_exec": False, "apps": False, "multi_agent": False}
        assert config["agents"]["enabled"] is False
        assert config["sandbox_mode"] == "workspace-write"
        assert config["approval_policy"] == "on-request"
        assert config["approvals_reviewer"] == "auto_review"
        assert config["model_reasoning_effort"] == data["effort"]
        assert "standalone AGENTS.md" in config["developer_instructions"]
        assert "repository-wide docs checklist" in config["developer_instructions"]
        assert "Do not run validation" in config["developer_instructions"]
    server = acp["mcp_servers"]["neovim"]
    assert server["required"] and server["enabled"]
    assert "lsp_formatting" in server["disabled_tools"]
    assert {"editor_context", "read_buffers", "find_files", "edit_buffer"} <= set(server["enabled_tools"])
    assert not {"exec_lua", "connect", "lsp_rename", "lsp_formatting"} & set(server["enabled_tools"])
    assert server["default_tools_approval_mode"] == "auto"
    for name in set(server["enabled_tools"]) - {"edit_buffer"}:
        assert server["tools"][name]["approval_mode"] == "approve"
    codex_home = directory / "codex"
    codex_home.mkdir()
    configured = subprocess.run(
        [data["cli"][0], *data["cli"][6:-1], "mcp", "get", "neovim", "--json"],
        cwd=directory, env={**os.environ, "CODEX_HOME": str(codex_home)},
        capture_output=True, text=True, check=True, timeout=20,
    )
    configured = json.loads(configured.stdout)
    assert configured["transport"]["command"] == server["command"]
    assert configured["transport"]["args"] == server["args"]
    app_log = stack.enter_context((directory / "app-server.log").open("w"))
    app_started = time.monotonic()
    app = MCP(launch(stack, [data["cli"][0], "app-server", "--strict-config", *data["cli"][6:-1]],
                     cwd=directory, env={**os.environ, "CODEX_HOME": str(codex_home)},
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=app_log, text=True), initialize=False)
    app.request("initialize", {"clientInfo": {"name": "dashvim-smoke", "version": "1"},
                               "capabilities": {"experimentalApi": True}})
    loaded = app.request("config/read", {"includeLayers": False})["config"]
    assert loaded["mcp_servers"]["neovim"]["tools"] == server["tools"], "Codex must parse per-tool approval settings"
    assert loaded["mcp_servers"]["neovim"]["default_tools_approval_mode"] == "auto"
    data["app_server_startup_ms"] = (time.monotonic() - app_started) * 1000
    mcp_log = stack.enter_context((directory / "mcp.log").open("w"))
    bridge = MCP(launch(stack, [server["command"], *server["args"]],
                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=mcp_log, text=True))
    resources = bridge.request("resources/read", {"uri": "nvim-connections://"})
    connections = json.loads(resources["contents"][0]["text"])
    assert len(connections) == 1
    connection = connections[0]
    assert connection["target"] == server["args"][1]
    tools = {tool["name"] for tool in bridge.request("tools/list", {})["tools"]}
    assert {"read", "list_buffers", "exec_lua", "lsp_definition", "lsp_references", "buffer_diagnostics"} <= tools
    return bridge, connection["id"], data["buffer"], source, server["args"][1], data


def main():
    binary = str(Path(sys.argv[1]).resolve())
    with tempfile.TemporaryDirectory(prefix="dashvim-mcp-") as tmp, contextlib.ExitStack() as stack:
        editors = [start_editor(stack, binary, Path(tmp), i) for i in range(2)]
        assert editors[0][4] != editors[1][4], "Editors must use different sockets"
        first, first_id, first_buf, _, _, first_data = editors[0]
        server = json.loads(first_data["acp"])["mcp_servers"]["neovim"]
        for index in range(4):
            log = stack.enter_context((Path(tmp) / f"peer-{index}.log").open("w"))
            peer = MCP(launch(stack, [server["command"], *server["args"]],
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=log, text=True))
            connections = json.loads(peer.request("resources/read", {"uri": "nvim-connections://"})["contents"][0]["text"])
            peer_id = connections[0]["id"]
            assert json.loads(peer.tool("editor_context", connection_id=peer_id, id=first_buf))["lines"] == ["unsaved editor 0"]
        assert first_data["editor_process"].poll() is None, "Multiple MCP clients must not crash Neovim"
        for i, (bridge, connection, buffer, source, _, _) in enumerate(editors):
            def lua(code):
                return json.loads(bridge.tool("exec_lua", connection_id=connection, code=code))["result"]

            def read():
                return bridge.tool("read", connection_id=connection, document={"buffer_id": buffer})

            assert f"unsaved editor {i}" in read()
            assert "existing diagnostic" in bridge.tool("buffer_diagnostics", connection_id=connection, id=buffer)
            assert "source-less diagnostic" in bridge.tool("buffer_diagnostics", connection_id=connection, id=buffer)
            context = json.loads(bridge.tool("editor_context", connection_id=connection, id=buffer, diagnostics=True))
            assert context["lines"] == [f"unsaved editor {i}"]
            assert context["path"] == str(source)
            assert any(d["source"] == "" for d in context["diagnostics"])
            other = source.parent / "related.txt"
            other.write_text("related source\n")
            batch = json.loads(bridge.tool("read_buffers", connection_id=connection,
                                          buffers=[{"id": buffer, "start": 0, "end": 1},
                                                   {"path": str(other), "start": 0, "end": 1}]))
            assert batch[0]["lines"] == context["lines"]
            assert batch[1]["lines"] == ["related source"]
            found = json.loads(bridge.tool("find_files", connection_id=connection,
                                          directory=str(source.parent), pattern="*.txt", depth=0))
            assert str(other) in found["paths"]
            edit = {"connection_id": connection, "id": buffer, "changedtick": context["changedtick"],
                    "start": 0, "end": 1, "expected": context["lines"], "replacement": ["changed through MCP"], "save": False}
            for conflict, message in (({"changedtick": context["changedtick"] - 1}, "changed since read"),
                                      ({"expected": ["wrong text"]}, "Expected text does not match")):
                result = bridge.request("tools/call", {"name": "edit_buffer", "arguments": {**edit, **conflict}}, allow_error=True)
                assert message in result["error"]["message"], result
                assert f"unsaved editor {i}" in read(), "Conflict must leave source untouched"
            changed = json.loads(bridge.tool("edit_buffer", **edit))
            assert changed["edited"] and not changed["saved"]
            assert "changed through MCP" in read()
            assert source.read_text() == "saved on disk\n", "Buffer mutation alone must not write to disk"
            assert lua(f"return vim.bo[{buffer}].modified") is True
            saved = json.loads(bridge.tool("edit_buffer", **{**edit, "changedtick": changed["changedtick"],
                                             "expected": ["changed through MCP"], "replacement": ["saved through MCP"], "save": True}))
            assert saved["saved"]
            assert source.read_text() == "saved through MCP\n"
            lua(f"vim.api.nvim_buf_call({buffer}, function() vim.cmd('undo') end); return true")
            assert "changed through MCP" in read(), "Each edit must be a separate native undo step"
            lua(f"vim.api.nvim_buf_call({buffer}, function() vim.cmd('noautocmd update') end); return true")
            assert source.read_text() == "changed through MCP\n"
            assert lua(f"return vim.bo[{buffer}].modified") is False
            lua(f"vim.api.nvim_buf_call({buffer}, function() vim.cmd('undo') end); return true")
            assert f"unsaved editor {i}" in read(), "Undo must restore the user's unsaved edit"
            context = json.loads(bridge.tool("editor_context", connection_id=connection, id=buffer))
            lua(f"vim.bo[{buffer}].readonly = true; return true")
            failure = bridge.request("tools/call", {"name": "edit_buffer", "arguments": {
                **edit, "changedtick": context["changedtick"], "save": True,
                "replacement": ["write must fail"],
            }}, allow_error=True)
            assert "Edit applied but save failed" in failure["error"]["message"]
            assert "write must fail" in read()
            assert source.read_text() == "changed through MCP\n"
            assert lua(f"return vim.bo[{buffer}].modified") is True
            lua(f"vim.bo[{buffer}].readonly = false; vim.api.nvim_buf_call({buffer}, function() vim.cmd('undo') end); return true")
            assert f"unsaved editor {i}" in read()
            outside = source.parent.parent / "outside.txt"
            outside.write_text("outside workspace\n")
            outside_context = json.loads(bridge.tool("editor_context", connection_id=connection, path=str(outside)))
            failure = bridge.request("tools/call", {"name": "edit_buffer", "arguments": {
                **edit, "id": outside_context["id"], "changedtick": outside_context["changedtick"],
                "expected": outside_context["lines"],
            }}, allow_error=True)
            assert "outside the editor workspace" in failure["error"]["message"]
            assert outside.read_text() == "outside workspace\n"
            created = source.parent / "new-file.txt"
            empty = json.loads(bridge.tool("editor_context", connection_id=connection, path=str(created)))
            bridge.tool("edit_buffer", connection_id=connection, id=empty["id"], changedtick=empty["changedtick"],
                        start=0, end=1, expected=[""], replacement=["created through Neovim"])
            assert created.read_text() == "created through Neovim\n", "New workspace files must remain supported"
        print("PASS: both launchers and strict Codex config; focused tools, source-less diagnostics, atomic conflicts, saves without hooks, undo, instance isolation, and multiple clients")
        print("Local app-server initialize + config/read (model-free): " +
              ", ".join(f"{editor[5]['app_server_startup_ms']:.1f} ms" for editor in editors))


if __name__ == "__main__":
    main()
