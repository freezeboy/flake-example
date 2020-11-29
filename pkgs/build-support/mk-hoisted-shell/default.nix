{ mkUserShell, callPackage }:

a@{
  home,
  name ? baseNameOf home,
  buildInputs ? [],
  hoistedInputs ? [],
  shellHook ? "",
  ... }:

let
  hoist = callPackage ./hoist.nix {};
  newInputs = buildInputs ++ map (pkg: hoist {inherit home pkg;}) hoistedInputs;
in
  mkUserShell ((removeAttrs a ["home" "name" "buildInputs" "hoistedInputs" "shellHook"]) // {
    inherit name;
    buildInputs = newInputs;
    LOCAL_HOME = home;
    shellHook = ''
      hash -d ${name}=${home}
      unset hoistedInputs
    '' + shellHook;
  })
