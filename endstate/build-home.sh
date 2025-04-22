#!/bin/sh

BASE_DIR=$HOME/.config/home-manager

build () {
  if [ -f "$BASE_DIR/home.nix" ]; then
    mv $BASE_DIR/home.nix $BASE_DIR/home.nix.backup
  fi

  cp -rf ./config/. $BASE_DIR/
  cp ./home.nix $BASE_DIR/home.nix
  home-manager switch
}

build
