{
  bun2nix,
  pkgs,
  ...
}:
bun2nix.mkDerivation rec {
  pname = "opencode";
  version = "v1.0.175";

  src = pkgs.fetchFromGitHub {
    owner = "sst";
    repo = pname;
    tag = version;
    hash = "";
  };

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  module = "index.ts";
  # postPatch = ''
  #   cp ${./opencode.lock.json} package-lock.json
  # '';
  #
  # npmDepsHash = "sha256-vb3uuKth1HvcQgjbrVEtPHX+WTuwImOqjaN8xOwOo1A=";
  # # npmBuildScript = "build";
  # dontNpmBuild = true;

  # installPhase = ''
  #   mkdir -p $out/bin $out/lib
  #   cp -rv build $out/lib
  #   cp -rv package.json $out/lib
  #
  #   cat > $out/bin/${pname} << EOF
  #   #!/bin/sh
  #   ${pkgs.lib.getExe pkgs.nodejs} $out/lib/build
  #   EOF
  #
  #   chmod +x $out/bin/${pname}
  # '';
  # meta.mainProgram = "${pname}";
}
