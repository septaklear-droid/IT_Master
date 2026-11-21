#!/usr/bin/env bash
# Assembles the static site from the saved page and its zipped assets.
#   - "Bosh sahifa - BDVDDV.html" becomes index.html
#   - HD.zip is extracted into the "Bosh sahifa - BDVDDV_files" folder the page links to
#   - Asset names saved without a usable extension ("*.js.Без названия", "css", "css(1)", ...)
#     are given proper extensions so they're served with the right MIME type
#     (browsers refuse module scripts and stylesheets served as application/octet-stream).
set -euo pipefail

OUT="${1:-dist}"
PAGE="Bosh sahifa - BDVDDV.html"
ASSETS="Bosh sahifa - BDVDDV_files"
SUFFIX=".Без названия"

rm -rf "$OUT"
mkdir -p "$OUT/$ASSETS"
unzip -q -o HD.zip -d "$OUT/$ASSETS"

cd "$OUT/$ASSETS"
for f in *"$SUFFIX"; do
  [ -e "$f" ] && mv -- "$f" "${f%"$SUFFIX"}"
done
for f in css 'css('*')'; do
  [ -e "$f" ] && mv -- "$f" "$f.css"
done
cd - >/dev/null

sed -e "s/${SUFFIX}\"/\"/g" \
    -e "s#${ASSETS}/css\(([0-9]*)\)\?\"#${ASSETS}/css\1.css\"#g" \
    "$PAGE" > "$OUT/index.html"
