const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const exercises = [
  'seated-leg-lifts',
  'torso-twists',
  'seated-marching',
  'neck-release',
  'arm-circles',
  'heel-touches',
  'wall-stand',
  'cat-cow',
  'wrist-stretch',
  'butterfly-stretch',
  'gentle-hamstring',
  'wall-pushups',
  'chair-squats',
  'calf-raises',
  'indoor-walk',
  'nature-walk',
];

const outDir = path.join(__dirname, 'out');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

console.log('Rendering ' + exercises.length + ' exercise videos...');
console.log('');

let success = 0;
let failed = 0;

for (const id of exercises) {
  const outFile = path.join(outDir, id + '.mp4');
  const title = id.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());

  if (fs.existsSync(outFile) && fs.statSync(outFile).size > 100000) {
    console.log('[' + (success+failed+1) + '/' + exercises.length + '] SKIP (exists): ' + title);
    success++;
    continue;
  }

  console.log('[' + (success+failed+1) + '/' + exercises.length + '] Rendering: ' + title);
  const start = Date.now();

  try {
    execSync(
      'npx remotion render src/index.ts ' + id + ' "' + outFile + '" --log=warn',
      { timeout: 600000, cwd: __dirname, stdio: 'inherit' }
    );

    const stats = fs.statSync(outFile);
    const elapsed = ((Date.now() - start) / 1000).toFixed(1);
    console.log('  OK - ' + elapsed + 's, ' + (stats.size / 1024 / 1024).toFixed(1) + 'MB');
    success++;
  } catch (err) {
    console.log('  FAIL');
    failed++;
  }
}

console.log('');
console.log('Done: ' + success + ' rendered, ' + failed + ' failed');
const files = fs.readdirSync(outDir).filter(f => f.endsWith('.mp4'));
console.log(files.length + ' video files in ' + outDir);
