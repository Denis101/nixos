#!/bin/sh
# requires sudo, run `sudo su` before executing this script

build () {
  if [ -f /etc/nixos/configuration.nix ]; then
    mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup
  fi

  cp ./configuration.nix /etc/nixos/configuration.nix
  nixos-rebuild switch
}

build
