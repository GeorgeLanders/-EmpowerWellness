import os
import subprocess

video_dir = r"C:\Users\George\Desktop\EmpowerWellness\build\app\outputs\video"
out_dir = r"C:\Users\George\Desktop\EmpowerWellness\assets\videos\thumbnails"
os.makedirs(out_dir, exist_ok=True)

for f in os.listdir(video_dir):
    if f.endswith('.mp4'):
        video_path = os.path.join(video_dir, f)
        img_name = f.replace('.mp4', '.jpg')
        img_path = os.path.join(out_dir, img_name)
        
        # Extract frame at 1.0s (or 0.5s if shorter)
        cmd = [
            'ffmpeg', '-y',
            '-ss', '00:00:01.000',
            '-i', video_path,
            '-vframes', '1',
            '-q:v', '2',
            img_path
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(img_path):
            print(f"Extracted frame for {f} -> {img_name}")
        else:
            # Try at 0.0s if 1.0s fails (e.g. short video)
            cmd[2] = '00:00:00.100'
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode == 0 and os.path.exists(img_path):
                print(f"Extracted frame at 0.1s for {f} -> {img_name}")
            else:
                print(f"Failed for {f}: {res.stderr[:100]}")
