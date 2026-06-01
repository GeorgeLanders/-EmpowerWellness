from PIL import Image, ImageDraw
import os

base = r"C:\Users\George\Desktop\EmpowerWellness\assets\diorama"
os.makedirs(base, exist_ok=True)

colors = {
    "world_seed": (139, 92, 246),
    "world_sprout": (0, 245, 255),
    "world_tree": (0, 245, 147),
    "world_garden": (255, 184, 0),
    "world_empire": (255, 51, 102),
}

size = (512, 512)

for name, color in colors.items():
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center = (256, 256)
    radius = 120

    for r in range(radius + 60, radius, -2):
        alpha = max(0, int(80 * (1 - (r - radius) / 60)))
        draw.ellipse(
            [center[0] - r, center[1] - r, center[0] + r, center[1] + r],
            fill=(*color, alpha)
        )

    draw.ellipse(
        [center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius],
        fill=(*color, 200)
    )

    draw.ellipse(
        [center[0] - 50, center[1] - 50, center[0] + 50, center[1] + 50],
        fill=(255, 255, 255, 100)
    )

    img.save(os.path.join(base, f"{name}.png"))
    print(f"Created {name}.png")

vid_base = r"C:\Users\George\Desktop\EmpowerWellness\assets\videos"
os.makedirs(vid_base, exist_ok=True)

print(f"\nDiorama assets: {base}")
print(f"Videos dir: {vid_base}")
