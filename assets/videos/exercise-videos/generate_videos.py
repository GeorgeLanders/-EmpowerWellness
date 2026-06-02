"""
Generate exercise instruction videos using Python + Pillow + FFmpeg.
Creates MP4 videos with text-based step-by-step instructions.
Renders at 1fps then uses FFmpeg to upscale to 30fps.
"""
import os
import subprocess
import math
import shutil
from PIL import Image, ImageDraw, ImageFont

OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT_DIR, exist_ok=True)

WIDTH, HEIGHT = 1080, 1920
FPS = 30
RENDER_FPS = 1  # Render 1 frame per second, FFmpeg will interpolate

BG_COLOR = (11, 5, 26)
WHITE = (255, 255, 255)
MUTED = (107, 91, 139)
SECONDARY = (176, 165, 192)

CAT_COLORS = {
    "Seated": (0, 245, 255),
    "Standing": (192, 132, 252),
    "Stretch": (232, 168, 124),
    "Strength": (255, 51, 102),
    "Walk": (52, 211, 153),
}

EXERCISES = [
    {
        "id": "indoor-walk",
        "title": "Indoor Walk",
        "duration": 600,
        "category": "Walk",
        "bodyPart": "Cardio",
        "description": "Walk at home to get your body moving.",
        "steps": [
            "Find a clear path in your home.",
            "Start walking at a comfortable, easy pace.",
            "Swing your arms naturally as you walk.",
            "Keep your posture tall and your head up high.",
            "Breathe deeply. Enjoy the movement.",
            "Every single step counts toward your health.",
        ],
    },
    {
        "id": "nature-walk",
        "title": "Nature Walk",
        "duration": 900,
        "category": "Walk",
        "bodyPart": "Cardio",
        "description": "Step outside for a refreshing walk in nature.",
        "steps": [
            "Put on comfortable shoes and head outside.",
            "Start slowly. Gradually increase your pace.",
            "Notice the sights, sounds, and smells around you.",
            "Breathe fresh air into your lungs.",
            "Walk for at least 15 minutes if possible.",
            "Being in nature boosts your mood and energy.",
        ],
    },
]


def get_font(size):
    font_paths = [
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/calibri.ttf",
    ]
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except:
                pass
    return ImageFont.load_default()


def render_exercise(exercise):
    ex_id = exercise["id"]
    title = exercise["title"]
    duration = exercise["duration"]
    category = exercise["category"]
    body_part = exercise["bodyPart"]
    description = exercise["description"]
    steps = exercise["steps"]

    output = os.path.join(OUT_DIR, f"{ex_id}.mp4")
    if os.path.exists(output) and os.path.getsize(output) > 50000:
        print(f"  SKIP (exists): {title}")
        return True

    print(f"  Rendering: {title} ({duration}s)...")

    cat_color = CAT_COLORS.get(category, (139, 92, 246))
    step_duration = duration / len(steps)
    total_render_frames = duration * RENDER_FPS

    tmp_dir = os.path.join(OUT_DIR, f"_tmp_{ex_id}")
    os.makedirs(tmp_dir, exist_ok=True)

    font_title = get_font(52)
    font_cat = get_font(28)
    font_body = get_font(24)
    font_step = get_font(30)
    font_timer = get_font(36)
    font_small = get_font(18)

    try:
        for frame_num in range(total_render_frames):
            t = frame_num / RENDER_FPS

            img = Image.new("RGB", (WIDTH, HEIGHT), BG_COLOR)
            draw = ImageDraw.Draw(img)

            # Background blob
            bx = int(WIDTH / 2 + math.sin(t * 0.3) * 100)
            by = int(HEIGHT / 3 + math.cos(t * 0.2) * 60)
            for r in range(180, 0, -10):
                a = max(1, int(6 * (1 - r / 180)))
                color = (min(255, cat_color[0] // max(1,a)), min(255, cat_color[1] // max(1,a)), min(255, cat_color[2] // max(1,a)))
                draw.ellipse([bx - r, by - r, bx + r, by + r], fill=color)

            # Category badge
            draw.rounded_rectangle([50, 40, 280, 88], radius=100, fill=cat_color, outline=cat_color, width=2)
            draw.text((165, 48), category.upper(), fill=cat_color, font=font_cat, anchor="mm")

            # Timer
            remaining = max(0, duration - t)
            rm = int(remaining // 60)
            rs = int(remaining % 60)
            draw.rounded_rectangle([WIDTH - 240, 40, WIDTH - 50, 88], radius=100, fill=(255, 255, 255), outline=(255, 255, 255), width=2)
            draw.text((WIDTH - 145, 48), f"{rm}:{rs:02d}", fill=WHITE, font=font_timer, anchor="mm")

            # Title
            draw.text((WIDTH // 2, 170), title, fill=WHITE, font=font_title, anchor="mm")

            # Body part
            draw.rounded_rectangle([WIDTH // 2 - 70, 235, WIDTH // 2 + 70, 272], radius=8, fill=cat_color)
            draw.text((WIDTH // 2, 242), body_part, fill=cat_color, font=font_small, anchor="mm")

            # Description
            words = description.split()
            lines = []
            line = ""
            for w in words:
                test = line + " " + w if line else w
                bbox = draw.textbbox((0, 0), test, font=font_body)
                if bbox[2] < WIDTH - 100:
                    line = test
                else:
                    lines.append(line)
                    line = w
            if line:
                lines.append(line)
            y = 300
            for l in lines:
                draw.text((WIDTH // 2, y), l, fill=SECONDARY, font=font_body, anchor="mm")
                y += 32

            # Progress bar
            prog = min(1.0, t / duration)
            draw.rounded_rectangle([50, 380, WIDTH - 50, 388], radius=4, fill=(255, 255, 255, 20))
            if prog > 0:
                draw.rounded_rectangle([50, 380, 50 + int((WIDTH - 100) * prog), 388], radius=4, fill=cat_color)

            # Steps
            current_step = min(len(steps) - 1, max(0, int((t - step_duration * 0.5) / step_duration)))
            sy = 440
            for i, step in enumerate(steps):
                if sy > HEIGHT - 120:
                    break
                active = i == current_step
                done = i < current_step

                cc = cat_color if active else (MUTED if done else (200, 200, 200))
                draw.ellipse([80, sy + 10, 128, sy + 58], fill=cc)
                if active:
                    draw.ellipse([76, sy + 6, 132, sy + 62], outline=cat_color, width=2)

                txt = str(i + 1) if not done else "✓"
                draw.text((104, sy + 25), txt, fill=WHITE if active or done else MUTED, font=font_step, anchor="mm")

                sc = WHITE if active else (MUTED if done else SECONDARY)
                max_c = 48
                ds = step[:max_c] + "..." if len(step) > max_c else step
                draw.text((145, sy + 12), ds, fill=sc, font=font_body)

                if active:
                    sp = min(1.0, (t - i * step_duration) / step_duration)
                    draw.rounded_rectangle([145, sy + 55, WIDTH - 50, sy + 61], radius=3, fill=(255, 255, 200))
                    if sp > 0:
                        draw.rounded_rectangle([145, sy + 55, 145 + int((WIDTH - 195) * sp), sy + 61], radius=3, fill=cat_color)

                sy += 90

            # Bottom
            ey = HEIGHT - 110
            if remaining <= 0:
                msg, mc = "Exercise complete. Great job.", (52, 211, 153)
            elif remaining < 60:
                msg, mc = "Almost there. Keep going.", cat_color
            else:
                msg, mc = "You are doing amazing.", (255, 184, 0)
            draw.rounded_rectangle([50, ey, WIDTH - 50, ey + 55], radius=16, fill=(255, 255, 255), outline=(255, 255, 255), width=2)
            draw.text((WIDTH // 2, ey + 15), msg, fill=mc, font=font_body, anchor="mm")

            img.save(os.path.join(tmp_dir, f"frame_{frame_num:06d}.png"), "PNG")

            if frame_num % 30 == 0:
                print(f"    Frame {frame_num}/{total_render_frames}...")

        # Encode with FFmpeg - interpolate from 1fps to 30fps
        print(f"    Encoding...")
        cmd = [
            "ffmpeg", "-y",
            "-framerate", str(RENDER_FPS),
            "-i", os.path.join(tmp_dir, "frame_%06d.png"),
            "-vf", f"fps={FPS}",
            "-c:v", "libx264",
            "-preset", "fast",
            "-crf", "26",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart",
            "-an",
            output,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

        if result.returncode == 0 and os.path.exists(output):
            sz = os.path.getsize(output)
            print(f"    OK: {(sz/1024/1024):.1f}MB")
            return True
        else:
            print(f"    FFmpeg error: {result.stderr[:200]}")
            return False

    except Exception as e:
        print(f"    Error: {e}")
        return False
    finally:
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir, ignore_errors=True)


def main():
    print(f"Generating {len(EXERCISES)} videos...\n")
    s = f = 0
    for ex in EXERCISES:
        if render_exercise(ex):
            s += 1
        else:
            f += 1
    print(f"\nResults: {s} done, {f} failed")
    files = [f for f in os.listdir(OUT_DIR) if f.endswith(".mp4") and not f.startswith("_")]
    total = sum(os.path.getsize(os.path.join(OUT_DIR, ff)) for ff in files)
    print(f"{len(files)} total videos, {(total/1024/1024):.1f}MB")


if __name__ == "__main__":
    main()
