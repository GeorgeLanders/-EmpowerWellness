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


def local_fallback(message: str) -> str:
    """Lumina-style local response used when the upstream model returns empty content
    (some models filter very short or trivial messages). Keeps the user experience
    smooth when 'big-pickle' decides not to answer."""
    lower = (message or "").lower().strip()
    if not lower:
        return "I am right here with you. Take your time — what would you like to talk about?"
    if any(g in lower for g in ("hello", "hi", "hey", "good morning", "good evening")):
        return "Hey there, friend! It is lovely to see you. How is your heart today?"
    if any(w in lower for w in ("tired", "exhausted", "drained", "sleepy", "no energy")):
        return "Rest is part of the journey, not a detour. Your world is still growing even when you pause. What is one small, gentle thing that feels doable right now?"
    if any(w in lower for w in ("sad", "down", "depressed", "lonely", "crying")):
        return "Your feelings are valid, and you are not alone in this. Even the strongest trees weather storms. What is one tiny thing that might bring you a moment of peace?"
    if any(w in lower for w in ("anxious", "worried", "stress", "panic", "overwhelm", "nervous")):
        return "Let us breathe through this together. Your world is safe, and you are doing better than you think. Would a short grounding exercise help right now?"
    if any(w in lower for w in ("motivat", "lazy", "give up", "can't be bothered", "procrastin")):
        return "Motivation comes and goes, but your commitment to showing up is the real magic. What is one small win you can claim today, even if it feels tiny?"
    if any(w in lower for w in ("thank", "thanks", "appreciate")):
        return "It means a lot that you shared that with me. Remember, I am here whenever you need a kind word or a steady hand."
    if any(w in lower for w in ("sore", "pain", "hurt", "ache")):
        return "Thank your body for telling you what it needs. Gentle movement, hydration, and rest are all acts of strength. How does it feel right now?"
    if any(w in lower for w in ("sleep", "insomnia", "can't sleep", "awake", "bed")):
        return "Sleep can be elusive, but your body knows how to rest. A slow breath in for four, out for six, can work wonders. Want to try together?"
    if any(w in lower for w in ("bored", "nothing to do", "restless")):
        return "Restlessness is just energy waiting for a direction. A short walk, a stretch, or even naming three things you can see can shift the moment. What sounds doable?"
    if any(w in lower for w in ("eat", "food", "hungry", "meal", "snack")):
        return "Nourishing yourself is one of the kindest things you can do. Something colorful and simple is often exactly what the body asks for. What sounds good right now?"
    return "That is a powerful thing to share. Remember, your journey is not a sprint — it is a dance. Let us focus on one small step forward. What feels most empowering right now?"


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

    try:
        reply = (data["choices"][0]["message"]["content"] or "").strip()
    except (KeyError, IndexError, TypeError):
        reply = ""

    # Some models (e.g. big-pickle) return empty content for very short or
    # trivial messages. Fall back to a local Lumina-style response so the user
    # never sees a silent bubble.
    if not reply:
        reply = local_fallback(req.message)

    return ChatResponse(reply=reply)
