# syntax=docker/dockerfile:1.7
# RENAR site image — hybrid build:
#   stage 1 (node)  : Astro landing + principles → /astro
#   stage 2 (python): MkDocs Material docs       → /docs-build
#   stage 3 (nginx) : merge into single static tree, serve

# ─── stage 1: Astro landing ────────────────────────────────────────────────
FROM node:22.14.0-alpine AS astro-build

ENV NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FETCH_RETRIES=5 \
    NPM_CONFIG_FETCH_RETRY_MINTIMEOUT=20000 \
    NPM_CONFIG_FETCH_RETRY_MAXTIMEOUT=120000

WORKDIR /repo/site
COPY site/package.json site/package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline --no-progress

WORKDIR /repo
COPY site/ site/

WORKDIR /repo/site
RUN npm run build

# ─── stage 2: MkDocs docs ──────────────────────────────────────────────────
FROM python:3.12-alpine AS mkdocs-build

# Pure-Python stack (no PDF deps). When planning task `pdf-generate-ru-en`
# activates, add: gcc g++ musl-dev libffi-dev cairo pango gdk-pixbuf, and
# uncomment mkdocs-with-pdf in site-docs/requirements.txt.

WORKDIR /repo
COPY site-docs/requirements.txt site-docs/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r site-docs/requirements.txt

# Repo content needed by mkdocs.yml + section mkdocs.yml subprojects + hooks.
COPY mkdocs.yml ./
COPY site-docs/ site-docs/
COPY standard/ standard/
COPY guide/ guide/
COPY reference/ reference/
COPY core/ core/

RUN mkdocs build

# ─── stage 3: nginx serve ──────────────────────────────────────────────────
FROM nginx:alpine

# Astro tree owns / (landing + /ru/* routes).
COPY --from=astro-build /repo/site/dist /usr/share/nginx/html

# MkDocs tree mounts under /docs/.
COPY --from=mkdocs-build /repo/site-docs/build /usr/share/nginx/html/docs

COPY site/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
