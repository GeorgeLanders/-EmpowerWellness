import os
from typing import List, Optional

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


# OpenRouter config — uses env var on Render, falls back to embedded key
OPENROUTER_API_KEY = os.environ.get("OPENROUTER_API_KEY", "sk-yXiOOMreUUejD7kD0iVN6b8eyxp0z789Y5WVqhRdDD7eR55NLhiuBX5Q2UVDlF8L")
OPENROUTER_MODEL = os.environ.get("OPENROUTER_MODEL", "nvidia/nemotron-3-super-120b-a12b:free")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"


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
        "key_configured": bool(OPENROUTER_API_KEY),
    }


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not OPENROUTER_API_KEY:
        return ChatResponse(
            reply="Server is not configured with an Wellness AI Secure Key. Please contact support."
        )

    messages = [{"role": "system", "content": build_system_prompt(req.user_name)}]
    for h in req.history or []:
        messages.append({"role": h.role, "content": h.content})
    messages.append({"role": "user", "content": req.message})

    payload = {
        "model": OPENROUTER_MODEL,
        "messages": messages,
        "max_tokens": 300,
    }

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(OPENROUTER_URL, json=payload, headers=headers)
        if resp.status_code != 200:
            return ChatResponse(
                reply=f"I'm having trouble reaching my AI backend right now. (Error {resp.status_code}: {resp.text[:200]})"
            )
        data = resp.json()

    reply = data["choices"][0]["message"]["content"]
    return ChatResponse(reply=reply)
