{
  inputs,
  lib,
  config,
  ...
}: {
  config = {
    settings.experimental-features = "nix-command flakes";
    networking.hostName = "nixos";
    system.stateVersion = "24.11";
  };
}
