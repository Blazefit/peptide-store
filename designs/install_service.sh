#!/usr/bin/env bash
#
# HUMAN+ — install the site as an always-on macOS background service.
#
# Run this ONCE on the Mac mini:
#     cd ~/peptide-store/designs
#     chmod +x install_service.sh
#     ./install_service.sh
#
# It creates a LaunchAgent that serves designs/ on port 8088 at login,
# restarts itself if it ever crashes, and (re)asserts the Tailscale route.
# To remove it later:  ./install_service.sh --uninstall
#
set -euo pipefail

PORT="${PORT:-8088}"
DIR="$(cd "$(dirname "$0")" && pwd)"          # the designs/ folder
LABEL="com.humanplus.site"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOGDIR="$HOME/Library/Logs/humanplus"
PYBIN="$(command -v python3 || echo /usr/bin/python3)"

# ---- uninstall path ----
if [[ "${1:-}" == "--uninstall" ]]; then
  echo "Removing HUMAN+ service…"
  launchctl unload -w "$PLIST" 2>/dev/null || launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  rm -f "$PLIST"
  tailscale serve --http="$PORT" off 2>/dev/null || true
  tailscale serve --https=443 off 2>/dev/null || true
  echo "Done. Service removed and Tailscale route cleared."
  exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents" "$LOGDIR"

echo "HUMAN+  •  installing always-on service"
echo "  folder : $DIR"
echo "  python : $PYBIN"
echo "  port   : $PORT"

# ---- write the LaunchAgent plist ----
cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>            <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$PYBIN</string>
    <string>-m</string>
    <string>http.server</string>
    <string>$PORT</string>
    <string>--bind</string>
    <string>127.0.0.1</string>
  </array>
  <key>WorkingDirectory</key> <string>$DIR</string>
  <key>RunAtLoad</key>        <true/>
  <key>KeepAlive</key>        <true/>
  <key>StandardOutPath</key>  <string>$LOGDIR/out.log</string>
  <key>StandardErrorPath</key><string>$LOGDIR/err.log</string>
</dict>
</plist>
PLISTEOF

# ---- (re)load the service ----
launchctl unload -w "$PLIST" 2>/dev/null || true
launchctl load -w "$PLIST"

sleep 1.5

# ---- assert the Tailscale routes (persist across reboots on their own) ----
if command -v tailscale >/dev/null 2>&1; then
  # HTTP on $PORT is the private tailnet fallback when HTTPS cert provisioning is unavailable.
  tailscale serve --bg --http="$PORT" "http://127.0.0.1:$PORT" >/dev/null 2>&1 || true
  tailscale serve --bg --https=443 "http://127.0.0.1:$PORT" >/dev/null 2>&1 || true
else
  echo "⚠  tailscale CLI not found — site runs locally but no tailnet URL."
  echo "   Fix: sudo ln -s /Applications/Tailscale.app/Contents/MacOS/Tailscale /usr/local/bin/tailscale"
fi

# ---- report ----
echo
echo "────────────────────────────────────────────────────────"
LOCAL_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/index.html" || echo 000)"
echo "Local server (index.html):  HTTP $LOCAL_CODE  (200 = good)"
DNS_NAME="$(tailscale status --json 2>/dev/null | "$PYBIN" -c 'import sys,json;d=json.load(sys.stdin);n=d.get("Self",{}).get("DNSName","").rstrip(".");print(n)' 2>/dev/null || true)"
if [[ -n "${DNS_NAME:-}" ]]; then
  echo "Private tailnet HTTP URL:   http://$DNS_NAME:$PORT/"
  echo "Private tailnet HTTPS URL:  https://$DNS_NAME/  (requires Tailscale HTTPS certs)"
fi
echo "────────────────────────────────────────────────────────"
echo "The site now starts automatically and restarts if it crashes."
echo "Logs: $LOGDIR/   •   Uninstall: ./install_service.sh --uninstall"
