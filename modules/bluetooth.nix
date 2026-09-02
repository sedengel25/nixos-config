# modules/bluetooth.nix
# Bluetooth + a tray applet for managing devices.
{ ... }:
{
  # Installs BlueZ and enables bluetooth.service, which owns the adapter
  # and handles scanning, pairing and connecting.
  hardware.bluetooth.enable = true;

  # GTK front end for BlueZ: tray icon and pairing dialogs instead of bluetoothctl.
  services.blueman.enable = true;
}
