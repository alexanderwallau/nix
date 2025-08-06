{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,  
  extraBuildEnv ? null,
}:
let
  dotnet = dotnetCorePackages.dotnet_8;
in 
buildDotnetModule (finalAttrs: {
  pname = "mampf-link"
  version = "1.0.0";


  src =
    fetchFromGitHub {
      owner = "alexanderwallau";
      repo = "mampf.link";
      hash = "sha256-1g6kqj869hwqm92rk38fqg79g2lfdj4pc21nqh8gddy4n3kc9b6l";
    };

  projectFile = [
    "GroupOrder/GroupOrder.csproj"
  ];

  buildInputs = [ dotnet-sdk ];
  dotnet-runtime = dotnet.runtime;
  executables = ["GroupOrder"]

meta = {
    description = " Webtool to more easily organize Group orders ";
    longDescription = ''
        We order food quite a lot in groups. There was a lot of complaining from the people needing to coordinate the ordering process, that this is quite a tedious job. 
        This tool is here to replace the countless manual tables and chat groups that people use to coordinate the order taking and finances.
    '';
    homepage = "https://github.com/alexanderwallau/mampf.link";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [
      alexanderwallau
    ];
    platforms = lib.platforms.linux;
    mainProgram = "GroupOrder";
  };
})

