#!/bin/bash
# Merge remaining real human clips with Lumina voice-over
# Uses the _audio.mp4 files (Lumina voice) merged with real clips from build/app/outputs/video/

set -e

PROJECT="C:/Users/George/Desktop/EmpowerWellness"
REAL_CLIPS="$PROJECT/build/app/outputs/video"
AUDIO_DIR="$PROJECT/assets/videos/exercise-videos/out"
OUT_DIR="$PROJECT/assets/videos/final_premium"

echo "=== Merging remaining real clips with Lumina voice ==="

# ── 1. arm-circles: Seated Arm Circles.mp4 (18.9s) + arm-circles_audio track ---
echo ""
echo "--- arm-circles ---"
ffmpeg -y \
  -i "$REAL_CLIPS/Seated Arm Circles.mp4" \
  -i "$AUDIO_DIR/arm-circles.mp4" \
  -c:v libx264 -preset fast -crf 18 \
  -c:a aac \
  -shortest \
  "$OUT_DIR/arm-circles.mp4" 2>&1 | tail -3
echo "OK: $(du -h "$OUT_DIR/arm-circles.mp4" | cut -f1)"

# ── 2. cat-cow: cat-cowSTRETCH.mp4 (12.4s) + cat-cow_audio track ---
echo ""
echo "--- cat-cow ---"
AUDIO_CATCOW=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$AUDIO_DIR/cat-cow.mp4" 2>/dev/null | head -1)
if [ -z "$AUDIO_CATCOW" ]; then
  echo "No audio in cat-cow remotion render, using as-is"
  cp "$AUDIO_DIR/cat-cow.mp4" "$OUT_DIR/cat-cow.mp4"
else
  ffmpeg -y \
    -i "$REAL_CLIPS/cat-cowSTRETCH.mp4" \
    -i "$AUDIO_DIR/cat-cow.mp4" \
    -c:v libx264 -preset fast -crf 18 \
    -c:a aac \
    -shortest \
    "$OUT_DIR/cat-cow.mp4" 2>&1 | tail -3
fi
echo "OK: $(du -h "$OUT_DIR/cat-cow.mp4" | cut -f1)"

# ── 3. nature-walk: Gentle Morning Stroll.mp4 (5s) + nature-walk_audio ---
# Note: the real clip already has audio, so we replace it with Lumina
echo ""
echo "--- nature-walk ---"
ffmpeg -y \
  -i "$REAL_CLIPS/Gentle Morning Stroll.mp4" \
  -i "$AUDIO_DIR/nature-walk.mp4" \
  -c:v libx264 -preset fast -crf 18 \
  -c:a aac \
  -map 0:v:0 -map 1:a:0 \
  -shortest \
  "$OUT_DIR/nature-walk.mp4" 2>&1 | tail -3
echo "OK: $(du -h "$OUT_DIR/nature-walk.mp4" | cut -f1)"

# ── 4. seated-leg-lifts: use seated hamstring stretch (14.6s) as it's a better match ---
echo ""
echo "--- seated-leg-lifts ---"
ffmpeg -y \
  -i "$REAL_CLIPS/seated hamstring stretch chair.mp4.mp4" \
  -i "$AUDIO_DIR/seated-leg-lifts.mp4" \
  -c:v libx264 -preset fast -crf 18 \
  -c:a aac \
  -map 0:v:0 -map 1:a:0 \
  -shortest \
  "$OUT_DIR/seated-leg-lifts.mp4" 2>&1 | tail -3
echo "OK: $(du -h "$OUT_DIR/seated-leg-lifts.mp4" | cut -f1)"

# ── 5. torso-twists: Seated Torso twist.mp4 (9.6s) + torso-twists_audio ---
echo ""
echo "--- torso-twists ---"
ffmpeg -y \
  -i "$REAL_CLIPS/Seated Torso twist.mp4" \
  -i "$AUDIO_DIR/torso-twists.mp4" \
  -c:v libx264 -preset fast -crf 18 \
  -c:a aac \
  -map 0:v:0 -map 1:a:0 \
  -shortest \
  "$OUT_DIR/torso-twists.mp4" 2>&1 | tail -3
echo "OK: $(du -h "$OUT_DIR/torso-twists.mp4" | cut -f1)"

# ── 6. neck-release: Gentle Neck Stretch.mp4 (17s) + neck-release_audio ---
echo ""
echo "--- neck-release ---"
ffmpeg -y \
  -i "$REAL_CLIPS/Gentle Neck Stretch.mp4" \
  -i "$AUDIO_DIR/neck-release.mp4" \
  -c:v libx264 -preset fast -crf 18 \
  -c:a aac \
  -map 0:v:0 -map 1:a:0 \
  -shortest \
  "$OUT_DIR/neck-release.mp4" 2>&1 | tail -3
echo "OK: $(du -h "$OUT_DIR/neck-release.mp4" | cut -f1)"

echo ""
echo "=== Verifying all 16 final videos ==="
for f in "$OUT_DIR"/*.mp4; do
  name=$(basename "$f")
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null)
  audio=$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$f" 2>/dev/null | head -1)
  size=$(du -h "$f" | cut -f1)
  echo "$name: ${dur}s audio=${audio:-MISSING} size=$size"
done

echo ""
echo "=== DONE ==="
