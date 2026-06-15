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
- runs **`tailscale serve`** to expose it privately to your tailnet,
- prints the URLs to open.

Open the private HTTP URL on your **phone and desktop** (both must be on the
tailnet): `http://mac-mini.<your-tailnet>.ts.net:8088/`. The HTTPS URL
`https://mac-mini.<your-tailnet>.ts.net/` also works once Tailscale HTTPS
certificate provisioning is healthy. Use `Ctrl-C` to stop; it tears down the
Tailscale routes automatically.

### Options
```bash
./serve.sh --local      # localhost only, skip Tailscale
PORT=9000 ./serve.sh    # use a different port
```

## Always-on (recommended) — runs at login, restarts on crash

`serve.sh` only runs while its terminal is open. For a permanent service that
starts automatically and restarts itself, use the installer instead:

```bash
cd ~/peptide-store/designs
chmod +x install_service.sh
./install_service.sh
```

This installs a macOS **LaunchAgent** (`com.humanplus.site`) that:
- serves `designs/` on port 8088 at every login,
- restarts automatically if it ever crashes (`KeepAlive`),
- re-asserts the private Tailscale HTTP route and the HTTPS route.

You can now close the terminal — the site stays up at
`http://<mac-mini>.<tailnet>.ts.net:8088/`.

**Manage it:**
```bash
./install_service.sh --uninstall   # remove the service + clear the route
tail -f ~/Library/Logs/humanplus/err.log   # view logs
```

> Note: a LaunchAgent runs when you're **logged in**. It survives reboots as long
> as the Mac logs back into your user account. If the Mac mini boots to the login
> screen and waits there, enable automatic login (System Settings → Users & Groups →
> Automatically log in as…) so the service comes up unattended. For a true
> system-wide daemon that runs before login, tell me and I'll switch it to a
> `LaunchDaemon`.

## Troubleshooting
- **`tailscale: command not found`** → add the CLI:
  `sudo ln -s /Applications/Tailscale.app/Contents/MacOS/Tailscale /usr/local/bin/tailscale`
- **URL loads on the Mac but not the phone** → confirm the phone is signed into the
  same tailnet and Tailscale is toggled on.
- **HTTPS fails but HTTP works** → Tailscale HTTPS certificate provisioning is the
  issue. Keep using the private HTTP URL, then check MagicDNS and HTTPS
  Certificates in the Tailscale DNS admin page.
- **Want a shareable link for someone NOT on your tailnet** → that's `tailscale funnel`
  (public). Ask me and I'll switch the script — but it makes the site public.
