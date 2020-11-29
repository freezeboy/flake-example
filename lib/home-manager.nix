{ self, nixpkgs, utils }:

let
  homeModules = import ../home/modules;

  configuration = {
      configuration
    , username
    , homeDirectory ? "/home/${username}"
    , pkgs ? nixpkgs.legacyPackages.${system}
    , system ? builtins.currentSystem
    , check ? true }:
  import "${self.legacyPackages.${system}.unstable.home-manager}/modules" {
    inherit check pkgs;
    configuration = { ... }: {
      imports = [ configuration homeModules ];
      _module.args.pkgs = pkgs;
      home = { inherit homeDirectory username; };
    };
  };
in

{
  inherit homeModules;

  loadConfigurations = {
        system ? builtins.currentSystem
      , pkgs ? nixpkgs.legacyPackages.${system}
      }:
    {
      inherit homeModules;

      homeConfigurations = utils.loadConfigurations "${self}/home"
        ({name, fullName }: configuration {
          configuration = "${fullName}/home.nix";
          username = name;
          inherit system pkgs;
        });
    };
}
