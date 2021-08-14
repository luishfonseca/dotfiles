# hosts/default.nix
#
# Author: Luís Fonseca <luis@lhf.pt>
# URL:    https://github.com/luishfonseca/dotfiles
# 
# Common configuration for all hosts.

{ pkgs, ... }:

{
  # Enable flakes.
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Set the time zone.
  time.timeZone = "Europe/Lisbon";

  
}
