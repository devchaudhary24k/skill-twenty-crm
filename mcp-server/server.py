"""MCP stdio server exposing the Twenty CRM skill as tools.

One MCP tool per entry in references/manifest.json (396 tools). Each tool
spawns the underlying bash script with its JSON payload as a single arg.

Configuration via env vars (same as the scripts themselves):
  TWENTY_API_KEY   required
  TWENTY_BASE_URL  required
  TWENTY_MCP_FILTER  optional regex; only operations matching are exposed.
                     Useful for MCP clients that throttle large tool lists.
"""

from __future__ import annotations

import asyncio
import json
import os
import re
import subprocess
import sys
from functools import lru_cache
from pathlib import Path

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

REPO_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = REPO_ROOT / "references" / "manifest.json"
SCHEMA_SH = REPO_ROOT / "scripts" / "schema.sh"

PERMISSIVE_SCHEMA = {"type": "object", "additionalProperties": True}


def load_manifest() -> list[dict]:
    if not MANIFEST.exists():
        print(
            f"Error: manifest not found at {MANIFEST}. "
            "Run scripts/gen-manifest.sh first.",
            file=sys.stderr,
        )
        sys.exit(1)
    return json.loads(MANIFEST.read_text())


def apply_filter(entries: list[dict]) -> list[dict]:
    pattern = os.environ.get("TWENTY_MCP_FILTER")
    if not pattern:
        return entries
    rx = re.compile(pattern)
    return [e for e in entries if rx.search(e["operation"])]


@lru_cache(maxsize=None)
def schema_for(script_rel: str) -> dict:
    script_abs = REPO_ROOT / script_rel
    try:
        result = subprocess.run(
            ["bash", str(SCHEMA_SH), str(script_abs)],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            return json.loads(result.stdout)
    except (subprocess.SubprocessError, json.JSONDecodeError) as exc:
        print(f"schema_for({script_rel}) failed: {exc}", file=sys.stderr)
    return dict(PERMISSIVE_SCHEMA)


def wrap_input_schema(inner: dict) -> dict:
    """MCP tools receive an object with named args; scripts take a single JSON arg.
    We nest the inferred schema under a `payload` property so agents see the shape
    but the dispatcher passes a single JSON string through to bash."""
    return {
        "type": "object",
        "properties": {"payload": inner},
        "required": ["payload"] if inner.get("properties") else [],
        "additionalProperties": False,
    }


def build_tools(entries: list[dict]) -> list[Tool]:
    tools: list[Tool] = []
    for e in entries:
        inner = schema_for(e["script"])
        tools.append(
            Tool(
                name=e["operation"],
                description=f"{e['method']} {e['path']}",
                inputSchema=wrap_input_schema(inner),
            )
        )
    return tools


async def run() -> None:
    entries = apply_filter(load_manifest())
    if not entries:
        print("Error: no operations match TWENTY_MCP_FILTER.", file=sys.stderr)
        sys.exit(1)

    by_op = {e["operation"]: e for e in entries}
    server: Server = Server("twenty-crm")

    @server.list_tools()
    async def _list_tools() -> list[Tool]:
        return build_tools(entries)

    @server.call_tool()
    async def _call_tool(name: str, arguments: dict) -> list[TextContent]:
        entry = by_op.get(name)
        if not entry:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

        payload = arguments.get("payload")
        script = REPO_ROOT / entry["script"]
        argv = ["bash", str(script)]
        if payload is not None:
            argv.append(
                payload if isinstance(payload, str) else json.dumps(payload)
            )

        proc = subprocess.run(
            argv, capture_output=True, text=True, timeout=60, check=False
        )
        text = proc.stdout.strip() or proc.stderr.strip()
        return [TextContent(type="text", text=text or "(no output)")]

    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(run())
