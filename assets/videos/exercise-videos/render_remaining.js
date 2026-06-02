const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const REMOTION_CLI = path.join(__dirname, 'node_modules', '@remotion', 'cli', 'dist', 'index.js');

const exercises = [
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

let done = 0;
let fail = 0;

function renderOne(id) {
  return new Promise((resolve) => {
    const outFile = path.join(outDir, id + '.mp4');
    const title = id.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());

    if (fs.existsSync(outFile) && fs.statSync(outFile).size > 50000) {
      console.log('[' + (++done) + '/' + exercises.length + '] EXISTS: ' + title);
      resolve();
      return;
    }

    console.log('[' + (done + fail + 1) + '/' + exercises.length + '] ' + title + '...');
    const t = Date.now();

    const proc = spawn(process.execPath, [REMOTION_CLI, 'render', 'src/index.ts', id, outFile, '--log=warn'], {
      cwd: __dirname,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let stderr = '';
    proc.stderr.on('data', (d) => { stderr += d; });
    proc.on('error', () => { console.log('  FAIL: spawn error'); fail++; resolve(); });
    proc.on('close', (code) => {
      if (code === 0) {
        const sz = fs.existsSync(outFile) ? fs.statSync(outFile).size : 0;
        console.log('  OK ' + ((Date.now() - t) / 1000).toFixed(0) + 's, ' + (sz / 1024 / 1024).toFixed(1) + 'MB');
        done++;
      } else {
        console.log('  FAIL (exit ' + code + '): ' + stderr.substring(0, 100));
        fail++;
      }
      resolve();
    });
  });
}

async function main() {
  for (const id of exercises) {
    await renderOne(id);
  }

  console.log('\nResults: ' + done + ' done, ' + fail + ' failed');
  const allFiles = fs.readdirSync(outDir).filter(f => f.endsWith('.mp4'));
  let total = 0;
  for (const f of allFiles) {
    total += fs.statSync(path.join(outDir, f)).size;
  }
  console.log(allFiles.length + ' videos, ' + (total / 1024 / 1024).toFixed(1) + 'MB total');
}

main();
