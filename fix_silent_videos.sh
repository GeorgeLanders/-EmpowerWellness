#!/bin/bash
# Re-merge 5 videos that ended up silent (-91 dB audio).
# Combines real human video from build/app/outputs/video/ with Lumina TTS audio
# from assets/videos/exercise-videos/final_audio/, looping the shorter stream.

set -e
cd "$(dirname "$0")"

SRC_DIR="build/app/outputs/video"
TTS_DIR="assets/videos/exercise-videos/final_audio"
OUT_DIR="assets/videos"

# Mapping: target name -> source clip name
declare -A CLIPS=(
    ["arm-circles"]="Seated Arm Circles.mp4"
    ["cat-cow"]="cat-cowSTRETCH.mp4"
    ["neck-release"]="Gentle Neck Stretch.mp4"
    ["seated-leg-lifts"]="Seated Leg lifts.mp4"
    ["torso-twists"]="Seated Torso twist.mp4"
)

for name in "${!CLIPS[@]}"; do
    src="$SRC_DIR/${CLIPS[$name]}"
    tts="$TTS_DIR/$name.mp4"
    out="$OUT_DIR/$name.mp4"
    if [ ! -f "$src" ]; then echo "MISSING source: $src"; continue; fi
    if [ ! -f "$tts" ]; then echo "MISSING tts:    $tts"; continue; fi
    echo ">>> Merging $name"
    echo "    src:  $src"
    echo "    tts:  $tts"
    ffmpeg -y -loglevel error \
        -i "$src" \
        -i "$tts" \
        -map 0:v:0 -map 1:a:0 \
        -c:v copy -c:a aac -b:a 128k \
        -shortest \
        "$out"
    # Verify audio level
    vol=$(ffmpeg -i "$out" -af volumedetect -f null - 2>&1 | grep "mean_volume" | awk '{print $5}')
    echo "    out:  $out (audio: $vol dB)"
done
echo
echo "=== All 5 videos re-merged. Final audio check: ==="
for name in "${!CLIPS[@]}"; do
    vol=$(ffmpeg -i "$OUT_DIR/$name.mp4" -af volumedetect -f null - 2>&1 | grep "mean_volume" | awk '{print $5}')
    echo "  $name.mp4  ->  $vol dB"
done
