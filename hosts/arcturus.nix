{profiles, ...}: {
  imports = with profiles; [
    server
    boot.zfs

    hardware.common-pc
    hardware.common-cpu-amd
  ];

  lhf.boot.zfs.device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNS0WB10632A";

  user.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE98aQ0VshDOnylLmZcfEdbuxZllCDtfBYH2786f4nph luis@altair"
  ];

  boot.blacklistedKernelModules = ["kvm_amd"];

  networking.hostId = "73c61367";

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
