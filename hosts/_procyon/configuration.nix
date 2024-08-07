# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  networking.useDHCP = false;
  networking.hostId = "6f1a976e";
  networking.nameservers = ["1.0.0.1" "1.1.1.1"];

  lhf.rnl.ssh = {
    enable = true;
    rnladmin = "luis.fonseca";
  };

  lhf.rnl.networking = {
    enable = true;
    enableManagementVlan = true;
    enableOnBoot = false;
    interface = "enp4s0";
    lastOctet = 196;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "colemak_dh";
    xkbOptions = "ralt:compose";
  };

  #lhf.programs.neovim.enable = true;
  lhf.programs.htop.enable = true;
  lhf.programs.tmux.enable = true;
  lhf.programs.git.enable = true;
  lhf.programs.bspwm.enable = true;
  lhf.programs.kitty.enable = true;
  lhf.programs.rofi.enable = true;

  lhf.services.picom.enable = true;

  virtualisation.libvirtd.enable = true;
  lhf.programs.virtManager = {
    enable = true;
    autoconnectAll = true;
    connections = [
      "qemu:///system"
      "qemu+ssh://root@dredd/system"
      "qemu+ssh://root@zion/system"
      "qemu+ssh://root@atlas/system"
      "qemu+ssh://root@chapek/system"
      "qemu+ssh://root@hive/system"
    ];
  };

  lhf.shell.fish = {
    enable = true;
    starship.enable = true;
    anyNixShell.enable = true;
    direnv.enable = true;
  };
  lhf.shell.dash.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.luis.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9M6O9ZBXm95eIkqdDk6RWEmHwA0oZXN4TEtfY2dtIR"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgnSKa8CXwWeqAxnkWBASF2tTJ33VylGWI68DAftIsQ"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFlJJH6flIuAxeF68lXgfaXRJkcsGD0IChY5P/0Wajr"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZF9DXj0XZ7be9Rc0yC3WKhr30Xbn1kqjbzWBLcC6K"
  ];

  boot.supportedFilesystems = ["zfs"];
  boot.kernelParams = let
    cidr2mask = cidr: let
      pow = n: p:
        if p == 0
        then 1
        else n * pow n (p - 1);
      oct = n: builtins.bitXor 255 ((pow 2 (8 - n)) - 1);
      mask = n: o:
        if n > 8
        then "255." + mask (n - 8) (o + 1)
        else
          toString (oct n)
          + (
            if o < 3
            then "." + mask 0 (o + 1)
            else ""
          );
    in
      mask cidr 0;
  in [
    "ip=193.136.164.196::193.136.164.222:${cidr2mask 27}:procyon:enp4s0:off"
  ];

  boot.initrd = {
    supportedFilesystems = ["zfs"];
    kernelModules = ["r8169"];

    network = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9M6O9ZBXm95eIkqdDk6RWEmHwA0oZXN4TEtfY2dtIR"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgnSKa8CXwWeqAxnkWBASF2tTJ33VylGWI68DAftIsQ"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFlJJH6flIuAxeF68lXgfaXRJkcsGD0IChY5P/0Wajr"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYZF9DXj0XZ7be9Rc0yC3WKhr30Xbn1kqjbzWBLcC6K"
        ];
        port = 2222;
        hostKeys = [/etc/ssh/ssh_host_ed25519_key_initrd];
      };

      postCommands = ''
        cat <<EOF > /root/.profile
        if pgrep -x "zfs" > /dev/null
        then
          zfs load-key -a
          killall zfs
        else
          echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
        fi
        EOF
      '';
    };
  };

  lhf.programs.gpg.enable = true;
  lhf.programs.gpg.sshKeys = ["A8329FD9836E2DF1DB5820200DC3CFF29680124E"];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
