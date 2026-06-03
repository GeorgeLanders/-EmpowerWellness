import requests
import json
import time
import os
import re

S_KEY_FILE = r"C:\Users\George\Desktop\EmpowerWellness\build\app\outputs\FAL key.txt"

def get_key():
    with open(S_KEY_FILE, 'r') as f:
        content = f.read()
        match = re.search(r':([a-z0-9-]+:[a-z0-9]+)', content)
        return match.group(1) if match else None

def generate_video(prompt, model_id="fal-ai/luma-dream-machine", aspect_ratio="9:16"):
    key = get_key()
    if not key:
        print("Error: FAL key not found.")
        return None
    
    headers = {
        "Authorization": f"Key {key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "prompt": prompt,
        "aspect_ratio": aspect_ratio
    }
    
    # Submit job to queue
    queue_url = f"https://queue.fal.run/{model_id}"
    print(f"Submitting job for: '{prompt}' to {queue_url}...")
    response = requests.post(queue_url, headers=headers, json=payload)
    
    if response.status_code != 200:
        print(f"Failed to submit job: {response.status_code} - {response.text}")
        return None
        
    res_json = response.json()
    request_id = res_json.get("request_id")
    status_url = res_json.get("status_url")
    response_url = res_json.get("response_url")
    
    print(f"Job submitted. Request ID: {request_id}")
    
    # Poll status
    while True:
        status_response = requests.get(status_url, headers=headers)
        if status_response.status_code != 200:
            print(f"Failed to get status: {status_response.status_code}")
            time.sleep(5)
            continue
            
        status_data = status_response.json()
        # The status field could be IN_QUEUE, IN_PROGRESS, COMPLETED, FAILED
        status = status_data.get("status", "UNKNOWN")
        print(f"Current status: {status}")
        
        if status == "COMPLETED":
            # Fetch response
            resp = requests.get(response_url, headers=headers)
            if resp.status_code == 200:
                return resp.json()
            else:
                print(f"Failed to get final response: {resp.status_code}")
                return None
        elif status == "FAILED":
            print(f"Job failed: {status_data}")
            return None
            
        time.sleep(5)

if __name__ == "__main__":
    prompt = "A healthy senior woman marching while sitting in a chair, portrait format, soft lighting"
    res = generate_video(prompt)
    print("Result:")
    print(json.dumps(res, indent=2))
