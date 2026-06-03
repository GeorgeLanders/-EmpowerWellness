#!/bin/bash
# Generate Lumina TTS audio for 8 new exercises
# Uses edge-tts with calm, warm female voice (en-US-AriaNeural)

set -e
PROJECT="C:/Users/George/Desktop/EmpowerWellness"
OUT_DIR="$PROJECT/assets/videos/exercise-videos/new_audio"
mkdir -p "$OUT_DIR"

VOICE="en-US-AriaNeural"

gen() {
  local id="$1"
  local steps_json="$2"
  echo "--- $id ---"
  /c/Python314/python - "$id" "$steps_json" <<'PYEOF'
import sys, subprocess, os, json, asyncio
from pathlib import Path

id = sys.argv[1]
steps = json.loads(sys.argv[2])
OUT_DIR = Path("C:/Users/George/Desktop/EmpowerWellness/assets/videos/exercise-videos/new_audio")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Build the full voice-over script with pauses between steps
intro = f"Welcome. Let's begin {id.replace('-', ' ')}. Take a deep breath, and let's move together."
outro = "Wonderful work. Take a moment to notice how you feel. Be proud of yourself."

script_lines = [intro] + steps + [outro]
full_script = "  ".join(script_lines)  # 2 spaces creates natural pause in TTS

print(f"  Script: {full_script[:80]}...")

# Generate TTS using edge-tts
cmd = [
    "edge-tts",
    "--voice", "en-US-AriaNeural",
    "--rate", "-5%",   # slightly slower for seniors
    "--pitch", "-2Hz", # slightly lower, more soothing
    "--text", full_script,
    "--write-media", str(OUT_DIR / f"{id}.mp3"),
]
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"  ERROR: {result.stderr}")
    sys.exit(1)

# Get audio duration
probe = subprocess.run(
    ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
     str(OUT_DIR / f"{id}.mp3")],
    capture_output=True, text=True
)
dur = probe.stdout.strip()
size = os.path.getsize(OUT_DIR / f"{id}.mp3")
print(f"  OK: {dur}s, {size/1024:.0f}KB")
PYEOF
}

# 1. box-breathing
gen "box-breathing" '["Sit comfortably with your back straight and feet flat on the floor.", "Breathe in slowly through your nose for a count of four.", "Hold that breath gently for a count of four.", "Exhale slowly through your mouth for a count of four.", "Hold empty for a count of four. This is one complete box.", "Repeat this pattern for four minutes. Let each breath calm your mind."]'

# 2. body-scan
gen "body-scan" '["Lie down or sit in a comfortable, supported position.", "Close your eyes and take three slow, deep breaths.", "Bring your attention to the top of your head. Notice any sensation.", "Slowly move your awareness down to your forehead, your eyes, your jaw.", "Let your shoulders soften. Release any tension you find.", "Continue down through your chest, your arms, your hands.", "Notice your belly rising and falling with each breath.", "Move awareness to your hips, thighs, knees, and all the way to your toes.", "Rest here for a moment, feeling your whole body relaxed and at peace."]'

# 3. mindful-breath
gen "mindful-breath" '["Find a quiet place to sit. Allow your hands to rest in your lap.", "Gently close your eyes if that feels comfortable.", "Bring your full attention to the breath entering your nose.", "Notice the cool air as you breathe in, the warm air as you breathe out.", "When your mind wanders, that is normal. Gently return to the breath.", "Each breath is a fresh beginning. A new moment to be present.", "Continue this practice for a few more minutes. You are exactly where you need to be."]'

# 4. deep-relaxation
gen "deep-relaxation" '["Settle into a comfortable position, either sitting or lying down.", "Let your body become heavy and supported.", "Breathe in deeply through your nose, filling your lungs completely.", "Exhale slowly through pursed lips, like blowing out a candle gently.", "Let each exhale be longer than each inhale.", "Imagine tension leaving your body with every breath out.", "Allow your jaw to soften, your shoulders to drop, your hands to open.", "Stay here as long as you like. You are safe. You are calm."]'

# 5. side-steps
gen "side-steps" '["Stand tall with your feet together and hands at your sides.", "Step your right foot out to the side, about two feet wide.", "Bring your left foot to meet your right.", "Now step your left foot out to the side.", "Bring your right foot to meet your left.", "Continue stepping side to side at a steady, comfortable pace.", "Add arm swings if you like. You are getting your heart healthy."]'

# 6. seated-forward-fold
gen "seated-forward-fold" '["Sit on the edge of a sturdy chair with feet hip-width apart.", "Place your hands on your knees and sit tall.", "Slowly hinge forward from your hips, not your waist.", "Let your hands slide down toward your shins or ankles.", "Stop when you feel a gentle stretch in your back and hamstrings.", "Hold this position and breathe deeply for thirty seconds.", "Slowly roll back up to sitting. Lift your head last. Repeat twice more."]'

# 7. posture-reset
gen "posture-reset" '["Stand with your back against a wall.", "Your heels, buttocks, shoulders, and head should all touch the wall.", "Step your feet about four inches away from the wall.", "Press your lower back gently into the wall.", "Tuck your chin slightly so your head is level.", "Hold this position for thirty seconds. Feel your spine lengthen.", "Step away from the wall. Try to maintain this alignment as you move through your day."]'

# 8. wall-push-variation
gen "wall-push-variation" '["Stand facing a wall, about three feet away.", "Place your palms flat on the wall at shoulder height.", "Walk your feet back so your body is at an angle.", "Bend your elbows and lower your chest toward the wall.", "Push through your palms to return to the starting position.", "Keep your core engaged and your body in a straight line.", "Do twelve repetitions. Rest. Then do two more sets. You are building real strength."]'

echo ""
echo "=== All TTS audio generated ==="
ls -lh "$OUT_DIR"
