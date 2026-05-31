#!/usr/bin/env bash
#
# HUMAN+ — serve the design site privately over your Tailscale network.
#
# Run this ON THE MAC MINI (or any machine on your tailnet). It serves the
# interactive site (designs/index.html) and exposes it over Tailscale with
# private tailnet HTTP and HTTPS routes, reachable only by devices logged into your tailnet.
#
#   ./serve.sh           # serve + Tailscale Serve (private tailnet URLs)
#   ./serve.sh --local   # serve on http://localhost:PORT only (no Tailscale)
#   PORT=9000 ./serve.sh # pick a different port
#
set -euo pipefail

PORT="${PORT:-8088}"
DIR="$(cd "$(dirname "$0")" && pwd)"   # the designs/ folder
LOCAL_ONLY=0
[[ "${1:-}" == "--local" ]] && LOCAL_ONLY=1

echo "HUMAN+  •  serving $DIR  on port $PORT"

# ---- pick a static file server (python3 ships on macOS) ----
if command -v python3 >/dev/null 2>&1; then
  ( cd "$DIR" && python3 -m http.server "$PORT" --bind 127.0.0.1 ) &
  SERVER_PID=$!
elif command -v npx >/dev/null 2>&1; then
  ( cd "$DIR" && npx --yes serve -l "$PORT" . ) &
  SERVER_PID=$!
else
  echo "Need python3 or npx to serve files. Install one and retry." >&2
  exit 1
fi

cleanup(){ echo; echo "Stopping…"; kill "$SERVER_PID" 2>/dev/null || true;
           if [[ $LOCAL_ONLY -eq 0 ]]; then
             tailscale serve --http="$PORT" off 2>/dev/null || true
             tailscale serve --https=443 off 2>/dev/null || true
           fi; }
trap cleanup EXIT INT TERM

sleep 1
echo "Local:  http://localhost:$PORT/"

if [[ $LOCAL_ONLY -eq 1 ]]; then
  echo "Local-only mode. Ctrl-C to stop."
  wait "$SERVER_PID"
fi

# ---- expose over Tailscale ----
if ! command -v tailscale >/dev/null 2>&1; then
  echo
  echo "⚠  'tailscale' CLI not found. Install the Tailscale app, then re-run."
  echo "   Meanwhile the site is live locally at http://localhost:$PORT/"
  wait "$SERVER_PID"
fi

echo "Bringing up Tailscale Serve (private tailnet routes)…"
# HTTP on $PORT works without HTTPS certificate provisioning; HTTPS uses port 443 when certs are healthy.
tailscale serve --bg --http="$PORT" "http://127.0.0.1:$PORT" >/dev/null 2>&1 || true
tailscale serve --bg --https=443 "http://127.0.0.1:$PORT" >/dev/null 2>&1 || {
  echo "Could not start Tailscale Serve automatically."
  echo "Try manually:  tailscale serve --bg --http=$PORT http://127.0.0.1:$PORT"
}

echo
echo "────────────────────────────────────────────────────────"
tailscale serve status 2>/dev/null || true
DNS_NAME="$(tailscale status --json 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); n=d.get("Self",{}).get("DNSName","").rstrip("."); print(n)' 2>/dev/null || true)"
if [[ -n "${DNS_NAME:-}" ]]; then
  echo "Open on any device on your tailnet:  http://$DNS_NAME:$PORT/"
  echo "HTTPS, once certs are healthy:        https://$DNS_NAME/"
fi
echo "────────────────────────────────────────────────────────"
echo "Serving. Ctrl-C to stop and tear down the Tailscale route."
wait "$SERVER_PID"
