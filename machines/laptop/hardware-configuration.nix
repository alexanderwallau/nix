# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    # use latest kernel for compatibility
    # kernelPackages = pkgs.linuxPackages_latest;

    # I want to find out, which Kernel breaks the system
    # please rebuild & reboot with different Kernels one by one
    # until you find the one that breaks the system
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_6_0;
    # kernelPackages = pkgs.linuxPackages_5_19;
    # kernelPackages = pkgs.linuxPackages_5_18;
    # kernelPackages = pkgs.linuxPackages_5_17;
    # kernelPackages = pkgs.linuxPackages_5_16;
    # kernelPackages = pkgs.linuxPackages_5_15;


    # load kernel modules
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" ];
    initrd.kernelModules = [ "dm-snapshot" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    loader = {
      # install GRUB
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };
    # encrypt the root partition
    initrd.luks.devices = {
      root = {
        # Get UUID from blkid /dev/nvme0n1p6
        device = "/dev/disk/by-uuid/76db6644-dc9b-4d2a-8424-46a343078284";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/67c8ff2a-1bc2-44f9-9c89-b426f74be4f1";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/35E8-E6E6";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/20172ba9-67cb-4d35-97bb-466611233f1a"; }];

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
