{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.awallau.programs.python;

  my-python-packages = python-packages:
    with python-packages; [
      ipykernel
      jupyter
      ipython
      matplotlib
      numpy
      requests
      scipy
      #tensorflow-build
      #tensorboard
      jinja2

    ];

  python-with-packages = pkgs.python312.withPackages my-python-packages;

in
{

  options.awallau.programs.python.enable = mkEnableOption "install python3 with libs";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ python-with-packages ];
  };

}

     