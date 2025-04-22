# Temp configuration for bootstrapping.

{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;
in
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    (import "${home-manager}/nixos")
  ];

  system.stateVersion = "24.11";
  nix.settings.experimental-features = "nix-command flakes";

  wsl = {
    enable = true;
    defaultUser = "denis";
    startMenuLaunchers = true;
    interop.includePath = false;
    wslConf = {
      network.generateResolvConf = true;
    };
  };

  fileSystems."/mnt/c".label = "c";
  fileSystems."/home/denis/git" = {
    depends = [
      "/mnt/c"
    ];
    device = "/mnt/c/Users/Denis/git";
    fsType = "none";
    options = [ "bind" ];
  };

  # Temp until I properly configure git ssh keys.
  fileSystems."/home/denis/.ssh" = {
    depends = [
      "/mnt/c"
    ];
    device = "/mnt/c/Users/Denis/.ssh";
    fsType = "none";
    options = [ "bind" "ro" ];
  };

  # fileSystems."/home/denis/.gpg" = {

  # };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Noto" "FiraCode" "CommitMono" ]; })
      noto-fonts-emoji
      fira-code-symbols
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "NotoSerif Nerd Font" ];
        sansSerif = [ "NotoSans Nerd Font" ];
        monospace = [ "CommitMono Nerd Font" ];
      };
    };
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.systemPackages = with pkgs; [
    pkgs.direnv
    pkgs.docker
    pkgs.git
    pkgs.home-manager
    pkgs.starship
    pkgs.zsh
  ];

  services.lorri.enable = true;

  users.users.denis = {
    shell = pkgs.zsh;
    isNormalUser = true;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  programs.zsh.enable = true;
}
