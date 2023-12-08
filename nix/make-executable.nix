{
  pkgs,
  stdenv,
  deno2nix,
  ...
}: {
  pname,
  version,
  src,
  lockfile,
  output ? pname,
  entrypoint,
  importMap ? null,
  additionalDenoFlags ? "",
  additionalBuildSteps ? "",
  preCompileSteps ? "",
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit pname version src;
    dontFixup = true;

    buildInputs = with pkgs; [deno jq];
    buildPhase = ''
      export DENO_DIR="/tmp/deno2nix"
      rm -rf $DENO_DIR
      mkdir -p $DENO_DIR
      echo Linking dependencies
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      ${preCompileSteps}

      echo Compiling
      deno compile \
        --lock="${lockfile}" \
        --output="${output}" \
        ${
        if importMap != null
        then "--import-map=\"$src/${importMap}\""
        else ""
      } \
        ${additionalDenoFlags} \
        "$src/${entrypoint}"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp "${output}" "$out/bin/"
      ${additionalBuildSteps}
    '';
  }
