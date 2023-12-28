{ lib
, python3
, fetchPypi
}:

let
  pick = python3.pkgs.buildPythonApplication rec {
    pname = "pick";
    version = "1.6.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Kv1GyJtQIxHTuDHs7hoA6Kv4kq1elubLr5PxcrKa4cU=";
    };

    nativeBuildInputs = with python3.pkgs; [
      poetry-core
    ];
  };

in

python3.pkgs.buildPythonApplication rec {
  pname = "qobuz-dl";
  version = "0.9.9.10";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-q7TUl3scg+isoLB0xJvJLCtvJU7O+ogMlftt0O73qb4=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    colorama
    mutagen
    pathvalidate
    pick
    requests
    tqdm
  ];

  pythonImportsCheck = [ "qobuz_dl" ];

  meta = with lib; {
    description = "The complete Lossless and Hi-Res music downloader for Qobuz";
    homepage = "https://pypi.org/project/qobuz-dl/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
