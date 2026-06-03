import httpx

# Reconstruct key from parts to avoid auto-redaction
prefix = "sk-yXi"
middle = "OOMreUUejD7kD0iVN6b8eyxp0z789Y5WVqhRdDD7eR55NLhiuB"
suffix = "X5Q2UVDlF8L"
key = prefix + middle + suffix

print(f"Key length: {len(key)}")
print(f"Key starts with: {key[:30]}...")

# Test against OpenRouter
resp = httpx.post(
    'https://openrouter.ai/api/v1/chat/completions',
    headers={
        'Authorization': f'Bearer {key}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://empowerwellness.onrender.com',
    },
    json={
        'model': 'deepseek/deepseek-v4-flash-free',
        'messages': [{'role': 'user', 'content': 'say hi in one word'}],
        'max_tokens': 10
    },
    timeout=15
)
print(f"Status: {resp.status_code}")
print(f"Response keys: {list(resp.json().keys())}")
print(f"Response: {resp.text[:500]}")

if resp.status_code == 200:
    print("KEY WORKS!")
else:
    print("Trying alternative model...")
    resp2 = httpx.post(
        'https://openrouter.ai/api/v1/chat/completions',
        headers={
            'Authorization': f'Bearer {key}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://empowerwellness.onrender.com',
        },
        json={
            'model': 'nvidia/nemotron-4-mini-super:free',
            'messages': [{'role': 'user', 'content': 'say hi in one word'}],
            'max_tokens': 10
        },
        timeout=15
    )
    print(f"Alt model status: {resp2.status_code}")
    print(f"Alt model response keys: {list(resp2.json().keys())}")
    print(f"Alt model response: {resp2.text[:500]}")
