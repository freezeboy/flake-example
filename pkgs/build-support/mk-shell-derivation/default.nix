{ shellcheck, makeWrapper, stdenvNoCC, lib }:

# Helper for shell packages
args@{ pname, ... }: stdenvNoCC.mkDerivation ({
  checkInputs = [ shellcheck ];
  doCheck = true;
  checkPhase = ''
    find -name "*.sh" -or -name ${pname} -exec shellcheck '{}' \;
  '';
  installPhase = ''
    mkdir -p $out/bin
    if [ -d lib ]; then
      mkdir -p $out/lib
      cp lib/*.sh $out/lib
    fi
    cp bin/${pname} $out/bin
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath (args.buildInputs or [])}
  '';
} // (args // { buildInputs = [ makeWrapper ] ++ (args.buildInputs or []); }))
