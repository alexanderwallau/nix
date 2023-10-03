{ lib, pkgs, config, alexanderwallau-keys, ... }:
with lib;
let cfg = config.awallau.user.root;
in
{

  options.awallau.user.root = {
    enable = mkEnableOption "activate user root";
    mayniklas = mkEnableOption "give MayNiklas temporary root access";
  };

  config = mkIf cfg.enable {

    users.users.root = {
      openssh.authorizedKeys = {
        keyFiles = [ alexanderwallau-keys ];
        keys = [ ] ++
          lib.optional cfg.mayniklas "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTN6R5IKYsOd4AlT0Ly+GPBwpfUBosuPZzgRMtOVGNR2ONcVGQHIx50N+FttsROjRIj3WqnnKoPGcy4wrRskpiK9G0tbU73qDRoWCnghcGQDfLO4BA+lW+U5HZ/EbHcCx9FSO6xkWWToWnXV37A5L3xdxGxBrsGqYFQUcmoxfGamaFQlaqnqHrtK209OTeyBIEdSr5NrI2BzQEvSIk4hFdS4AiCLUD/EnCj35Frle14cOzIU2dh3sLpULzfdTD/U43Kyt0NPGFqNX0KS/NjlT75eM6QpkgnKpb0W3QPaioIil0Vkwym2CJBCIJ65kZbhd2NiK7vCVQPEHdeIoCw2S/N1ggPpdUBOutoefWnx4RZ1Y+jYIQu+3sXETqZJ0G5b5nU2FDs5G+izlMxlRbhoUJlnf1ZMa4U6SQIgVnO/l7HOhcMjeNlbEGH+VXJacccDFQ6AjIj3V8rAMh4YecLpEhiP2XdD0dla1UPlU1HpifRoxTJ506+eIfPIkmlnMuyyIQRVwliX+QnACqb9B//xgi9vFQHEYIyKrwud7W/+5MckQNRx1IGEJHjVs7xZE+3j3kF0o+MjGcjJWnV+R8KxPj5qb4twr3z3SDrIZ766DwzLSQ1YVskU9l7Ko9SfELvZKUVmW7nHZxZ61MJYOU3Nrol0MMRe2xr6Asn2/5vpJ4nQ== cardno:17_113_145";
      };
    };
    nix.settings.allowed-users = [ "root" ];
  };

}
