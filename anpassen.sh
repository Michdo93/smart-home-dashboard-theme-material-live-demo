#!/usr/bin/env bash
# Macht aus Smart-Home-Dashboard und smart-home-dashboard-theme-material
# die Online-Demo:
#   1. Ansicht "material" installieren
#   2. js-openhab-proxy-client statt js-openhab-rest-client
#   3. config.demo.js hinter config.js hängen
#
#   ./anpassen.sh <Dashboard> <Proxy-Client> <Theme-Repo>
#   (Theme-Repo: smart-home-dashboard-theme-material)
set -euo pipefail
SITE="$1"
CLIENT="$2"
THEME="$3"
HIER="$(cd "$(dirname "$0")" && pwd)"

# 1. Ansicht "material" als Unterordner installieren
# Die Startseite leitet dorthin.
"$THEME/install.sh" "$SITE"
cat > "$SITE/index.html" <<'HTML'
<!doctype html>
<meta charset="utf-8">
<title>Smart-Home-Dashboard · Live-Demo</title>
<meta http-equiv="refresh" content="0; url=material/">
<script>location.replace("material/" + location.search);  // ?room=… mitnehmen</script>
<a href="material/">Zur Demo</a>
HTML

# 2. Bibliothek tauschen – beide haben dieselbe Schnittstelle
cp "$CLIENT/openhab-proxy.min.js" "$SITE/lib/"
rm -f "$SITE/lib/openhab.min.js"
sed -i 's|\.\./lib/openhab.min.js|../lib/openhab-proxy.min.js|' \
  "$SITE/material/index.html"
# Abbruch, falls nicht ersetzt
grep -q 'lib/openhab-proxy.min.js' "$SITE/material/index.html"

# 3. Einstellungen der Demo anhängen
{ echo; cat "$HIER/config.demo.js"; } >> "$SITE/config.js"
if [ -n "${PROXY_URL:-}" ]; then                        # nur für lokale Tests
  sed -i "s|https://openhab-demo-proxy[^\"]*|$PROXY_URL|" "$SITE/config.js"
fi
rm -rf "$SITE/.git" "$SITE/.github"
echo "Online-Demo (material) vorbereitet in $SITE"
