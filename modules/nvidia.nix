# Proprietäre NVIDIA-Treiber für die Desktop-GPU (RTX 4070 SUPER, Ada Lovelace).
# NUR von Hosts importieren, die wirklich eine NVIDIA-Karte haben (nicht x1).
{ config, ... }:

{
  # OpenGL/Vulkan-Userspace inkl. 32-Bit-Libs, die Steam/Proton brauchen.
  # (Heisst seit 24.11 `hardware.graphics`, früher `hardware.opengl`.)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Xorg den proprietären Treiber nutzen lassen (blacklistet zugleich nouveau).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Nötig für Wayland und verhindert Tearing / Black-Screens. Fast immer an.
    modesetting.enable = true;

    # Desktop am Netzteil: die Laufzeit-Stromsparfunktionen (für Laptops)
    # nicht nötig. Beide aus lassen, ausser es gibt Suspend/Resume-Probleme.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Open-Source-Kernelmodule. Von NVIDIA für Turing und neuer empfohlen
    # (RTX 4070 SUPER = Ada) und künftiger Standard.
    open = true;

    # Liefert das GUI-Tool `nvidia-settings`.
    nvidiaSettings = true;

    # Treiberversion passend zum aktuellen Kernel-Paket.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
