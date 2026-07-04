# RENAR Docs — Distribution Artifacts

Distribution-ready artifacts for the RENAR standard (mirrors `senar/docs/` layout).

## Artifacts

| Artifact | Source | Status |
|---|---|---|
| `RENAR-v1.0-draft-ru-standard.pdf` | `core/` + `standard/` (RU) — нормативное ядро | Generated via `npm run pdf:ru` |
| `RENAR-v1.0-draft-ru-guide.pdf` | `guide/` (RU) | Generated via `npm run pdf:ru` |
| `RENAR-v1.0-draft-ru-reference.pdf` | `reference/` минус авторские мета-доки 04/06/09 (RU) | Generated via `npm run pdf:ru` |
| `RENAR-v1.0-draft-ru.pdf` | полный архив: всё + мета-доки (RU) | Generated via `npm run pdf:ru` |
| `RENAR-v1.0-en.pdf` | EN corpus | Planned — after EN translation |
| Site (MkDocs) | `/docs/` on renar.tech | Docker hybrid build (MkDocs + Astro) |
| Site (landing) | `/` and `/ru/` | Astro in `site/` |

## Generate PDF (local)

```bash
npm install
npm run pdf:ru
```

Outputs (4 PDFs — split by audience + full archive): `*-standard.pdf`, `*-guide.pdf`, `*-reference.pdf`, and the combined `RENAR-v1.0-draft-ru.pdf`. Each is written to both `docs/` (committed distribution copy) and `site/public/` (served by Astro/nginx static). Build a single one with `node scripts/build-pdf-ru.cjs --only standard`.

Manifest (documents + chapter order): [`scripts/pdf-manifest-ru.json`](../scripts/pdf-manifest-ru.json)

## Build full site (local)

```bash
docker compose up --build
# Astro landing: http://localhost:4321
# Full hybrid image (nginx): port from docker-compose
```

MkDocs-only:

```bash
pip install -r site-docs/requirements.txt
mkdocs serve
```

## Reference

Format mirrors [SENAR docs/](https://github.com/kibertum/senar/tree/main/docs):

- PDFs split by audience (Standard / Guide / Reference) plus a full archive per language
- Linked from root `README.md` «PDF Downloads»
- Markdown source remains canonical in section folders
