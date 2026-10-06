"""Check rollout correlation, parallel timing, and privacy using synthetic logs."""

import importlib.util
import json
from pathlib import Path
import tempfile
import sys

sys.dont_write_bytecode = True


spec = importlib.util.spec_from_file_location("latency", Path(__file__).with_name("codex-latency.py"))
latency = importlib.util.module_from_spec(spec)
spec.loader.exec_module(latency)


def row(kind, second, payload):
    return {"type": kind, "timestamp": f"2026-10-06T00:00:{second:02d}Z", "payload": payload}


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    main = [
        row("session_meta", 0, {"id": "main", "originator": "Agentic.nvim", "timestamp": "2026-10-06T00:00:00Z"}),
        row("event_msg", 0, {"type": "task_started"}),
        row("turn_context", 0, {"model": "fixture-model", "effort": "low"}),
        row("response_item", 1, {"text": "SECRET SOURCE"}),
        row("event_msg", 2, {"type": "token_count", "info": {"last_token_usage": {"input_tokens": 100}}}),
    ]
    for start, end in [(1000, 4000), (2000, 5000)]:
        main.append(row("event_msg", 5, {
            "type": "item_completed", "started_at_ms": start, "completed_at_ms": end,
            "item": {"type": "McpToolCall", "tool": "editor_context", "arguments": "SECRET SOURCE",
                     "duration": {"secs": 0, "nanos": 1000000}},
        }))
    main.append(row("event_msg", 10, {"type": "task_complete", "time_to_first_token_ms": 2000}))
    review = [
        row("session_meta", 1, {"id": "review", "parent_thread_id": "main", "timestamp": "2026-10-06T00:00:01Z"}),
        row("turn_context", 1, {"model": "codex-auto-review", "effort": "low"}),
        row("event_msg", 1, {"type": "task_started"}),
        row("event_msg", 4, {"type": "task_complete"}),
    ]
    for name, rows in [("main", main), ("review", review)]:
        (root / f"{name}.jsonl").write_text("\n".join(map(json.dumps, rows)) + '\n{"incomplete":')
    result = latency.report(root, ["main"])
    turn, = result["turns"]
    assert turn["model"] == "fixture-model"
    assert turn["total_seconds"] == 10 and turn["ttft_seconds"] == 2
    assert turn["context_peak_tokens"] == 100
    assert turn["tool_count"] == 2 and turn["tool_wait_seconds"] == 4
    assert turn["tool_execution_seconds"] == 0.002
    assert turn["approval_count"] == 1 and turn["approval_seconds"] == 3
    assert "SECRET" not in json.dumps(result)
    assert not latency.report(root, ["missing"])["turns"]
    assert not latency.report(root, since="2026-10-07T00:00:00Z")["turns"]
print("PASS: rollout correlation, parallel timing, incomplete logs, filtering, and privacy")
