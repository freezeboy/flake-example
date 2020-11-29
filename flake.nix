{
  description = "My custom flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable }:
    let
      lib = import ./lib { inherit nixpkgs self; };
    in
    {
      inherit lib;
      legacyPackages = lib.utils.forAllSystems (system: 
        let
          rawPkgs = import ./pkgs {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
            inherit home-manager;
          };
        in
          # Not working atm
          #lib.utils.removeIncompatible system rawPkgs;
          rawPkgs
      );

      homeConfigurations = lib.utils.forAllSystems (system: (lib.homeManager.loadConfigurations { inherit system; }).homeConfigurations);
      homeModules = lib.utils.forAllSystems (system: (lib.homeManager.loadConfigurations { inherit system; }).homeModules);

      inherit (lib.utils) overlay;
      inherit (lib.nixos.loadConfigurations home-manager.nixosModules)
        nixosModules nixosConfigurations;
      inherit (lib.darwin.loadConfigurations)
        darwinModules darwinConfigurations;

      devShell = lib.utils.forAllSystems (system:
        nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = 
            (with self.legacyPackages.${system}; [
              flake-mgr
            ]);
        });
    };
}
