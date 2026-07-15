# Audio via PipeWire (ersetzt PulseAudio, pactl funktioniert weiterhin).
{ ... }:

{
  # rtkit lets PipeWire acquire realtime priority (recommended).
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
