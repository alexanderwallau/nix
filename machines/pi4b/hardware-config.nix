# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, nixos-hardware, argononed,... }: {

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    "${argononed}/OS/nixos/default.nix"
    nixos-hardware.nixosModules.raspberry-pi-4
  ];

  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
    deviceTree = {
      enable = true;
    };
  };
  console.enable = true;


  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4096;
    }
  ];

  services.argonone = {
    enable = true;
    logLevel = 4;
    settings = {
      fanTemp0 = 41; fanSpeed0 = 20;
      fanTemp1 = 46; fanSpeed1 = 50;
      fanTemp2 = 51; fanSpeed2 = 80;
      hysteresis = 4;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
