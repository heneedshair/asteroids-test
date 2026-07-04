// Regenerate raster favicon assets from the RENAR-branded source SVG.
//
// Source of truth: site/public/favicon.svg (navy #1E3A5F tile + gold #D4A843 "R").
// Outputs (site/public/):
//   - apple-touch-icon.png  180x180, opaque (navy-flattened)
//   - favicon.ico           multi-size 16/32/48 (PNG-embedded ICO container)
//   - og-image.png          1200x630 branded social card
//
// Dependency-free except `sharp` (resolved from site/node_modules). The ICO
// container is assembled by hand so we don't depend on ImageMagick/`convert`
// (which on Windows shadows the NTFS convert.exe).
//
// Run:  node scripts/build-favicon-assets.cjs

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const PUB = path.join(ROOT, 'site', 'public');
const sharp = require(path.join(ROOT, 'site', 'node_modules', 'sharp'));

const NAVY = '#1E3A5F';
const NAVY_DARK = '#15293F';
const GOLD = '#D4A843';
const FONT = "Inter, 'Segoe UI', system-ui, sans-serif";

// R-mark tile (mirrors favicon.svg) at an arbitrary pixel size.
const markSvg = (size) => Buffer.from(
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="${size}" height="${size}">
     <rect width="64" height="64" rx="12" fill="${NAVY}"/>
     <text x="32" y="48" text-anchor="middle" font-family="${FONT}" font-weight="800" font-size="44" fill="${GOLD}">R</text>
   </svg>`);

// 1200x630 social card: brand background, R-mark tile, wordmark + tagline.
const ogSvg = Buffer.from(
  `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
     <rect width="1200" height="630" fill="${NAVY}"/>
     <rect x="90" y="225" width="180" height="180" rx="34" fill="${NAVY_DARK}" stroke="${GOLD}" stroke-width="3"/>
     <text x="180" y="358" text-anchor="middle" font-family="${FONT}" font-weight="800" font-size="120" fill="${GOLD}">R</text>
     <text x="320" y="300" font-family="${FONT}" font-weight="800" font-size="92" fill="#FFFFFF">RENAR</text>
     <text x="324" y="358" font-family="${FONT}" font-weight="500" font-size="29" fill="#9FC2E0">Requirements Engineering &amp; Normative Adaptive Regulation</text>
     <text x="324" y="408" font-family="${FONT}" font-weight="600" font-size="26" fill="${GOLD}">renar.tech</text>
   </svg>`);

// Assemble a PNG-embedded .ico from an array of {size, buffer(PNG)}.
function buildIco(frames) {
  const count = frames.length;
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0);     // reserved
  header.writeUInt16LE(1, 2);     // type: icon
  header.writeUInt16LE(count, 4); // image count

  const dir = Buffer.alloc(16 * count);
  let offset = 6 + 16 * count;
  frames.forEach((f, i) => {
    const e = i * 16;
    dir.writeUInt8(f.size >= 256 ? 0 : f.size, e + 0); // width  (0 => 256)
    dir.writeUInt8(f.size >= 256 ? 0 : f.size, e + 1); // height (0 => 256)
    dir.writeUInt8(0, e + 2);                 // palette colors
    dir.writeUInt8(0, e + 3);                 // reserved
    dir.writeUInt16LE(1, e + 4);              // color planes
    dir.writeUInt16LE(32, e + 6);             // bits per pixel
    dir.writeUInt32LE(f.buffer.length, e + 8);// bytes in resource
    dir.writeUInt32LE(offset, e + 12);        // offset
    offset += f.buffer.length;
  });

  return Buffer.concat([header, dir, ...frames.map((f) => f.buffer)]);
}

async function flatStdevOk(file) {
  // Guard: a blank tile (font failed to render the "R") would be near-flat.
  const { channels } = await sharp(file).stats();
  const maxStd = Math.max(...channels.map((c) => c.stdev));
  return maxStd > 3;
}

async function main() {
  if (!fs.existsSync(path.join(PUB, 'favicon.svg'))) {
    throw new Error('source site/public/favicon.svg not found');
  }

  // apple-touch-icon: 180x180, opaque (iOS masks corners itself).
  const apple = path.join(PUB, 'apple-touch-icon.png');
  await sharp(markSvg(180)).flatten({ background: NAVY }).png().toFile(apple);

  // favicon.ico: 16/32/48 PNG frames.
  const frames = [];
  for (const size of [16, 32, 48]) {
    const buffer = await sharp(markSvg(size)).png().toBuffer();
    frames.push({ size, buffer });
  }
  fs.writeFileSync(path.join(PUB, 'favicon.ico'), buildIco(frames));

  // og-image: 1200x630 social card.
  const og = path.join(PUB, 'og-image.png');
  await sharp(ogSvg).png().toFile(og);

  // Render-sanity guard (catches missing-font blank output).
  for (const f of [apple, og]) {
    if (!(await flatStdevOk(f))) {
      throw new Error(`render looks flat (font/SVG issue?): ${f}`);
    }
  }

  console.log('regenerated: apple-touch-icon.png (180), favicon.ico (16/32/48), og-image.png (1200x630)');
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
