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
    def __init__(self, proc):
        self.proc = proc
        self.messages = queue.Queue()
        self.next_id = 0

        def read():
            for line in proc.stdout:
                self.messages.put(json.loads(line))
            self.messages.put(None)

        threading.Thread(target=read, daemon=True).start()
        self.request("initialize", {
            "protocolVersion": "2025-03-26",
            "capabilities": {},
            "clientInfo": {"name": "dashvim-smoke", "version": "1"},
        })
        self.send({"method": "notifications/initialized"})

    def send(self, message):
        self.proc.stdin.write(json.dumps({"jsonrpc": "2.0", **message}) + "\n")
        self.proc.stdin.flush()

    def request(self, method, params):
        self.next_id += 1
        self.send({"id": self.next_id, "method": method, "params": params})
        while True:
            message = self.messages.get(timeout=20)
            assert message is not None, "MCP exited before responding"
            if message.get("id") == self.next_id:
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
  {{ lnum = 0, col = 0, message = "existing diagnostic", source = "bridge-test", severity = vim.diagnostic.severity.WARN }}
}})
require("99")
require("agentic")
local acp = require("agentic.config").acp_providers["codex-acp"]
local command = require("99.codex-provider"):_build_command("code only", {{
  model = "gpt-5.3-codex", tmp_file = "/tmp/result with spaces"
}})
vim.fn.writefile({{vim.json.encode({{acp = acp.env.CODEX_CONFIG, cli = command, buffer = buf}})}}, {json.dumps(str(ready))})
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

    def settings(args):
        return tomllib.loads("\n".join(args[i + 1] for i, arg in enumerate(args) if arg == "-c"))

    acp, cli = json.loads(data["acp"]), settings(data["cli"])
    assert acp["mcp_servers"] == cli["mcp_servers"]
    assert data["cli"][-1] == "code only"
    assert data["cli"][5] == "/tmp/result with spaces"
    for config in (acp, cli):
        assert config["features"] == {"shell_tool": False, "unified_exec": False}
        assert "name: caveman" in config["developer_instructions"]
        assert "Do not run validation" in config["developer_instructions"]
    server = acp["mcp_servers"]["neovim"]
    assert server["required"] and server["enabled"]
    assert "lsp_formatting" in server["disabled_tools"]
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
    return bridge, connection["id"], data["buffer"], source, server["args"][1]


def main():
    binary = str(Path(sys.argv[1]).resolve())
    with tempfile.TemporaryDirectory(prefix="dashvim-mcp-") as tmp, contextlib.ExitStack() as stack:
        editors = [start_editor(stack, binary, Path(tmp), i) for i in range(2)]
        assert editors[0][4] != editors[1][4], "Editors must use different sockets"
        for i, (bridge, connection, buffer, source, _) in enumerate(editors):
            def lua(code):
                return json.loads(bridge.tool("exec_lua", connection_id=connection, code=code))["result"]

            def read():
                return bridge.tool("read", connection_id=connection, document={"buffer_id": buffer})

            assert f"unsaved editor {i}" in read()
            assert "existing diagnostic" in bridge.tool("buffer_diagnostics", connection_id=connection, id=buffer)
            tick = lua(f"return vim.api.nvim_buf_get_changedtick({buffer})")
            lua(f"assert(vim.api.nvim_buf_get_changedtick({buffer}) == {tick}); "
                f"vim.api.nvim_buf_set_lines({buffer}, 0, 1, false, {{'changed through MCP'}}); return true")
            assert "changed through MCP" in read()
            assert source.read_text() == "saved on disk\n", "Buffer mutation alone must not write to disk"
            assert lua(f"return vim.bo[{buffer}].modified") is True
            lua(f"vim.api.nvim_buf_call({buffer}, function() vim.cmd('noautocmd update') end); return true")
            assert source.read_text() == "changed through MCP\n"
            assert lua(f"return vim.bo[{buffer}].modified") is False
            lua(f"vim.api.nvim_buf_call({buffer}, function() vim.cmd('undo') end); return true")
            assert f"unsaved editor {i}" in read(), "Undo must restore the user's unsaved edit"
        print("PASS: ACP environment and CLI settings agree; direct MCP reads, edits, diagnostics, native saves, undo, and instance isolation")


if __name__ == "__main__":
    main()
