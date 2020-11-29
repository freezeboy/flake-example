{ self, nixpkgs, utils }:

let
  darwinModules = import ../darwin/modules;

in
{
  inherit darwinModules;

  loadConfigurations = {
        system ? builtins.currentSystem
      , pkgs ? nixpkgs.legacyPackages.${system}
      }:
    {
      inherit darwinModules;

      darwinConfigurations = utils.loadConfigurations "${self}/darwin"
        ({name, fullName }: {
          configuration = "${fullName}/configuration.nix";
          username = name;
          inherit system pkgs;
        });
    };
}