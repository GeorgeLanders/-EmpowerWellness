"""Generate EmpowerWellness app icon and logo assets."""
import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets", "branding")
os.makedirs(OUT_DIR, exist_ok=True)

# ── Theme Colors ──
DEEP_SPACE = (11, 5, 26)
PRIMARY_PURPLE = (139, 92, 246)
NEON_CYAN = (0, 245, 255)
HOT_CORAL = (255, 51, 102)
WARM_GOLD = (255, 184, 0)
MINT_GREEN = (52, 211, 153)
PLASMA_VIOLET = (192, 132, 252)
ICE_BLUE = (103, 232, 249)
EMBER_ORANGE = (251, 146, 60)


def get_font(size):
    paths = [
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/calibri.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
    ]
    for fp in paths:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except:
                pass
    return ImageFont.load_default()


def draw_rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def radial_gradient(size, colors, center=None):
    """Create a radial gradient image."""
    if center is None:
        center = (size[0] // 2, size[1] // 2)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    max_dist = math.sqrt(center[0]**2 + center[1]**2)
    for y in range(size[1]):
        for x in range(size[0]):
            dx, dy = x - center[0], y - center[1]
            dist = math.sqrt(dx**2 + dy**2) / max_dist
            # Find which two colors to interpolate between
            num_segments = len(colors) - 1
            segment = min(int(dist * num_segments), num_segments - 1)
            local_t = (dist * num_segments) - segment
            c1, c2 = colors[segment], colors[segment + 1]
            r = int(c1[0] + (c2[0] - c1[0]) * local_t)
            g = int(c1[1] + (c2[1] - c1[1]) * local_t)
            b = int(c1[2] + (c2[2] - c1[2]) * local_t)
            alpha = int(255 * (1 - dist * 0.3))
            img.putpixel((x, y), (r, g, b, alpha))
    return img


def create_app_icon(size=1024):
    """Create the main app icon."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    radius = size * 0.42

    # 1. Background - rounded square with deep space
    bg_margin = size * 0.04
    bg = Image.new("RGBA", (size, size), DEEP_SPACE + (255,))
    bg_draw = ImageDraw.Draw(bg)
    draw_rounded_rect(bg_draw, 
        [bg_margin, bg_margin, size - bg_margin, size - bg_margin], 
        radius=size * 0.18, fill=DEEP_SPACE + (255,))
    bg = bg.filter(ImageFilter.GaussianBlur(radius=2))

    # 2. Outer glow ring
    for r in range(int(radius * 1.3), int(radius * 1.1), -1):
        alpha = max(0, int(15 * (1 - (r - radius * 1.1) / (radius * 0.2))))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], 
            fill=(PRIMARY_PURPLE[0], PRIMARY_PURPLE[1], PRIMARY_PURPLE[2], alpha))

    # 3. Main gradient circle
    circle = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    c_draw = ImageDraw.Draw(circle)

    # Draw with gradient using pixel approach for quality
    for y in range(size):
        for x in range(size):
            dx, dy = x - cx, y - cy
            dist = math.sqrt(dx**2 + dy**2)
            if dist <= radius:
                # Radial gradient: purple -> cyan -> coral
                t = dist / radius
                if t < 0.5:
                    t2 = t / 0.5
                    r = int(PRIMARY_PURPLE[0] + (NEON_CYAN[0] - PRIMARY_PURPLE[0]) * t2)
                    g = int(PRIMARY_PURPLE[1] + (NEON_CYAN[1] - PRIMARY_PURPLE[1]) * t2)
                    b = int(PRIMARY_PURPLE[2] + (NEON_CYAN[2] - PRIMARY_PURPLE[2]) * t2)
                else:
                    t2 = (t - 0.5) / 0.5
                    r = int(NEON_CYAN[0] + (HOT_CORAL[0] - NEON_CYAN[0]) * t2)
                    g = int(NEON_CYAN[1] + (HOT_CORAL[1] - NEON_CYAN[1]) * t2)
                    b = int(NEON_CYAN[2] + (HOT_CORAL[2] - NEON_CYAN[2]) * t2)
                circle.putpixel((x, y), (min(255, r), min(255, g), min(255, b), 220))

    # Apply subtle blur for smoothness
    circle = circle.filter(ImageFilter.GaussianBlur(radius=size * 0.005))
    img.paste(circle, (0, 0), circle)

    # 4. Glass highlight (crescent reflection on top-left)
    highlight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    h_draw = ImageDraw.Draw(highlight)
    hx, hy = int(cx - radius * 0.3), int(cy - radius * 0.35)
    hr = int(radius * 0.7)
    h_draw.ellipse([hx - hr, hy - hr, hx + hr, hy + hr], 
        fill=(255, 255, 255, 30))
    # Cut away the bottom half to make a crescent
    h_draw.ellipse([hx - hr, hy, hx + hr, hy + int(hr * 1.2)], 
        fill=(0, 0, 0, 0))
    highlight = highlight.filter(ImageFilter.GaussianBlur(radius=size * 0.04))
    img.paste(highlight, (0, 0), highlight)

    # 5. "E" monogram
    font_size = int(size * 0.38)
    font = get_font(font_size)
    # If no good font, draw manually
    if font_size > 80:
        # Draw a stylized "E" using shapes
        e_color = (255, 255, 255, 240)
        stroke_w = max(6, int(size * 0.04))
        spine_x = cx - int(radius * 0.35)
        arm_top = cy - int(radius * 0.35)
        arm_mid = cy
        arm_bot = cy + int(radius * 0.35)
        arm_len = int(radius * 0.55)
        
        # Vertical spine
        draw.rectangle([spine_x, arm_top - stroke_w, spine_x + stroke_w, arm_bot + stroke_w], 
            fill=e_color)
        # Top arm
        draw.rectangle([spine_x, arm_top - stroke_w, spine_x + arm_len, arm_top + stroke_w],
            fill=e_color)
        # Middle arm
        draw.rectangle([spine_x, arm_mid - stroke_w, spine_x + arm_len - int(arm_len * 0.2), arm_mid + stroke_w],
            fill=e_color)
        # Bottom arm
        draw.rectangle([spine_x, arm_bot - stroke_w, spine_x + arm_len, arm_bot + stroke_w],
            fill=e_color)

    # 6. Leaf accent growing from the "E"
    leaf_color = MINT_GREEN + (220,)
    leaf_base_x = spine_x + stroke_w + int(radius * 0.05)
    leaf_base_y = arm_bot + stroke_w + int(radius * 0.02)
    # Stem
    stem_end_x = leaf_base_x + int(radius * 0.15)
    stem_end_y = leaf_base_y - int(radius * 0.25)
    draw.line([leaf_base_x, leaf_base_y, stem_end_x, stem_end_y], 
        fill=leaf_color, width=max(3, int(size * 0.02)))
    # Leaf
    lx, ly = stem_end_x, stem_end_y
    leaf_r = int(radius * 0.12)
    draw.ellipse([lx - leaf_r, ly - leaf_r, lx + leaf_r, ly + leaf_r], 
        fill=leaf_color)
    # Leaf vein
    draw.line([lx - leaf_r, ly, lx + leaf_r, ly], 
        fill=(255, 255, 255, 100), width=max(1, int(size * 0.01)))

    # 7. Bottom tagline "EW"
    tag_font = get_font(int(size * 0.08))
    if tag_font:
        try:
            bbox = draw.textbbox((0, 0), "EW", font=tag_font)
            tw = bbox[2] - bbox[0]
            tx = cx - tw // 2
            ty = int(cy + radius * 0.7)
            draw.text((tx, ty), "EW", fill=(255, 255, 255, 120), font=tag_font)
        except:
            pass

    # 8. Subtle inner border (glass edge)
    border_r = radius + 2
    draw.ellipse([cx - border_r, cy - border_r, cx + border_r, cy + border_r], 
        outline=(255, 255, 255, 40), width=max(2, int(size * 0.005)))

    # Composite over background
    final = Image.new("RGBA", (size, size), DEEP_SPACE + (255,))
    final = Image.alpha_composite(final, img)
    
    return final.convert("RGB")


def create_in_app_logo(width=1080):
    """Create a horizontal in-app logo with 'EmpowerWellness' text."""
    height = int(width * 0.3)
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = width // 2, height // 2

    # Icon circle on the left
    icon_size = int(height * 0.7)
    icon_x = int(width * 0.08)
    icon_y = cy
    icon_r = icon_size // 2

    # Draw mini version of the icon
    for y in range(height):
        for x in range(width):
            dx, dy = x - icon_x, y - icon_y
            dist = math.sqrt(dx**2 + dy**2)
            if dist <= icon_r:
                t = dist / icon_r
                if t < 0.5:
                    t2 = t / 0.5
                    r = int(PRIMARY_PURPLE[0] + (NEON_CYAN[0] - PRIMARY_PURPLE[0]) * t2)
                    g = int(PRIMARY_PURPLE[1] + (NEON_CYAN[1] - PRIMARY_PURPLE[1]) * t2)
                    b = int(PRIMARY_PURPLE[2] + (NEON_CYAN[2] - PRIMARY_PURPLE[2]) * t2)
                else:
                    t2 = (t - 0.5) / 0.5
                    r = int(NEON_CYAN[0] + (HOT_CORAL[0] - NEON_CYAN[0]) * t2)
                    g = int(NEON_CYAN[1] + (HOT_CORAL[1] - NEON_CYAN[1]) * t2)
                    b = int(NEON_CYAN[2] + (HOT_CORAL[2] - NEON_CYAN[2]) * t2)
                img.putpixel((x, y), (min(255, r), min(255, g), min(255, b), 230))

    # Outer glow on icon
    for r in range(icon_r + 5, icon_r + 25):
        alpha = max(0, int(20 * (1 - (r - icon_r - 5) / 20)))
        draw.ellipse([icon_x - r, icon_y - r, icon_x + r, icon_y + r],
            outline=(PRIMARY_PURPLE[0], PRIMARY_PURPLE[1], PRIMARY_PURPLE[2], alpha))

    # "E" in the mini icon
    s = icon_r * 0.4
    sw = max(2, int(icon_r * 0.12))
    ex = icon_x - int(s * 0.3)
    ey = icon_y
    draw.rectangle([ex, ey - int(s * 0.8), ex + sw, ey + int(s * 0.8)], 
        fill=(255, 255, 255, 230))
    draw.rectangle([ex, ey - int(s * 0.8), ex + int(s * 0.7), ey - int(s * 0.8) + sw], 
        fill=(255, 255, 255, 230))
    draw.rectangle([ex, ey - sw // 2, ex + int(s * 0.5), ey + sw // 2], 
        fill=(255, 255, 255, 230))
    draw.rectangle([ex, ey + int(s * 0.8) - sw, ex + int(s * 0.7), ey + int(s * 0.8)], 
        fill=(255, 255, 255, 230))

    # "EmpowerWellness" text
    font_size = int(height * 0.22)
    font = get_font(font_size)
    text_x = icon_x + icon_r + int(width * 0.04)
    text_y = cy - int(font_size * 0.35)

    if font and font_size > 20:
        # "Empower" in white
        draw.text((text_x, text_y), "Empower", fill=(255, 255, 255, 240), font=font)
        tw = draw.textbbox((0, 0), "Empower", font=font)[2]
        # "Wellness" in gradient (shifted right)
        w_x = text_x + tw + int(width * 0.01)
        draw.text((w_x, text_y), "Wellness", fill=NEON_CYAN + (240,), font=font)

    # Tagline
    tag_font = get_font(int(font_size * 0.4))
    if tag_font:
        tag_y = text_y + font_size + int(height * 0.02)
        draw.text((text_x, tag_y), "Your world is evolving", 
            fill=(176, 165, 192, 180), font=tag_font)

    return img.convert("RGBA")


def resize_icon(src_path, sizes, output_dir):
    """Resize icon to multiple sizes."""
    img = Image.open(src_path)
    os.makedirs(output_dir, exist_ok=True)
    for name, size, dest_sub in sizes:
        resized = img.resize((size, size), Image.LANCZOS)
        dest_dir = os.path.join(output_dir, dest_sub)
        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, name)
        resized.save(dest_path, "PNG")
        print(f"  {name}: {size}x{size} -> {dest_sub}/")


def main():
    print("Creating EmpowerWellness branding assets...\n")

    # 1. High-res app icon (1024x1024)
    print("1. App icon (1024x1024)...")
    icon = create_app_icon(1024)
    icon_path = os.path.join(OUT_DIR, "app_icon_1024.png")
    icon.save(icon_path, "PNG")
    print(f"   Saved: {icon_path}")

    # 2. In-app logo (horizontal)
    print("\n2. In-app logo (1080x324)...")
    logo = create_in_app_logo(1080)
    logo_path = os.path.join(OUT_DIR, "logo_horizontal.png")
    logo.save(logo_path, "PNG")
    print(f"   Saved: {logo_path}")

    # 3. Square logo for splash screen
    print("\n3. Square logo (512x512 for splash)...")
    logo_square = create_app_icon(512)
    logo_sq_path = os.path.join(OUT_DIR, "logo_square.png")
    logo_square.save(logo_sq_path, "PNG")
    print(f"   Saved: {logo_sq_path}")

    # 4. Android mipmap sizes
    print("\n4. Android mipmap icons...")
    android_dir = "C:\\Users\\George\\Desktop\\EmpowerWellness\\android\\app\\src\\main\\res"
    mipmaps = [
        ("ic_launcher.png", 48, "mipmap-mdpi"),
        ("ic_launcher.png", 72, "mipmap-hdpi"),
        ("ic_launcher.png", 96, "mipmap-xhdpi"),
        ("ic_launcher.png", 144, "mipmap-xxhdpi"),
        ("ic_launcher.png", 192, "mipmap-xxxhdpi"),
    ]
    resize_icon(icon_path, mipmaps, android_dir)

    # 5. Adaptive icon
    print("\n5. Adaptive icon (for Android 8+)...")
    adapt_dir = os.path.join(android_dir, "mipmap-xxxhdpi")
    # Create foreground (the icon itself, no background)
    fg = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    # Draw the gradient circle on transparent
    cx_fg, cy_fg = 216, 216
    r_fg = 180
    for y in range(432):
        for x in range(432):
            dx, dy = x - cx_fg, y - cy_fg
            dist = math.sqrt(dx**2 + dy**2)
            if dist <= r_fg:
                t = dist / r_fg
                if t < 0.5:
                    t2 = t / 0.5
                    rr = int(PRIMARY_PURPLE[0] + (NEON_CYAN[0] - PRIMARY_PURPLE[0]) * t2)
                    gg = int(PRIMARY_PURPLE[1] + (NEON_CYAN[1] - PRIMARY_PURPLE[1]) * t2)
                    bb = int(PRIMARY_PURPLE[2] + (NEON_CYAN[2] - PRIMARY_PURPLE[2]) * t2)
                else:
                    t2 = (t - 0.5) / 0.5
                    rr = int(NEON_CYAN[0] + (HOT_CORAL[0] - NEON_CYAN[0]) * t2)
                    gg = int(NEON_CYAN[1] + (HOT_CORAL[1] - NEON_CYAN[1]) * t2)
                    bb = int(NEON_CYAN[2] + (HOT_CORAL[2] - NEON_CYAN[2]) * t2)
                fg.putpixel((x, y), (min(255, rr), min(255, gg), min(255, bb), 200))
    fg_path = os.path.join(adapt_dir, "ic_launcher_foreground.png")
    fg.save(fg_path, "PNG")
    print(f"  Foreground: {fg_path}")

    # Create background (deep space)
    bg_img = Image.new("RGB", (432, 432), DEEP_SPACE)
    bg_path = os.path.join(adapt_dir, "ic_launcher_background.png")
    bg_img.save(bg_path, "PNG")
    print(f"  Background: {bg_path}")

    # 6. Adaptive icon XML
    print("\n6. Adaptive icon XML...")
    xml_dir = os.path.join(android_dir, "mipmap-anydpi-v26")
    os.makedirs(xml_dir, exist_ok=True)
    xml_content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>'''
    xml_path = os.path.join(xml_dir, "ic_launcher.xml")
    with open(xml_path, "w") as f:
        f.write(xml_content)
    print(f"  XML: {xml_path}")

    # 7. iOS icon (for web favicon too)
    print("\n7. Web favicon...")
    favicon = icon.resize((256, 256), Image.LANCZOS)
    favicon.save("C:\\Users\\George\\Desktop\\EmpowerWellness\\web\\favicon.png", "PNG")
    print(f"  Saved: web/favicon.png")

    # 8. Windows icon (just the 256 PNG for now)
    print("\n8. Windows app icon...")
    win_icon = icon.resize((256, 256), Image.LANCZOS)
    win_icon.save("C:\\Users\\George\\Desktop\\EmpowerWellness\\windows\\runner\\resources\\app_icon.ico", "PNG")
    print(f"  Saved: windows/runner/resources/app_icon.ico")

    print("\n✓ All branding assets generated!")
    print(f"\nAssets location: {OUT_DIR}")
    print("Android mipmaps updated in: res/")


if __name__ == "__main__":
    main()
