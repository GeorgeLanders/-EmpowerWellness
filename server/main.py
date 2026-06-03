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


import re

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


# ── Local Lumina-style fallback ──
# big-pickle on OpenCode returns empty for some questions (jokes, weather, news,
# very short messages, certain content filters) or gets cut off. We never want
# the user to see a silent bubble, so we serve a local Lumina-style response
# matched by whole-word keywords.

_FALLBACK_RESPONSES = {
    # Jokes / humor — Lumina is gentle, not a standup comedian
    "joke": "Why did the sun go to school? To get a little brighter! "
            "I am better at warm moments than punchlines, friend. "
            "Want to share something that made you smile today?",
    "funny": "I would rather be your cheerleader than your comedian. "
             "Tell me something you laughed at recently and I will laugh with you.",
    # Positive news / celebration
    "happy": "That is wonderful, and I am so glad you shared it. "
             "Moments like this are worth savoring. What made it special?",
    "good news": "I love hearing that. Joy shared is joy doubled. "
                 "Tell me more about what happened.",
    "excited": "That energy is contagious. Hold onto it. What is the best part?",
    "proud": "You should be. Every step you take is something to celebrate. "
             "What does this moment mean to you?",
    "grateful": "Gratitude is a quiet kind of strength. "
                "What is one small thing you are grateful for right now?",
    "visited": "That is precious time. I hope the visit warmed you up. "
               "What was the highlight?",
    # Fear of falling / balance concerns
    "scared of falling": "Your caution is wisdom, not weakness. "
                          "Let us talk about what helps: sturdy shoes with grip, "
                          "a clear path, and rising slowly from chairs. "
                          "Would you like a few seated balance exercises to build confidence?",
    "falling": "Feeling unsteady is more common than people admit, and asking about it is brave. "
               "Three small things help most: stand up slowly, wear non-slip footwear, and keep "
               "a lamp on the path to the bathroom at night. Want me to suggest some seated balance moves?",
    "afraid": "Thank you for naming that. Fear is information, not a verdict. "
              "What feels safest to talk about first?",
    "balance": "Balance is a skill, and skills grow with practice. "
               "Try standing near the kitchen counter and lifting one foot an inch off the floor, "
               "ten seconds each side. That tiny move trains the system. Want more ideas?",
    # Knee / joint pain
    "knee": "When the knee speaks, listen. For right now, skip deep squats, lunges, and stairs. "
            "Try these instead: seated leg lifts (10 each side), heel slides on the floor, and "
            "gentle standing marches holding a chair. If the pain is sharp or new, please call your doctor.",
    "joint": "Stiff joints love warm-up, not jumping in. Try a warm towel for five minutes, "
             "then slow range-of-motion circles: ankles, wrists, shoulders, neck. "
             "Small and steady wins every time.",
    "pain": "Pain is your body asking for gentleness. Try a warm compress for ten minutes, "
            "some slow deep breaths, and the gentlest movement you can. "
            "If the pain is sharp, new, or worsening, your doctor is the right next call.",
    # Weather / news / external info — model can't know
    "weather": "I do not have a window to the sky, but I can offer this: "
               "dress in light layers, drink water before you feel thirsty, and "
               "step outside for five minutes of daylight. Your body notices. "
               "Want a stretching idea for indoors?",
    "news": "I am not connected to the news, and that is a kind of freedom. "
            "I am best at wellness, movement, and how you are feeling. "
            "What is on your heart right now?",
    "time": "Your watch and phone are the best source for that. "
            "I can help with how you spend it though. What feels most important right now?",
    "date": "Today is what matters. What are you hoping to do with it?",
    # Exercise / movement requests
    "exercise": "Movement is medicine, and the smallest dose still helps. "
                "Even five minutes of gentle stretching or a slow walk around the room "
                "counts. Would you like a specific routine from the Move tab?",
    "stretch": "Slow and gentle is the way. Try this: seated neck rolls (3 each side), "
               "shoulder shrugs (5), seated forward fold (10 seconds), and ankle circles (5 each). "
               "You will feel the difference in under two minutes.",
    "workout": "Beautiful. Check the Move tab for gentle routines designed for real bodies. "
               "A ten-minute session done well beats a heroic plan abandoned by Tuesday.",
    # Sleep
    "sleep": "Rest is the foundation. Three quiet things help: dim the screens an hour before bed, "
             "keep the room cool, and try the 4-7-8 breath (in for 4, hold for 7, out for 8) "
             "three times in bed. Sweet dreams are made of small rituals.",
    "insomnia": "Sleeplessness is exhausting, and you are not alone in it. "
                "Try getting up after 20 minutes of trying, doing something calm in dim light, "
                "and coming back when your eyes feel heavy. Your body will follow. "
                "Want a short body-scan script to try?",
    # Breathing
    "breathing": "Yes. The breath is always available. Try box breathing with me: "
                 "in for 4, hold for 4, out for 4, hold for 4. Repeat four times. "
                 "Notice what changes.",
    "anxious": "Anxiety is a wave, and waves pass. Three slow exhales longer than your inhales "
               "calm the nervous system. You are safe right now. What feels doable in the next minute?",
    "stressed": "Stress asks for one small kindness, not a perfect plan. "
                "Try five slow breaths, then name three things you can see. "
                "Want a short grounding script?",
    "overwhelmed": "When everything feels loud, choose one tiny thing. "
                  "A glass of water. One slow breath. One sentence said out loud. "
                  "The big picture gets smaller when you shrink the next step.",
    # Sad / lonely / depressed
    "sad": "I am sorry you are carrying this. Sadness is not a problem to solve, "
           "it is a feeling to sit with. I am here. What does it feel like in your body right now?",
    "lonely": "Loneliness is one of the heaviest feelings, and naming it is a kind of courage. "
              "Is there one person you could send a short message to today, even just a heart emoji? "
              "Small connections interrupt the silence.",
    "depressed": "What you are feeling is real, and you do not have to carry it alone. "
                 "If you have a therapist or doctor, please reach out today. "
                 "In the meantime, can we do one small gentle thing together, like a glass of water?",
    "crying": "Tears are not weakness, they are release. Let them come. "
              "When you are ready, take three slow breaths. I am right here.",
    "cry": "Tears are not weakness, they are release. Let them come. "
           "When you are ready, take three slow breaths. I am right here.",
    "grief": "Grief has no timeline, and there is no right way to do it. "
             "Be gentle with yourself today. Is there one small ritual that honors what you have lost?",
    "died": "I am so sorry for your loss. Grief has no timeline, and there is no right way to do it. "
            "Be gentle with yourself today. Is there one small ritual that honors who you have lost?",
    "lost": "Loss is heavy, and you do not have to carry it alone. "
            "Be gentle with yourself today. Is there one small ritual that honors what you have lost?",
    "passed": "I am so sorry. Loss has no timeline, and there is no right way to grieve. "
              "Be gentle with yourself today. Who or what are you remembering?",
    # Motivation / energy
    "tired": "Tiredness is information. Before pushing, try a glass of water, a two-minute rest, "
             "or a few slow breaths. If the tiredness is bone-deep, a short nap (20 minutes) "
             "is medicine. What does your body need most right now?",
    "lazy": "Lazy is a harsh word for a body that needs rest. "
            "Try just one tiny thing: stand up and stretch, or walk to the window. "
            "Small moves create momentum. You are not behind.",
    "motivation": "Motivation is the spark, not the engine. Habit is the engine. "
                  "Start with two minutes of something gentle — a stretch, a breath, a glass of water. "
                  "Action creates motivation more often than the other way around.",
    "unmotivated": "That is a normal day, not a character flaw. "
                  "What is the smallest kind thing you could do for yourself right now? "
                  "A glass of water counts. Sitting outside counts.",
    # Greetings / generic
    "hi": "Hi friend. It is good to hear from you. What is on your mind today?",
    "hello": "Hello, beautiful soul. I have been thinking of you. What would feel good to talk about?",
    "hey": "Hey there. Whatever brought you here, I am glad you came. What is up?",
    "good morning": "Good morning. How did you sleep, and how is your body feeling as the day begins?",
    "morning": "Good morning. A glass of water first, then a slow stretch. That is a kind start.",
    "good night": "Good night. May your rest be deep and your dreams be kind. I will be here tomorrow.",
    "night": "Good night. Dim the screens, take a slow breath, and let the day go. You did enough.",
    "thank you": "You are so welcome. I am glad I could be here. What else would feel good?",
    "thanks": "Always. You are doing meaningful work just by showing up. I mean that.",
    # Food / meals
    "hungry": "Nourishing yourself is one of the kindest things you can do. "
              "Something colorful and simple is often exactly what the body asks for. "
              "What sounds good right now?",
    "snack": "A small something is a kind friend. Apple and almond butter, "
             "a handful of berries, cheese and whole-grain crackers, or a warm cup of tea. "
             "Which sounds doable?",
    "thirsty": "A glass of water right now will be felt in fifteen minutes. "
               "Sip slowly, and add a slice of lemon or cucumber if you like. Small kindness, big return.",
    # Hydration
    "water": "Beautiful. Slow sips, room temperature if your body is cool. "
             "A pinch of salt or a squeeze of lemon helps your cells use it. You are doing a kind thing.",
    # Daily check-ins
    "how are you": "I am steady and glad you are here. More importantly, how are you?",
    "what is up": "Just here, ready when you are. What would feel good to talk about?",
    "bored": "Boredom is the mind asking for something new. "
             "Try a one-minute stretch, a single page of a book, or stepping outside for a breath of air. "
             "Tiny novelty resets the system.",
}

# Keywords that map to a fallback key
_KW_TO_KEY = []
for _key in _FALLBACK_RESPONSES:
    _KW_TO_KEY.append((_key, _key))


def _has_word(text: str, word) -> bool:
    """Word-START, case-insensitive check (avoids 'weather' matching 'eat').
    Matches the keyword and any longer form ending with it (meals, stretches,
    hurting, cried) so plurals and verb forms work. Accepts a string or an
    iterable of strings (any-match)."""
    if isinstance(word, str):
        words = (word,)
    else:
        words = tuple(word)
    return any(
        re.search(rf"\b{re.escape(w)}", text, re.IGNORECASE) is not None
        for w in words
    )


def local_fallback(message: str) -> str:
    lower = message.lower().strip()
    if not lower:
        return "I am here whenever you are ready. Take your time."

    # ── Sub-branches first (need tier-2 routing by body-part / meal-plan etc.) ──

    # Food / meals: meal-planning questions get a full day template;
    # "hungry" gets a gentle prompt; everything else gets a snack idea.
    _FOOD_TERMS = ("hungry", "snack", "food", "eat", "meal", "dinner",
                   "lunch", "breakfast", "recipe", "cook", "menu", "thirsty",
                   "water", "drink", "hydrate")
    _MEAL_PLAN_TERMS = ("plan", "prepare", "prep", "ideas", "suggest",
                        "what should i", "what to", "menu", "cook", "recipe",
                        "dinner", "lunch", "breakfast", "tonight", "today",
                        "for me", "the day", "week")
    if any(_has_word(lower, w) for w in _FOOD_TERMS):
        if any(_has_word(lower, w) for w in _MEAL_PLAN_TERMS):
            return (
                "Here is a simple, balanced day of meals that supports steady energy:\n"
                "  • Breakfast: oatmeal with berries and a spoon of nut butter\n"
                "  • Lunch: grilled chicken or chickpea salad with leafy greens, olive oil, and lemon\n"
                "  • Snack: apple slices with a small handful of almonds\n"
                "  • Dinner: baked salmon (or lentils) with roasted sweet potato and steamed broccoli\n"
                "Always pair protein and fiber to stay full longer. Want a recipe for any of these?"
            )
        if _has_word(lower, "hungry"):
            return ("Nourishing yourself is one of the kindest things you can do. "
                    "Something colorful and simple is often exactly what the body asks for. "
                    "What sounds good right now?")
        if _has_word(lower, "snack"):
            return ("A small something is a kind friend. Apple and almond butter, "
                    "a handful of berries, cheese and whole-grain crackers, or a warm cup of tea. "
                    "Which sounds doable?")
        if _has_word(lower, ("thirsty", "water", "drink", "hydrate")):
            return ("A glass of water right now will be felt in fifteen minutes. "
                    "Sip slowly, and add a slice of lemon or cucumber if you like. "
                    "Small kindness, big return.")
        return ("Nourishing yourself is one of the kindest things you can do. "
                "Something colorful and simple is often exactly what the body asks for. "
                "What sounds good right now?")

    # Pain: branch on body part when mentioned
    _PAIN_TERMS = ("hurt", "ache", "pain", "sore", "stiff", "twinge")
    if any(_has_word(lower, w) for w in _PAIN_TERMS):
        if _has_word(lower, "knee"):
            return ("When the knee speaks, listen. For right now, skip deep squats, lunges, and stairs. "
                    "Try these instead: seated leg lifts (10 each side), heel slides on the floor, and "
                    "gentle standing marches holding a chair. If the pain is sharp or new, please call your doctor.")
        if _has_word(lower, ("shoulder", "neck", "back", "hip", "wrist", "ankle")):
            return ("Try a warm compress on the area for ten minutes, then very slow circles — "
                    "smaller than you think you need. If it is sharp or new, please call your doctor. "
                    "Want a few gentle moves that respect this spot?")
        return ("Pain is your body asking for gentleness. Try a warm compress for ten minutes, "
                "some slow deep breaths, and the gentlest movement you can. "
                "If the pain is sharp, new, or worsening, your doctor is the right next call.")

    # Movement: specific guidance for stretch / exercise / workout / move
    _MOVE_TERMS = ("stretch", "workout", "exercise", "movement", "move", "yoga", "walk")
    if any(_has_word(lower, w) for w in _MOVE_TERMS):
        if _has_word(lower, "stretch"):
            return ("Slow and gentle is the way. Try this: seated neck rolls (3 each side), "
                    "shoulder shrugs (5), seated forward fold (10 seconds), and ankle circles (5 each). "
                    "You will feel the difference in under two minutes.")
        if _has_word(lower, "yoga"):
            return ("Beautiful. Try a seated cat-cow and a slow seated twist to each side. "
                    "If you would like a guided video, check the Move tab — there are gentle "
                    "options designed for real bodies.")
        if _has_word(lower, "walk"):
            return ("A short walk outside is medicine. Five minutes is plenty. "
                    "If you can, find a level path with a railing or a friend. "
                    "What is one safe route you already know?")
        return ("Movement is medicine, and the smallest dose still helps. "
                "Even five minutes of gentle stretching or a slow walk around the room "
                "counts. Would you like a specific routine from the Move tab?")

    # Time/date placeholders
    # Time/date placeholders
    if _has_word(lower, "time"):
        return "Your watch and phone are the best source for that. I can help with how you spend it though. What feels most important right now?"
    if _has_word(lower, "date"):
        return "Today is what matters. What are you hoping to do with it?"

    # Multi-word keys from the dictionary (longest first so "good morning" beats "morning")
    multi_first = sorted(_FALLBACK_RESPONSES.keys(), key=lambda k: -len(k))
    for key in multi_first:
        if _has_word(lower, key):
            return _FALLBACK_RESPONSES[key]

    # Last-resort generic — never silent
    return (
        "I hear you, and I am here. Tell me a little more, and we will take the next small step together. "
        "What feels most present for you right now?"
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

    def _extract_content(payload: dict) -> str:
        try:
            return (payload["choices"][0]["message"]["content"] or "").strip()
        except (KeyError, IndexError, TypeError):
            return ""

    reply = _extract_content(data)

    # If the model returned something but it was cut off (very short, no ending
    # punctuation, or a trailing comma), retry once. Some models (big-pickle)
    # occasionally stop mid-sentence. After one retry, fall back to local
    # instead of returning a truncated reply.
    def _looks_complete(text: str) -> bool:
        if not text:
            return False
        if len(text) < 50:
            return False
        return text[-1] in ".!?'\"" or text.endswith("\u2728")

    if not _looks_complete(reply):
        try:
            retry = await client.post(OPENCODE_URL, json=payload, headers=headers)
            if retry.status_code == 200:
                retry_reply = _extract_content(retry.json())
                if _looks_complete(retry_reply):
                    reply = retry_reply
        except Exception:
            # Retry is best-effort; fall through to fallback below
            pass

    # Some models (e.g. big-pickle) return empty content for very short or
    # trivial messages, or truncated replies. Fall back to a local Lumina-
    # style response so the user never sees a silent or cut-off bubble.
    if not _looks_complete(reply):
        reply = local_fallback(req.message)

    return ChatResponse(reply=reply)
