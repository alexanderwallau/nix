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
      seaborn
      cufflinks
      black
      numpy
      pandas
      plotly
      plotnine
      scikit-learn
      requests
      scipy
      #tensorflow-build
      #tensorboard
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

     
