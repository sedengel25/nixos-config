# Steam, Lutris + Gaming-Helfer. Braucht die 32-Bit-GL-Libs aus einem GPU-Modul
# (hier modules/nvidia.nix mit hardware.graphics.enable32Bit).
{ pkgs, ... }:

let
  # Der MyWhoosh-Installer (github.com/Dj0ulo/mywhoosh-linux) ruft blank
  # `python3` auf -- einmal fuer den MS-Store-Downloader (nur stdlib), und fuer
  # den Bluetooth-Helfer daneben, der `dbus` und `gi` importiert.
  blePython = pkgs.python3.withPackages (ps: with ps; [ dbus-python pygobject3 ]);
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # Steam Remote Play
    dedicatedServer.openFirewall = true;  # Source-Dedicated-Server
  };

  # `gamemoded` optimiert z.B. CPU-Governor, solange ein Spiel läuft.
  # In Steam als Launch-Option nutzbar: `gamemoderun %command%`.
  programs.gamemode.enable = true;

  environment.systemPackages = [
    # Lutris läuft in einer FHS-Sandbox. Alles, was ein Lutris-Installer
    # aufruft, muss DORT im PATH liegen -- ein Eintrag in systemPackages
    # hilft dafür nicht. Darum extraPkgs.
    (pkgs.lutris.override {
      # ... und selbst das reicht fuer `python3` nicht: Lutris ist eine
      # Python-App, und ihr eigener Wrapper haengt den nackten Interpreter
      # (ohne dbus/gi) vorne in den PATH -- vor /usr/bin der Sandbox. Das
      # zuletzt angegebene --prefix landet ganz vorne, also gewinnt hier
      # blePython. Sonst meldet der BLE-Helfer "MISSING python modules" und
      # das Spiel zeigt Bluetooth stumm als aus an.
      lutris-unwrapped = pkgs.lutris-unwrapped.overrideAttrs (old: {
        makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
          "--prefix PATH : ${blePython}/bin"
        ];
      });

      extraPkgs = p: [
        # Damit auch /usr/bin/python3 in der Sandbox der richtige ist.
        blePython

        # `umu-run`: Lutris nimmt es als Proton-Runner, sobald es im PATH ist.
        # Hier die *unwrapped* Variante -- pkgs.umu-launcher ist selbst eine
        # FHS-Sandbox (steam.buildRuntimeEnv), und bwrap in bwrap scheitert:
        # `umu-run createprefix` stirbt sofort, der Wine-Prefix entsteht nie,
        # und das Spiel beendet sich nach zwei Sekunden.
        p.umu-launcher-unwrapped

        # notify-send -- damit meldet der BLE-Helfer Probleme auf den Desktop.
        p.libnotify
      ];
    })


    # umu auch ausserhalb von Lutris, direkt auf der Kommandozeile -- dort ist
    # der FHS-Wrapper genau richtig.
    pkgs.umu-launcher
  ];
}
