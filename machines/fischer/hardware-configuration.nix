# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, nixos-hardware, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      # import hardware specific configuration
      nixos-hardware.nixosModules.lenovo-thinkpad-x220
    ];

  boot = {
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
    initrd.kernelModules = [ "dm-snapshot" ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      # install GRUB
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        default = "0";
        theme = pkgs.sleek-grub-theme;
      };
      efi.canTouchEfiVariables = true;
    };
    # encrypt the root partition
    initrd.luks.devices = {
      root = {
        # Get UUID from blkid /dev/nvme0n1p6
        device = "/dev/disk/by-uuid/f84bd902-d03c-49ef-a82f-b12564d4f7d1";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };


  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3c8da8cb-162e-4c78-8afc-ea0bdc45dbb6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/1294-DAA3";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/8fad684d-f9cd-4ea0-b955-96594c25708d"; }];


  services.xserver = {
    xkb.layout = "us";
  };

  # Set your time zone.
  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
  # Fingerprint service options
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
