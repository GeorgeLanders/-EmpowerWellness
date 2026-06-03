#!/bin/bash
# Merge 8 new real human clips with new Lumina TTS audio tracks
# Output goes directly to assets/videos/ (since these are new exercises)

set -e
PROJECT="C:/Users/George/Desktop/EmpowerWellness"
REAL_CLIPS="$PROJECT/build/app/outputs/video"
NEW_AUDIO="$PROJECT/assets/videos/exercise-videos/new_audio"
OUT_DIR="$PROJECT/assets/videos"
mkdir -p "$OUT_DIR"

merge() {
  local id="$1"
  local real_clip="$2"
  echo ""
  echo "--- $id ---"
  if [ ! -f "$REAL_CLIPS/$real_clip" ]; then
    echo "SKIP: real clip not found: $real_clip"
    return 1
  fi
  if [ ! -f "$NEW_AUDIO/$id.mp3" ]; then
    echo "SKIP: audio not found: $id.mp3"
    return 1
  fi
  ffmpeg -y \
    -i "$REAL_CLIPS/$real_clip" \
    -i "$NEW_AUDIO/$id.mp3" \
    -c:v libx264 -preset fast -crf 18 \
    -c:a aac -b:a 128k \
    -map 0:v:0 -map 1:a:0 \
    -shortest \
    "$OUT_DIR/$id.mp4" 2>&1 | tail -2
  size=$(du -h "$OUT_DIR/$id.mp4" | cut -f1)
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT_DIR/$id.mp4" 2>/dev/null)
  audio=$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$OUT_DIR/$id.mp4" 2>/dev/null | head -1)
  echo "OK: ${dur}s audio=${audio:-MISSING} size=$size"
}

# Breathing & Mindfulness
merge "box-breathing" "Box Breathing.mp4"
merge "body-scan" "Body Scan Relaxation.mp4"
merge "mindful-breath" "Mindfull.mp4"
merge "deep-relaxation" "Relaxation Breath.mp4"

# Cardio
merge "side-steps" "side steps.mp4"

# Stretch
merge "seated-forward-fold" "Seated forward fold.mp4"

# Posture
merge "posture-reset" "person leaning against wall posture.mp4.mp4"

# Strength
merge "wall-push-variation" "Will push.mp4"

echo ""
echo "=== All 8 new exercises merged ==="
ls -lh "$OUT_DIR" | grep -E "(box-breathing|body-scan|mindful-breath|deep-relaxation|side-steps|seated-forward-fold|posture-reset|wall-push-variation)"
