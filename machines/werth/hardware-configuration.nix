  { config, lib, pkgs, modulesPath, self, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  
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

    # This server is not for heavy computation and because space is limited use Ram-Sized SwapFile
    swapDevices = [{
      device = "/var/swapfile";
      size = (1024 * 2);
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