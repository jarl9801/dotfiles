---
name: mac-mini-gateway
description: Mac mini "Mac" as Hermes gateway — SSH access, Tailscale IP, troubleshooting
category: devops
---

# Mac Mini Gateway Access — Hermes

## Context

Mac mini "Mac" at Jarl's home office (Celle). Used as gateway for Hermes agent and Tailscale exit node.

## Connection Details

| Property | Value |
|---|---|
| Local hostname | `Mac` (Bonjour/mDNS) |
| Tailscale IP | `100.64.65.5` |
| SSH command | `ssh mini` (local) or `ssh 100.64.65.5` (remote/Tailscale) |
| Tailscale MagicDNS | `mini.tailnetname` (check actual suffix in Tailscale admin) |

## Access Patterns

**From within the same network (local):**
```bash
ssh mini
```

**From outside via Tailscale (remote):**
```bash
ssh 100.64.65.5
```
Tailscale must be installed and logged in on the remote machine.

## What runs on the Mac mini

- Hermes agent (`claude --acp --stdio`) for Telegram gateway
- Manim venv: `/tmp/manim_venv`
- LaTeX: NOT installed (requires sudo)
- Tailscale: exits via this machine

## Troubleshooting

**"Could not resolve hostname mini":**
→ Mac mini is not on the same local network, or hostname not broadcast
→ Try Tailscale IP: `ssh 100.64.65.5`

**Connection timed out on 100.64.65.5:**
→ Mac mini is off or Tailscale disconnected
→ Cannot restart Hermes remotely — user must physically power on the Mac
→ Check Tailscale admin console for device status

**Restart Hermes via SSH (when reachable):**
```bash
ssh mini "pkill -f hermes; nohup hermes --daemon &"  # or appropriate restart cmd
```

## Useful Commands on Mac Mini

```bash
# Check Hermes/gateway status
ps aux | grep -E 'hermes|claude'

# Restart Hermes service
launchctl kickstart -k gui/$(id -u)/homebrew.mxcl.hermes

# Check if Tailscale is up
tailscale status

# Manim animation rendering
source /tmp/manim_venv/bin/activate && manim ...
```