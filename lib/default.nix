{ self, nixpkgs }:

let
  utils = import ./utils.nix { inherit self nixpkgs; };

  combinedPackages = nixpkgs // {
    legacyPackages = utils.forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlay ];
      });
  };
in
{
  inherit utils;
  
  nixos = import ./nixos.nix {
    inherit self utils;
    nixpkgs = combinedPackages;
  };

  homeManager = import ./home-manager.nix {
    inherit self utils;
    nixpkgs = combinedPackages;
  };

  darwin = import ./darwin.nix {
    inherit self utils;
    nixpkgs = combinedPackages;
  };
}
