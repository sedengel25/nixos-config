# nixos-config

Flake-based NixOS configuration for all of my machines, with home-manager for
the user-level setup. One repo, one `nixpkgs` pin, four hosts.

## Hosts

| Flake attribute | Hostname | Was es ist | home-manager profile |
| --- | --- | --- | --- |
| `x1` | `nixos-x1` | ThinkPad X1, i3 desktop, dual boot with Windows | `home/sebi.nix` |
| `l14` | `nixos-l14` | ThinkPad L14, i3 desktop, dual boot with Windows | `home/sebi.nix` |
| `desktop` | `nixos-desktop` | Desktop with NVIDIA GPU (RTX 4070 SUPER) + Steam | `home/sebi.nix` |
| `server` | `server` | Headless, SSH key only, Tailscale + Syncthing | `home/server.nix` |

## Layout

```
flake.nix          inputs (nixpkgs 26.05, home-manager) + mkHost helper
hosts/<name>/      per-host: imports, hostname, bootloader, stateVersion
  hardware-configuration.nix   generated ON that machine, not portable
modules/           shared system modules, toggled per host by importing them
users/sebi.nix     system-level account (groups, shell)
home/sebi.nix      home-manager profile: GUI apps, dotfiles, R/Python env
home/server.nix    home-manager profile for headless hosts (no GUI)
dotfiles/          plain config files (i3, alacritty, vim, rstudio) read by home/
```

A host is nothing more than a list of module imports plus its own identity. Want
Bluetooth on the server? Add `../../modules/bluetooth.nix` to its `imports`.

### modules/

| Module | Purpose |
| --- | --- |
| `common.nix` | baseline every host imports: flakes, unfree, NetworkManager, locale/timezone, base packages |
| `desktop.nix` | X11 + i3, lightdm, gnome-keyring and the tools around them |
| `audio.nix` | PipeWire (PulseAudio + ALSA compat) |
| `bluetooth.nix` | BlueZ + blueman tray applet |
| `nvidia.nix` | proprietary NVIDIA driver — **only** for hosts that have such a card |
| `gaming.nix` | Steam + gamemode (needs a GPU module with 32-bit GL) |
| `eduvpn.nix` | eduVPN client + the NetworkManager OpenVPN plugin |
| `tailscale.nix` | Tailscale, `tailscale0` trusted in the firewall |
| `syncthing.nix` | Syncthing as user `sebi` |

## Usage

```sh
# Rebuild the current machine (flake attribute = hostname, sonst mit #<name>)
sudo nixos-rebuild switch --flake .#x1

# Try a build without activating it
nixos-rebuild build --flake .#desktop

# Update all inputs, then rebuild
nix flake update
sudo nixos-rebuild switch --flake .#x1
```

## Adding a new host

1. `mkdir hosts/<name>` and copy an existing `default.nix` as a starting point.
2. Run `nixos-generate-config --show-hardware-config > hosts/<name>/hardware-configuration.nix`
   **on that machine** — the file is machine-specific (UUIDs, kernel modules).
3. Set `networking.hostName` and `system.stateVersion`, and pick the modules to import.
4. Register it in `flake.nix`: `<name> = mkHost { host = "<name>"; };`
   (headless hosts also pass `home = ./home/server.nix`).

## Notes

- `system.stateVersion` is set per host and must **not** be changed after the
  initial installation.
- Secrets are not in this repo. eduVPN state under `~/.config/eduvpn` is
  per-machine and must not be copied between hosts; the server's SSH access is
  public-key only.
- R packages for both RStudio and terminal R are declared in one list in
  `home/sebi.nix` — add packages there and rebuild, never via `install.packages()`.
- Laptops with a shared 260 MB Windows ESP limit the number of boot entries
  (`boot.loader.systemd-boot.configurationLimit`); see the comment in
  `hosts/l14/default.nix`.
