"""
Generate beautiful AI-style diorama world images for EmpowerWellness.
Uses PIL to create stunning glow/gradient images without any cloud services.
Produces 5 world states: Seed, Sprout, Tree, Garden, Empire.
"""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import os
import math
import random

random.seed(42)

OUTPUT = r"C:\Users\George\Desktop\EmpowerWellness\assets\diorama"
os.makedirs(OUTPUT, exist_ok=True)

SIZE = (1024, 1024)
BG = (11, 5, 26)  # deepSpace #0B051A


def make_gradient_bg(size, color1, color2):
    base = Image.new("RGBA", size)
    for y in range(size[1]):
        r = int(color1[0] + (color2[0] - color1[0]) * y / size[1])
        g = int(color1[1] + (color2[1] - color1[1]) * y / size[1])
        b = int(color1[2] + (color2[2] - color1[2]) * y / size[1])
        ImageDraw.Draw(base).line([(0, y), (size[0], y)], fill=(r, g, b, 255))
    return base


def add_glow_layer(img, cx, cy, radius, color, intensity=1.0):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for r in range(radius + 1, 0, -1):
        alpha = int(intensity * 200 * (1 - r / radius) ** 2)
        if alpha > 0:
            draw.ellipse(
                [cx - r, cy - r, cx + r, cy + r],
                fill=(color[0], color[1], color[2], min(alpha, 255)),
            )
    return Image.alpha_composite(img, layer)


def add_particles(img, cx, cy, spread, color, count=30):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for _ in range(count):
        angle = random.random() * 2 * math.pi
        dist = random.random() * spread
        x = cx + math.cos(angle) * dist
        y = cy + math.sin(angle) * dist
        size = random.randint(1, 4)
        alpha = int(random.random() * 150 + 50)
        draw.ellipse(
            [x - size, y - size, x + size, y + size],
            fill=(color[0], color[1], color[2], alpha),
        )
    return Image.alpha_composite(img, layer)


def add_text_centered(img, text, color, y_offset=-40, size=36):
    try:
        font = ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", size)
    except Exception:
        font = ImageFont.load_default()
    bbox = ImageDraw.Draw(img).textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = (img.size[0] - tw) // 2
    y = img.size[1] // 2 + y_offset
    draw = ImageDraw.Draw(img)
    # shadow
    draw.text((x + 2, y + 2), text, fill=(0, 0, 0, 100), font=font)
    draw.text((x, y), text, fill=color + (255,), font=font)
    return img


def save(img, name):
    path = os.path.join(OUTPUT, f"{name}.png")
    img = img.filter(ImageFilter.GaussianBlur(radius=0))
    img.save(path)
    print(f"  {path}")


# ============================================================
# WORLD 1 — SEED (purple glowing orb in void)
# ============================================================
print("Generating world_seed.png ...")
img = make_gradient_bg(SIZE, (11, 5, 26), (30, 10, 70))
# Nebula blobs
for _ in range(8):
    bx, by = random.randint(100, 900), random.randint(100, 900)
    br = random.randint(80, 200)
    bc = random.choice([(139, 92, 246), (0, 245, 255), (255, 184, 0)])
    img = add_glow_layer(img, bx, by, br, bc, 0.3)
# Central seed
cx, cy = 512, 480
img = add_glow_layer(img, cx, cy, 200, (139, 92, 246), 0.5)
img = add_glow_layer(img, cx, cy, 120, (180, 130, 255), 0.6)
img = add_glow_layer(img, cx, cy, 60, (220, 180, 255), 0.8)
# Core
core = Image.new("RGBA", SIZE, (0, 0, 0, 0))
ImageDraw.Draw(core).ellipse([cx - 25, cy - 25, cx + 25, cy + 25], fill=(255, 255, 255, 200))
img = Image.alpha_composite(img, core)
# Particles
img = add_particles(img, cx, cy, 350, (139, 92, 246), 50)
img = add_text_centered(img, "SEED", (200, 170, 255), y_offset=160, size=48)
save(img, "world_seed")


# ============================================================
# WORLD 2 — SPROUT (cyan-green sprout emerging)
# ============================================================
print("Generating world_sprout.png ...")
img = make_gradient_bg(SIZE, (5, 15, 30), (10, 40, 60))
for _ in range(6):
    bx, by = random.randint(100, 900), random.randint(100, 900)
    br = random.randint(60, 180)
    bc = random.choice([(0, 245, 255), (0, 245, 147), (139, 92, 246)])
    img = add_glow_layer(img, bx, by, br, bc, 0.25)
cx, cy = 512, 520
# Ground glow
img = add_glow_layer(img, cx, cy + 80, 250, (0, 200, 120), 0.2)
# Sprout stem
stem_layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
draw = ImageDraw.Draw(stem_layer)
# Curved stem using bezier-style points
points = []
for t in range(0, 101, 2):
    frac = t / 100
    sx = cx + math.sin(frac * 3) * 20
    sy = cy + 60 - frac * 200
    points.append((sx, sy))
if len(points) > 1:
    draw.line(points, fill=(0, 245, 147, 200), width=8)
img = Image.alpha_composite(img, stem_layer)
# Leaves
for angle in [-0.6, 0.6]:
    lx = cx + math.cos(angle) * 30
    ly = cy - 80 + abs(math.sin(angle)) * 20
    img = add_glow_layer(img, int(lx), int(ly), 50, (0, 245, 255), 0.5)
    img = add_glow_layer(img, int(lx), int(ly), 25, (200, 255, 230), 0.7)
# Top glow
img = add_glow_layer(img, cx, cy - 150, 80, (0, 245, 255), 0.6)
img = add_glow_layer(img, cx, cy - 150, 40, (200, 255, 240), 0.8)
# Particles
img = add_particles(img, cx, 400, 400, (0, 245, 255), 60)
img = add_particles(img, cx, 400, 400, (0, 245, 147), 40)
img = add_text_centered(img, "SPROUT", (150, 255, 230), y_offset=180, size=48)
save(img, "world_sprout")


# ============================================================
# WORLD 3 — TREE (full glowing tree with branches)
# ============================================================
print("Generating world_tree.png ...")
img = make_gradient_bg(SIZE, (10, 20, 15), (20, 50, 40))
for _ in range(10):
    bx, by = random.randint(50, 950), random.randint(50, 950)
    br = random.randint(100, 300)
    bc = random.choice([(0, 245, 147), (139, 92, 246), (0, 245, 255), (255, 184, 0)])
    img = add_glow_layer(img, bx, by, br, bc, 0.2)
cx, cy = 512, 580
# Ground
img = add_glow_layer(img, cx, cy + 60, 200, (0, 180, 100), 0.15)
# Trunk
trunk_layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
draw = ImageDraw.Draw(trunk_layer)
for t in range(0, 101, 2):
    frac = t / 100
    sx = cx + math.sin(frac * 5) * 8
    sy = cy + 50 - frac * 300
    w = max(2, int(12 * (1 - frac * 0.8)))
    draw.ellipse([sx - w, sy - w, sx + w, sy + w], fill=(0, 220, 130, 180))
img = Image.alpha_composite(img, trunk_layer)
# Canopy clusters
for dx, dy, r in [(-60, -250, 80), (60, -260, 90), (0, -300, 100), (-40, -200, 60), (50, -210, 70)]:
    img = add_glow_layer(img, cx + dx, cy + dy, r, (0, 245, 147), 0.4)
    img = add_glow_layer(img, cx + dx, cy + dy, r // 2, (150, 255, 200), 0.6)
# Crown
img = add_glow_layer(img, cx, cy - 280, 130, (0, 245, 147), 0.5)
img = add_glow_layer(img, cx, cy - 280, 60, (200, 255, 220), 0.7)
# Floating particles
img = add_particles(img, cx, cy - 100, 500, (0, 245, 147), 70)
img = add_particles(img, cx, cy - 100, 500, (0, 245, 255), 30)
img = add_text_centered(img, "TREE", (150, 255, 200), y_offset=200, size=52)
save(img, "world_tree")


# ============================================================
# WORLD 4 — GARDEN (cluster of plants and flowers)
# ============================================================
print("Generating world_garden.png ...")
img = make_gradient_bg(SIZE, (15, 10, 5), (40, 30, 10))
# Rich nebula
for _ in range(15):
    bx, by = random.randint(50, 950), random.randint(50, 950)
    br = random.randint(80, 250)
    bc = random.choice([(255, 184, 0), (232, 168, 124), (255, 51, 102), (139, 92, 246)])
    img = add_glow_layer(img, bx, by, br, bc, 0.2)
# Ground plane
ground_layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
draw = ImageDraw.Draw(ground_layer)
for x in range(0, SIZE[0], 4):
    h = 60 + int(math.sin(x * 0.02) * 20) + random.randint(-10, 10)
    y = SIZE[1] - h
    draw.line([(x, SIZE[1]), (x, y)], fill=(0, 245, 147, 40), width=3)
img = Image.alpha_composite(img, ground_layer)
# Multiple plants
plant_colors = [(0, 245, 147), (0, 245, 255), (255, 184, 0), (232, 168, 124), (139, 92, 246)]
plant_positions = [(200, 650), (380, 620), (550, 640), (720, 630), (850, 660)]
for (px, py), pc in zip(plant_positions, plant_colors):
    img = add_glow_layer(img, px, py - 40, 70, pc, 0.4)
    img = add_glow_layer(img, px, py - 80, 50, pc, 0.5)
    img = add_glow_layer(img, px, py - 40, 15, (255, 255, 255), 0.8)
    # Small flowers around
    for _ in range(5):
        fx = px + random.randint(-60, 60)
        fy = py + random.randint(-120, 20)
        img = add_glow_layer(img, fx, fy, 15, random.choice(plant_colors), 0.6)
# Firefly particles
for _ in range(80):
    px = random.randint(50, 950)
    py = random.randint(100, 700)
    pc = random.choice([(255, 184, 0), (255, 200, 100), (0, 245, 255)])
    img = add_glow_layer(img, px, py, random.randint(3, 8), pc, 0.7)
img = add_text_centered(img, "GARDEN", (255, 220, 150), y_offset=220, size=52)
save(img, "world_garden")


# ============================================================
# WORLD 5 — EMPIRE (floating glass city in space)
# ============================================================
print("Generating world_empire.png ...")
img = make_gradient_bg(SIZE, (15, 5, 30), (50, 20, 80))
# Star field
for _ in range(200):
    sx, sy = random.randint(0, 1023), random.randint(0, 1023)
    bright = random.randint(100, 255)
    size = random.randint(1, 3)
    alpha = random.randint(50, 200)
    pc = random.choice([(255, 51, 102), (255, 184, 0), (139, 92, 246), (0, 245, 255), (255, 255, 255)])
    ImageDraw.Draw(img).ellipse([sx - size, sy - size, sx + size, sy + size], fill=(pc[0], pc[1], pc[2], alpha))
# Nebula background
for _ in range(12):
    bx, by = random.randint(0, 1024), random.randint(0, 1024)
    br = random.randint(100, 350)
    bc = random.choice([(255, 51, 102), (139, 92, 246), (255, 184, 0), (0, 245, 255)])
    img = add_glow_layer(img, bx, by, br, bc, 0.25)
# Central floating structure
cx, cy = 512, 450
# Main platform
img = add_glow_layer(img, cx, cy + 150, 150, (139, 92, 246), 0.3)
# Towers
for dx, dy, h, c in [(-150, -50, 200, (255, 51, 102)), (-80, -120, 280, (0, 245, 255)),
                      (0, -150, 350, (139, 92, 246)), (80, -130, 300, (255, 184, 0)),
                      (150, -60, 220, (0, 245, 147)), (-200, 20, 150, (232, 168, 124)),
                      (200, 30, 170, (255, 51, 102))]:
    # Tower body glow
    img = add_glow_layer(img, cx + dx, cy + dy, 30, c, 0.5)
    img = add_glow_layer(img, cx + dx, cy + dy, 12, (255, 255, 255), 0.6)
    # Light beam upward
    beam_layer = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    bd = ImageDraw.Draw(beam_layer)
    for t in range(0, h, 2):
        frac = t / h
        alpha = int(60 * (1 - frac))
        bw = int(8 * frac)
        bd.ellipse([cx + dx - bw, cy + dy - t - bw, cx + dx + bw, cy + dy - t + bw],
                    fill=(c[0], c[1], c[2], alpha))
    img = Image.alpha_composite(img, beam_layer)
# Top dome
img = add_glow_layer(img, cx, cy - 180, 60, (255, 255, 255), 0.5)
img = add_glow_layer(img, cx, cy - 180, 100, (139, 92, 246), 0.4)
# Energy particles
for _ in range(100):
    px = random.randint(100, 900)
    py = random.randint(50, 700)
    pc = random.choice([(255, 51, 102), (255, 184, 0), (139, 92, 246), (0, 245, 255)])
    img = add_glow_layer(img, px, py, random.randint(2, 6), pc, 0.6)
img = add_text_centered(img, "EMPIRE", (255, 200, 220), y_offset=250, size=56)
save(img, "world_empire")

print("\nAll 5 diorama images generated!")
print(f"Location: {OUTPUT}")
