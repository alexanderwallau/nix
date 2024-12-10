  { config, lib, pkgs, modulesPath, flake-self, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    flake-self.inputs.disko.nixosModules.disko
  ];
  # Lets try Disko with nix-anywhere for the fiirst time
disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "0";
            end = "1M";
            flags = [ "bios_grub" ];
          }
          {
            name = "ESP";
            start = "1M";
            end = "512M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nixos";
            start = "512M";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
      };
        
      };
    };
  };
    boot = {
      loader = {
        timeout = 10;
        grub ={
          enable = true;
          device = "/dev/sda";
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
      };
      growPartition = true;
      kernelParams = [ "console=ttyS0" ];
      initrd.availableKernelModules =
        [ "ata_piix" "virtio_pci" "xhci_pci" "sd_mod" "sr_mod" ];
      initrd.kernelModules = [ ];
      kernelModules = [ ];
      extraModulePackages = [ ];
    };

    # swapfile
    swapDevices = [{
      device = "/var/swapfile";
      size = (1024 * 8);
    }];

    # Running fstrim weekly is a good idea for VMs.
    # Empty blocks are returned to the host, which can then be used for other VMs.
    # It also reduces the size of the qcow2 image, which is good for backups.
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };
    #fileSystems."/".label = "nixos";
    services.qemuGuest.enable = true;

  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}