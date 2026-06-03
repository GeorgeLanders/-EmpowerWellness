import os
from typing import List, Optional

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


# OpenCode config — OPENCODE_API_KEY must be set in Render dashboard env vars.
# No hardcoded fallback: prevents accidentally using a dead/expired key.
OPENCODE_API_KEY = os.environ.get("OPENCODE_API_KEY", "")
OPENCODE_MODEL = os.environ.get("OPENCODE_MODEL", "big-pickle")
OPENCODE_URL = "https://opencode.ai/zen/v1/chat/completions"


app = FastAPI(title="Lumina Wellness Proxy")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    user_name: str = "Friend"
    history: Optional[List[ChatMessage]] = []


class ChatResponse(BaseModel):
    reply: str


def build_system_prompt(user_name: str) -> str:
    return (
        f"You are Lumina, a warm and shame-free wellness coach. "
        f"Keep your replies to 2-3 sentences. Address the user by name ({user_name}). "
        f"Be encouraging, practical, and never judgmental."
    )


@app.get("/")
def root():
    return {"status": "ok", "service": "Lumina Wellness Proxy"}


@app.get("/health")
def health():
    return {
        "status": "ok",
        "provider": "opencode",
        "model": OPENCODE_MODEL,
        "key_configured": bool(OPENCODE_API_KEY),
    }


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not OPENCODE_API_KEY:
        return ChatResponse(
            reply="Server is not configured with a Wellness AI Secure Key. Please contact support."
        )

    messages = [{"role": "system", "content": build_system_prompt(req.user_name)}]
    for h in req.history or []:
        messages.append({"role": h.role, "content": h.content})
    messages.append({"role": "user", "content": req.message})

    payload = {
        "model": OPENCODE_MODEL,
        "messages": messages,
        "max_tokens": 300,
    }

    headers = {
        "Authorization": f"Bearer {OPENCODE_API_KEY}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(OPENCODE_URL, json=payload, headers=headers)
        if resp.status_code != 200:
            return ChatResponse(
                reply=f"I'm having trouble reaching my AI backend right now. (Error {resp.status_code}: {resp.text[:200]})"
            )
        data = resp.json()

    reply = data["choices"][0]["message"]["content"]
    return ChatResponse(reply=reply)
