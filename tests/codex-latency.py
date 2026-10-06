"""Report Codex rollout timing without printing prompts, source text, or tool arguments."""

import argparse
from datetime import datetime
import json
import math
import os
from pathlib import Path
import statistics


def timestamp(value):
    return datetime.fromisoformat(value).timestamp()


def union_seconds(intervals):
    end, total = 0, 0
    for start, finish in sorted(intervals):
        total += max(0, finish - max(start, end))
        end = max(end, finish)
    return total


def read_turns(path):
    meta, context, active, turns = {}, {}, None, []
    for line in path.read_text().splitlines():
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue  # An active rollout can end in an incomplete append.
        payload = row.get("payload", {})
        if row.get("type") == "session_meta":
            meta = payload
        if row.get("type") == "turn_context":
            context = payload
            if active is not None:
                active["model"] = context.get("model")
                active["effort"] = context.get("effort")
        if row.get("type") != "event_msg":
            continue
        kind = payload.get("type")
        if kind == "task_started":
            active = {
                "session_id": meta.get("id"), "parent_thread_id": meta.get("parent_thread_id"),
                "originator": meta.get("originator"), "model": context.get("model"), "effort": context.get("effort"),
                "started": timestamp(row["timestamp"]), "calls": [], "context_peak_tokens": 0,
            }
        if active is None:
            continue
        item = payload.get("item", {})
        if kind == "item_completed" and item.get("type") == "McpToolCall":
            duration = item.get("duration") or {}
            active["calls"].append({
                "tool": item.get("tool"),
                "started": payload["started_at_ms"] / 1000, "completed": payload["completed_at_ms"] / 1000,
                "execution_seconds": duration.get("secs", 0) + duration.get("nanos", 0) / 1e9,
            })
        if kind == "token_count" and payload.get("info"):
            usage = payload["info"].get("last_token_usage") or {}
            active["context_peak_tokens"] = max(active["context_peak_tokens"], usage.get("input_tokens", 0))
        if kind in ("task_complete", "task_completed"):
            active["completed"] = timestamp(row["timestamp"])
            active["total_seconds"] = active["completed"] - active["started"]
            ttft = payload.get("time_to_first_token_ms")
            active["ttft_seconds"] = ttft / 1000 if ttft is not None else None
            turns.append(active)
            active = None
    return turns


def report(root, session_ids=(), since=None):
    turns = []
    ids = set(session_ids)
    for path in sorted(root.rglob("*.jsonl")):
        with path.open() as file:
            try:
                meta = json.loads(file.readline()).get("payload", {})
            except json.JSONDecodeError:
                continue
        if ids and meta.get("id") not in ids and meta.get("parent_thread_id") not in ids:
            continue
        if since and timestamp(meta["timestamp"]) < timestamp(since):
            continue
        turns.extend(read_turns(path))
    reviews = [turn for turn in turns if turn["model"] == "codex-auto-review"]
    samples = []
    for turn in turns:
        if turn["model"] == "codex-auto-review":
            continue
        approvals = [review for review in reviews if review["parent_thread_id"] == turn["session_id"]
                     and turn["started"] <= review["started"] < turn["completed"]]
        calls = turn["calls"]
        samples.append({
            key: turn[key] for key in ("session_id", "originator", "model", "effort", "total_seconds", "ttft_seconds", "context_peak_tokens")
        } | {
            "tool_count": len(calls), "tools": [call["tool"] for call in calls],
            "tool_execution_seconds": sum(call["execution_seconds"] for call in calls),
            "tool_wait_seconds": union_seconds([(call["started"], call["completed"]) for call in calls]),
            "approval_count": len(approvals), "approval_seconds": sum(review["total_seconds"] for review in approvals),
        })
    grouped = {}
    for sample in samples:
        key = f"{sample['originator']} / {sample['model']} / {sample['effort']}"
        grouped.setdefault(key, []).append(sample)
    aggregates = {}
    for key, group in grouped.items():
        totals = sorted(sample["total_seconds"] for sample in group)
        first_tokens = [sample["ttft_seconds"] for sample in group if sample["ttft_seconds"] is not None]
        aggregates[key] = {
            "samples": len(group), "median_seconds": statistics.median(totals),
            "p95_seconds": totals[math.ceil(len(totals) * 0.95) - 1], "max_seconds": max(totals),
            "median_ttft_seconds": statistics.median(first_tokens) if first_tokens else None,
            "approval_count": sum(sample["approval_count"] for sample in group),
        }
    return {"turns": samples, "aggregates": aggregates}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sessions", nargs="*", help="Session ids; includes their approval-review children")
    parser.add_argument("--codex-home", type=Path, default=Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))))
    parser.add_argument("--since", help="ISO timestamp; filters sessions created at or after it")
    args = parser.parse_args()
    print(json.dumps(report(args.codex_home / "sessions", args.sessions, args.since), indent=2))
