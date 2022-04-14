{ config, options, lib, pkgs, inputs, ... }:

{
  nixpkgs.pkgs = pkgs;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix = {
    nixPath = [
      "nixpkgs=${inputs.nixpkgs-unstable}"
    ];
    autoOptimiseStore = true;
    useSandbox = true;
    gc = {
      dates = "weekly";
      automatic = true;
      persistent = true;
    };
  };
  programs.command-not-found.enable = false;
}
