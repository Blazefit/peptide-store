# Hosting the HUMAN+ site privately (Tailscale)

The interactive site is a single static file (`index.html`) plus the `preview/`
images. Nothing to build — just serve the `designs/` folder. These steps put it on
a **private HTTPS URL reachable only by devices on your tailnet** (phone, desktop,
Mac mini, etc.). Nothing is published publicly.

## On the Mac mini (one-time)

1. **Install Tailscale** (if not already): https://tailscale.com/download/mac
   — sign in to the same tailnet as your phone/desktop.
2. **Get the code** (pick one):
   ```bash
   # if the repo isn't cloned yet:
   git clone <your-repo-url> peptide-store
   cd peptide-store
   git checkout claude/periodic-table-tshirt-designs-Wd9su
   git pull origin claude/periodic-table-tshirt-designs-Wd9su
   ```

## Run it

```bash
cd peptide-store/designs
chmod +x serve.sh      # first time only
./serve.sh
```

That's it. The script:
- serves `designs/` on `localhost` (default port 8088), and
- runs **`tailscale serve`** to expose it over HTTPS to your tailnet,
- prints the URL to open — looks like `https://mac-mini.<your-tailnet>.ts.net/`.

Open that URL on your **phone and desktop** (both must be on the tailnet). Use
`Ctrl-C` to stop; it tears down the Tailscale route automatically.

### Options
```bash
./serve.sh --local      # localhost only, skip Tailscale
PORT=9000 ./serve.sh    # use a different port
```

## Keep it running after you close the terminal (optional)

`tailscale serve --bg` keeps the proxy alive, but the file server stops when the
terminal closes. To keep the whole thing up persistently, run it under `caffeinate`
or as a LaunchAgent. Simplest "stays up while logged in":
```bash
cd peptide-store/designs
caffeinate -s ./serve.sh
```

For a true always-on service (survives logout/reboot), tell me and I'll add a
`launchd` plist — but for review/testing, the command above is enough.

## Troubleshooting
- **`tailscale: command not found`** → add the CLI:
  `sudo ln -s /Applications/Tailscale.app/Contents/MacOS/Tailscale /usr/local/bin/tailscale`
- **URL loads on the Mac but not the phone** → confirm the phone is signed into the
  same tailnet and Tailscale is toggled on.
- **HTTPS warning** → first hit can take a few seconds while Tailscale provisions the
  cert; refresh.
- **Want a shareable link for someone NOT on your tailnet** → that's `tailscale funnel`
  (public). Ask me and I'll switch the script — but it makes the site public.
