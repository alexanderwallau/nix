{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.awallau.programs.python;

  my-python-packages = python-packages:
    with python-packages; [
      ipykernel
      jupyter
      jupyter-client
      jupyterlab
      ipython
      matplotlib
      black
      numpy
      pandas
      ploars # pandas do be slow
      plotly
      plotnine
      requests
      scipy
      jinja2
      rpy2

    ];

  python-with-packages = pkgs.python311.withPackages my-python-packages;

in
{

  options.awallau.programs.python.enable = mkEnableOption "install python3 with libs";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ python-with-packages ];
  };

}