{ lib, mkShellDerivation, jq, bash, nixUnstable, makeWrapper }:

let
  path = lib.makeBinPath [ jq nixUnstable ];
in
mkShellDerivation rec {
  pname = "flake-mgr";
  version = "0.1";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    install -D flake-mgr.sh $out/bin/flake-mgr
    wrapProgram $out/bin/flake-mgr \
      --prefix PATH : ${path}

    runHook postInstall
  '';
}
