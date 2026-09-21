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

## One file server, three workplaces

`server` is the always-on central node and holds the data. `desktop`, `x1` and
`l14` are interchangeable workplaces — I use whichever one I am sitting at and
see the same files everywhere.

- **Tailscale** is the network. All hosts join the same tailnet, so the laptops
  reach `server` from any location without port forwarding or a public IP.
- **Syncthing** does the actual replication, peering with `server` over the
  tailnet. `tailscale0` is the only trusted interface in the firewall and
  Syncthing's ports are not opened otherwise, so sync happens over the tailnet
  or not at all — identical behaviour at home and on the road.
- The workplaces keep a **full local copy**, so everything still works offline;
  `server` is the node that is always reachable and therefore the one that
  ultimately holds the current state.

The modules only enable the services. Joining the tailnet (`tailscale up`) and
pairing devices/folders in Syncthing is per-machine state outside this repo —
`~/.config/syncthing` must not be copied between hosts.

## Layout

```
flake.nix          inputs (nixpkgs 26.05, home-manager) + mkHost helper
hosts/<name>/      per-host: imports, hostname, bootloader, stateVersion
  hardware-configuration.nix
modules/           shared system modules, toggled per host by importing them
users/sebi.nix     system-level account (groups, shell)
home/sebi.nix      home-manager profile: GUI apps, dotfiles, R/Python env
home/server.nix    home-manager profile for headless hosts (no GUI)
dotfiles/          plain config files (i3, alacritty, vim, rstudio) read by home/
```

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

# Update all inputs
nix flake update
```
