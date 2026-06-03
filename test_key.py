"""Quick smoke test for the OpenCode API key.

Usage:
    export OPENCODE_API_KEY=sk-...
    python test_key.py
"""
import os
import sys

import httpx


def main() -> int:
    api_key = os.environ.get("OPENCODE_API_KEY", "").strip()
    if not api_key:
        print("ERROR: Set OPENCODE_API_KEY env var first.")
        return 1

    print(f"Key length: {len(api_key)}")
    print(f"Key starts with: {api_key[:8]}...")

    model = os.environ.get("OPENCODE_MODEL", "big-pickle")
    url = "https://opencode.ai/zen/v1/chat/completions"

    resp = httpx.post(
        url,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "model": model,
            "messages": [{"role": "user", "content": "say hi in one word"}],
            "max_tokens": 10,
        },
        timeout=15,
    )
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text[:500]}")

    if resp.status_code == 200:
        print("KEY WORKS!")
        return 0
    print("KEY FAILED — check model name and key validity.")
    return 2


if __name__ == "__main__":
    sys.exit(main())
