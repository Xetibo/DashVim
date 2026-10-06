"""Opt-in authenticated benchmark: temporary editor fixtures, ACP questions/edits and 99 output contracts."""

import argparse
import contextlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import statistics
import subprocess
import sys
import tempfile
import time

sys.dont_write_bytecode = True


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


bridge_test = load("bridge_test", "codex-bridge.py")
latency = load("latency", "codex-latency.py")


class ACP(bridge_test.MCP):
    def request(self, method, params, allow_error=False):
        self.response_text = ""
        self.next_id += 1
        request_id = self.next_id
        self.send({"id": request_id, "method": method, "params": params})
        deadline = time.monotonic() + 180
        while time.monotonic() < deadline:
            message = self.messages.get(timeout=max(0.1, deadline - time.monotonic()))
            assert message is not None, "ACP exited before responding"
            if message.get("method") == "session/update":
                update = message.get("params", {}).get("update", {})
                content = update.get("content", {})
                if update.get("sessionUpdate") == "agent_message_chunk" and content.get("type") == "text":
                    self.response_text += content.get("text", "")
            if message.get("method") and "id" in message:
                if message["method"] == "session/request_permission":
                    self.send({"id": message["id"], "result": {"outcome": {"outcome": "cancelled"}}})
                    raise RuntimeError("ACP unexpectedly requested client approval; inspect benchmark log")
                self.send({"id": message["id"], "error": {"code": -32601, "message": "Unsupported benchmark client request"}})
            elif message.get("id") == request_id:
                assert "error" not in message, message
                return message["result"]
        raise TimeoutError(f"ACP timeout: {method}")


def stop_group(proc):
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass


def benchmark(args):
    samples, session_ids = [], []
    temporary = (contextlib.nullcontext(tempfile.mkdtemp(prefix="dashvim-benchmark-")) if args.keep_fixtures
                 else tempfile.TemporaryDirectory(prefix="dashvim-benchmark-"))
    with temporary as tmp, contextlib.ExitStack() as stack:
        root = Path(tmp)
        if args.keep_fixtures:
            print(f"Benchmark fixtures: {root}", file=sys.stderr)
        bridge, connection, buffer, source, _, data = bridge_test.start_editor(stack, str(args.nvim.resolve()), root, 0)
        subprocess.run(["git", "init", "--quiet", str(source.parent)], check=True)
        models = args.models or [data["model"]]
        for name in ("ARCHITECTURE", "UI", "CODE_GUIDELINES", "TECHNICAL_DEBT", "TESTING", "DECISIONS"):
            docs = source.parent / "docs"
            docs.mkdir(exist_ok=True)
            (docs / f"{name}.md").write_text("Benchmark fixture. No documentation work requested.\n")
        before_docs = {path: path.read_bytes() for path in docs.iterdir()}
        config = json.loads(data["acp"])
        for model in models:
            if "acp" in args.hosts:
                config["model"] = model
                log = stack.enter_context((root / f"acp-{model}.log").open("w"))
                proc = bridge_test.launch(stack, [data["acp_command"]], cwd=source.parent,
                                         env={**os.environ, "CODEX_HOME": str(args.codex_home), "CODEX_CONFIG": json.dumps(config)},
                                         stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=log, text=True,
                                         start_new_session=True)
                stack.callback(stop_group, proc)
                client = ACP(proc, initialize=False)
                client.request("initialize", {"protocolVersion": 1, "clientInfo": {"name": "Agentic.nvim", "version": "dashvim-benchmark"},
                                               "clientCapabilities": {"fs": {"readTextFile": False, "writeTextFile": False}, "terminal": False}})
                for index in range(args.samples):
                    session = client.request("session/new", {"cwd": str(source.parent), "mcpServers": []})
                    session_id = session["sessionId"]
                    session_ids.append(session_id)
                    client.request("session/set_mode", {"sessionId": session_id, "modeId": "agent"})
                    for key, value in (("model", model), ("reasoning_effort", data["effort"])):
                        client.request("session/set_config_option", {"sessionId": session_id, "configId": key, "value": value})
                    for operation in ("question", "edit"):
                        replacement = f"benchmark edited {model} {index}"
                        context = f"Attached source: buffer id {buffer}, path {source}. "
                        text = context + ("What is the first live unsaved line? Read through Neovim and answer only that line."
                                          if operation == "question" else
                                          f"Replace the first line with exactly '{replacement}'. Preserve other lines and save through Neovim.")
                        if operation == "question":
                            expected_line = json.loads(bridge.tool("editor_context", connection_id=connection,
                                                                  id=buffer, start=0, end=1))["lines"][0]
                        started = time.monotonic()
                        client.request("session/prompt", {"sessionId": session_id, "prompt": [{"type": "text", "text": text}]})
                        samples.append({"host": "acp", "model": model, "operation": operation,
                                        "seconds": time.monotonic() - started, "session_id": session_id})
                        print(f"ACP {model} {operation} #{index + 1}: {samples[-1]['seconds']:.2f}s", file=sys.stderr)
                        if operation == "edit":
                            assert source.read_text() == replacement + "\n", "ACP must edit and save requested source"
                        else:
                            answer_lines = [line.strip().strip("`") for line in client.response_text.splitlines()]
                            assert expected_line in answer_lines, f"ACP must answer from live source: {client.response_text!r}"
            if "99" in args.hosts:
                before_source = source.read_bytes()
                for index in range(args.samples):
                    result_file = root / f"99-{model}-{index}.txt"
                    command = data["cli"].copy()
                    command[3], command[5] = model, str(result_file)
                    command[-1] = "Visual replacement: return only code, changing old_value to new_value in this selection:\nlocal old_value = 1\nLet 99 apply the replacement; do not edit files."
                    command.insert(2, "--json")
                    started = time.monotonic()
                    completed = subprocess.run(command, cwd=source.parent, stdin=subprocess.DEVNULL,
                                               env={**os.environ, "CODEX_HOME": str(args.codex_home)},
                                               capture_output=True, text=True, timeout=180)
                    assert completed.returncode == 0, completed.stderr
                    elapsed = time.monotonic() - started
                    events = [json.loads(line) for line in completed.stdout.splitlines() if line.startswith("{")]
                    session_id = next(event["thread_id"] for event in events if event.get("type") == "thread.started")
                    session_ids.append(session_id)
                    assert result_file.read_text().strip() == "local new_value = 1", "99 must return code-only output"
                    samples.append({"host": "99", "model": model, "operation": "visual", "seconds": elapsed, "session_id": session_id})
                    print(f"99 {model} visual #{index + 1}: {elapsed:.2f}s", file=sys.stderr)
                assert source.read_bytes() == before_source, "99 visual response must leave file edits to its host"
        assert {path: path.read_bytes() for path in docs.iterdir()} == before_docs, "Focused requests must not update docs"
        report = latency.report(args.codex_home / "sessions", session_ids)
    groups = {}
    for sample in samples:
        groups.setdefault(f"{sample['host']} / {sample['model']} / {sample['operation']}", []).append(sample["seconds"])
    return {
        "samples": samples,
        "summary": {key: {"n": len(values), "median_seconds": statistics.median(values), "max_seconds": max(values)}
                    for key, values in groups.items()},
        "model_free_app_server_startup_ms": data["app_server_startup_ms"],
        "fixture_checks": {"docs_unchanged": True, "focused_edits_saved": "acp" in args.hosts,
                           "99_code_only": "99" in args.hosts},
        "rollout_metrics": report,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("nvim", type=Path)
    parser.add_argument("--samples", type=int, default=3)
    parser.add_argument("--models", nargs="+")
    parser.add_argument("--keep-fixtures", action="store_true", help="Keep temporary logs for debugging")
    parser.add_argument("--hosts", nargs="+", choices=("acp", "99"), default=["acp", "99"])
    parser.add_argument("--codex-home", type=Path, default=Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))))
    args = parser.parse_args()
    if args.samples < 1:
        parser.error("--samples must be positive")
    print(json.dumps(benchmark(args), indent=2))
