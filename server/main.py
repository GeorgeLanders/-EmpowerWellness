import os
from typing import List, Optional

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


OPENROUTER_API_KEY = os.environ.get("OPENROUTER_API_KEY", "")
OPENROUTER_MODEL = os.environ.get("OPENROUTER_MODEL", "google/gemma-4-31b-it:free")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"


app = FastAPI(title="Big Pickle Free Wellness Proxy")

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
        f"You are Big Pickle Free, a warm and shame-free wellness coach. "
        f"Keep your replies to 2-3 sentences. Address the user by name ({user_name}). "
        f"Be encouraging, practical, and never judgmental."
    )


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
            reply="Server is not configured with an OpenRouter API key. Please contact support."
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
        resp.raise_for_status()
        data = resp.json()

    reply = data["choices"][0]["message"]["content"]
    return ChatResponse(reply=reply)
