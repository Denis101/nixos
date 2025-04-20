# WSL Platform for NixOS

## Installation

1. Follow the instructions from the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) repository.
2. Switch to your new NixOS installation:
```
wsl -d NixOS
```
3. Ensure you're running the latest NixOS and NixOS-WSL versions:
```
sudo nix-channel --update
sudo nixos-rebuild switch
```
4. Rebuild with this flake:
```
nixos-rebuild switch --flake github:Denis101/nixos
```
