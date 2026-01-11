{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  php,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mensa-jetzt";
  version = "1.0.0";

  src =
    fetchFromGitHub {
      owner = "strifel";
      repo = "Mensa.Jetzt";
      hash = "sha256-DqfUUXY79CndEqPT8TR4PasLtaSCtqZaV2kp10Vu4PQ=";
    }

  buildInputs = [ php ];

  # There's nothing to build.
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -vr * $out/

  '';

 meta = {
    description = "Website for coordinating canteen visits";
    homepage = "https://github.com/strifel/Mensa.Jetz";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      alexanderwallau
    ];
    platforms = lib.platforms.all;
  };
}