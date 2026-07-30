#!/usr/bin/env bash
# Post-render: copy branding assets and CNAME into the output directory.
# Quarto's resources directive can't reach files above the project root,
# so we handle these manually here. Idempotent.
set -euo pipefail

WEBSITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$WEBSITE_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/docs"

# Copy brand assets so <img src="branding/..."> in index.html resolves.
# Sync the full branding tree (svgs, team photos, etc.) into the output.
mkdir -p "$OUT_DIR/branding"
rsync -a --delete --exclude '.DS_Store' "$REPO_ROOT/branding/" "$OUT_DIR/branding/"

# Ensure CNAME (akriti.io) is preserved at the docs/ root for GitHub Pages.
cp -f "$WEBSITE_DIR/_static/CNAME" "$OUT_DIR/CNAME"

# Drop provisional pages from the sitemap. They carry <meta robots="noindex">,
# and listing a page we are asking crawlers to ignore is a contradiction.
# Reachable by direct URL; simply not advertised. Remove a page from this list
# once it is announced.
NOINDEX_PAGES=( "sangam" )
for page in "${NOINDEX_PAGES[@]}"; do
  if grep -q "/$page/" "$OUT_DIR/sitemap.xml" 2>/dev/null; then
    perl -0pi -e "s{\s*<url>\s*<loc>[^<]*/$page/[^<]*</loc>.*?</url>}{}gs" "$OUT_DIR/sitemap.xml"
    echo "post-render: removed /$page/ from sitemap.xml (noindex)"
  fi
done

echo "post-render: copied branding/ and CNAME into $OUT_DIR"
