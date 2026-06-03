import os
for root, dirs, files in os.walk('.'):
    # Exclude build, .dart_tool, .git, node_modules
    if any(x in root for x in ['build', '.dart_tool', '.git', 'node_modules']):
        continue
    for f in files:
        if f.endswith(('.dart', '.py', '.ts', '.tsx', '.js', '.json')):
            p = os.path.join(root, f)
            try:
                with open(p, 'r', encoding='utf-8') as file:
                    content = file.read()
                    for term in ['exercise.mp4', 'exercise1.mp4', 'exercise2.mp4', 'exercise3.mp4', 'Will push.mp4', 'side steps.mp4', 'cat-cowSTRETCH']:
                        if term in content:
                            print(f'Found "{term}" in {p}')
            except Exception as e:
                pass
