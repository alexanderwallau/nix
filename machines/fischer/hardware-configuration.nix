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
      };
      efi.canTouchEfiVariables = true;
    };
    # encrypt the root partition
    initrd.luks.devices = {
      root = {
        # Get UUID from blkid /dev/sda2
        device = "/dev/disk/by-uuid/2c490a0b-cb57-4c5a-8f29-02e41a7fcdd2";
        preLVM = true;
        allowDiscards = true;
      };
    };

    kernelParams = [
    "debugfs=off"
    "lockdown=confidentiality"
    "module.sig_enforce=1"
    "oops=panic"
    "quiet" "loglevel=0"
    "slab_nomerge"
    "vsyscall=none"
  ];

    # A sort of actual effort towards security
    blacklistedKernelModules = [
    # Obscure networking protocols
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "n-hdlc"
    "x25"
    "decnet"
    "econet"
    "af_802154"
    "ipx"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "can"
    "atm"
    # Various rare filesystems
    "jffs2"
    "hfsplus"
    "squashfs"
    "udf"
    "cifs"
    "nfs"
    "nfsv3"
    "gfs2"
    "vivid"
    ];

  };


  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/1f2d45d2-23ff-43e0-8895-80ecb4e9c51a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/8FB4-1604";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2a5df563-096e-450f-95a3-f0acfed15bc5"; }];


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

  # security.lockKernelModules = false;
  security.allowSimultaneousMultithreading = true;
  security.virtualisation.flushL1DataCache = "cond";
  # security.forcePageTableIsolation = false;


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
