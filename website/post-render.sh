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

# Sangam 2027 is a hand-written standalone page, not a Quarto document — it has
# its own theme and shares nothing with the rest of the site. Quarto has no say
# over it; we simply copy it into place after each render.
rsync -a --delete --exclude '.DS_Store' --exclude 'README.md' \
  "$WEBSITE_DIR/_static/sangam/" "$OUT_DIR/sangam/"

# Cache-bust the stylesheet. Pages serves it with max-age=600, so a browser can
# hold a ten-minute-old style.css against freshly deployed HTML. On a hero with
# light type over a dark photograph that means invisible text, which is exactly
# what happened on 2026-08-07. A content hash in the href rules it out.
SANGAM_CSS="$OUT_DIR/sangam/assets/style.css"
if [ -f "$SANGAM_CSS" ]; then
  if command -v md5 >/dev/null 2>&1; then
    CSS_HASH=$(md5 -q "$SANGAM_CSS" | cut -c1-8)
  else
    CSS_HASH=$(md5sum "$SANGAM_CSS" | cut -c1-8)
  fi
  perl -pi -e "s{assets/style\.css(\?v=[0-9a-f]+)?}{assets/style.css?v=$CSS_HASH}g" \
    "$OUT_DIR/sangam/index.html"
  echo "post-render: stamped sangam stylesheet as ?v=$CSS_HASH"
fi
echo "post-render: copied _static/sangam/ into $OUT_DIR/sangam"

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
