const { mdToPdf } = require('md-to-pdf');
const fs = require('fs');
const path = require('path');

const manifest = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'pdf-manifest-ru.json'), 'utf-8')
);

// CLI: `--only <id>` builds a single document (e.g. standard) for fast iteration.
const argv = process.argv.slice(2);
const onlyIdx = argv.indexOf('--only');
const onlyId = onlyIdx !== -1 ? argv[onlyIdx + 1] : null;

function resolveBrowserExecutable() {
  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    return process.env.PUPPETEER_EXECUTABLE_PATH;
  }
  const candidates = [
    'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
    'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
  ];
  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  return undefined;
}

// Strip a single leading YAML frontmatter block (--- ... ---) so it does not
// render as visible body text. md-to-pdf only parses frontmatter on the FIRST
// document of a concatenated stream; every subsequent file leaked its YAML into
// the PDF as plain text (~7 lines × 36 files). We concatenate body-only here.
function stripFrontmatter(md) {
  if (!md.startsWith('---')) return md;
  const m = md.match(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/);
  return m ? md.slice(m[0].length) : md;
}

// Tightened typography: 10.5pt / 1.45 line-height / 1.6–1.8cm margins, smaller
// heading gaps and denser tables. Cuts ~15–20% of page count vs. the previous
// 11pt / 1.6 / 2cm settings, with no content change.
const CSS = `
  body { font-family: 'Inter', 'Segoe UI', system-ui, sans-serif; font-size: 10.5pt; line-height: 1.45; color: #1a1a1a; }
  h1 { font-size: 22pt; font-weight: 800; color: #1E3A5F; border-bottom: 3px solid #D4A843; padding-bottom: 6px; margin-top: 24px; page-break-before: always; }
  h1:first-child { page-break-before: avoid; }
  h2 { font-size: 15pt; font-weight: 700; color: #1E3A5F; border-bottom: 1px solid #E3EFF8; padding-bottom: 3px; margin-top: 20px; }
  h3 { font-size: 12.5pt; font-weight: 600; color: #2A4A73; margin-top: 14px; }
  p { margin: 6px 0; }
  ul, ol { margin: 6px 0; }
  table { width: 100%; border-collapse: collapse; margin: 10px 0; font-size: 9.5pt; }
  th { background: #F2F7FC; padding: 4px 8px; text-align: left; font-weight: 600; border-bottom: 2px solid #B8D4EA; }
  td { padding: 3px 8px; border-bottom: 1px solid #E3EFF8; }
  code { background: #F2F7FC; padding: 1px 4px; border-radius: 3px; font-size: 9pt; font-family: 'JetBrains Mono', monospace; }
  pre { background: #0F1B2D; color: #E3EFF8; padding: 10px; border-radius: 6px; font-size: 8.5pt; line-height: 1.35; }
  pre code { background: none; color: inherit; padding: 0; }
  blockquote { border-left: 4px solid #D4A843; padding-left: 12px; margin: 12px 0; font-style: italic; color: #2A4A73; }
  hr { border: none; border-top: 1px solid #E3EFF8; margin: 8px 0; }
  strong { font-weight: 700; }
  a { color: #3B6491; text-decoration: none; }
  .cover { text-align: center; padding-top: 200px; page-break-after: always; }
  .cover h1 { font-size: 46pt; border: none; color: #1E3A5F; page-break-before: avoid; margin-bottom: 10px; }
  .cover .sub { font-size: 15pt; color: #5A8AB5; margin-bottom: 40px; }
  .cover .meta { font-size: 11pt; color: #8BB3D4; }
  @page { margin: 1.6cm 1.8cm; }
`;

function buildDocMarkdown(root, doc) {
  const missing = [];
  let md = `<div class="cover">

# RENAR

<div class="sub">${doc.subtitle || doc.title}</div>

<div class="meta">

${doc.title} · Версия ${manifest.version} | ${manifest.date}

Авторы: ${manifest.authors}

CC BY-SA 4.0 | renar.tech

</div>
</div>

`;

  for (const file of doc.files) {
    const fp = path.join(root, file);
    if (fs.existsSync(fp)) {
      md += stripFrontmatter(fs.readFileSync(fp, 'utf-8')) + '\n\n---\n\n';
    } else {
      missing.push(file);
      console.warn('MISSING:', file);
    }
  }
  return { md, missing };
}

async function main() {
  const root = path.resolve(__dirname, '..');
  const browserPath = resolveBrowserExecutable();
  if (!browserPath) {
    console.error(
      'No Chrome/Edge found. Set PUPPETEER_EXECUTABLE_PATH or run: npx puppeteer browsers install chrome'
    );
    process.exit(1);
  }

  const docs = manifest.documents.filter((d) => !onlyId || d.id === onlyId);
  if (onlyId && docs.length === 0) {
    console.error(`No document with id "${onlyId}". Known: ${manifest.documents.map((d) => d.id).join(', ')}`);
    process.exit(1);
  }

  const allMissing = [];
  for (const doc of docs) {
    const { md, missing } = buildDocMarkdown(root, doc);
    allMissing.push(...missing);
    if (missing.length) {
      console.error(`Abort "${doc.id}": ${missing.length} manifest file(s) missing`);
      continue;
    }

    const pdf = await mdToPdf(
      { content: md },
      {
        css: CSS,
        pdf_options: {
          format: 'A4',
          printBackground: true,
          // Footer with page numbers. Puppeteer needs displayHeaderFooter + a
          // non-empty bottom margin to reserve space; an explicit font-size is
          // mandatory (the default is 0, which silently hides the footer). The
          // header is intentionally blank to suppress Puppeteer's default date.
          displayHeaderFooter: true,
          headerTemplate: '<div></div>',
          footerTemplate:
            '<div style="width:100%; margin:0 1.8cm; font-size:8pt; color:#8BB3D4; font-family:\'Inter\',\'Segoe UI\',sans-serif; text-align:center;">' +
            '<span class="pageNumber"></span> / <span class="totalPages"></span></div>',
          margin: { top: '1.6cm', bottom: '1.8cm', left: '1.8cm', right: '1.8cm' },
        },
        launch_options: {
          headless: true,
          args: ['--no-sandbox'],
          executablePath: browserPath,
        },
      }
    );

    if (!pdf) {
      console.error(`PDF generation returned empty result for "${doc.id}"`);
      process.exit(1);
    }

    for (const outRel of doc.outputs) {
      const out = path.join(root, outRel);
      fs.mkdirSync(path.dirname(out), { recursive: true });
      fs.writeFileSync(out, pdf.content);
      console.log(`PDF [${doc.id}]: ${outRel} (${Math.round(pdf.content.length / 1024)} KB)`);
    }
  }

  if (allMissing.length) {
    console.error(`\n${allMissing.length} missing manifest file(s) total`);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
