# modules/audio.nix
# Audio stack: PipeWire as sound server, with PulseAudio and ALSA compatibility.
{ ... }:
{
  # Grants PipeWire realtime scheduling priority so audio does not stutter under CPU load.
  security.rtkit.enable = true;

  services.pipewire = {
    # Starts the PipeWire daemon and WirePlumber as systemd user services.
    enable = true;

    # PulseAudio protocol emulation, needed by browsers, Discord, most desktop apps.
    pulse.enable = true;

    # Routes programs that open ALSA directly through PipeWire instead of grabbing the card.
    alsa.enable = true;
  };
}
