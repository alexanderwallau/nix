{ self, ... }:
{ pkgs, lib, config, modulesPath, nixos-hardware,... }: {

  imports = [
    # being able to build the sd-image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # https://github.com/NixOS/nixos-hardware/tree/master/raspberry-pi/4
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

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # set up language and timezone
    locales.enable = true;
    # enable node exporter
    metrics = { node = { enable = true; flake = true; }; };
    # enable nginx
    nginx.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    # zsh as default shell for all users
    zsh.enable = true;
  };

  ### build sd-image
  # nix build .\#nixosConfigurations.pi4b.config.system.build.sdImage
  # add boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; to your x86 system
  # to build ARM stuff through qemu
  sdImage.compressImage = false;
  sdImage.imageBaseName = "raspi-image";
  nix.registry.nixpkgs.flake = pkgs;
  nix.nixPath = [ "nixpkgs=${pkgs}" ];
  # this workaround is currently needed to build the sd-image
  # basically: there currently is an issue that prevents the sd-image to be built successfully
  # remove this once the issue is fixed!
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];


  environment.systemPackages = with pkgs;
    [
      bash-completion
      wget
      git
      libraspberrypi
      raspberrypi-eeprom
    ];

    lollypops.deployment = {
      local-evaluation = true;
      ssh = { user = "root"; };
    };

    documentation = {
      enable = false;
      doc.enable = false;
      info.enable = false;
      man.enable = false;
    };
  networking = {
    nameservers = [ "192.168.69.1" "1.0.0.1" ];
    # Fallback ntp service, this one being T-Online
    timeServers = [ "194.25.134.196" ];
    hostName = "pi4b";
  };
   nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
