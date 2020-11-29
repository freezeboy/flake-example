{ self, nixpkgs, utils }:

let
  inherit (nixpkgs) lib;
  inherit (utils) filterDir mapDir;

  fromCommonConfiguration = nixosModules: extraModule: rec {
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    modules = (lib.mapAttrsToList (n: v: v) nixosModules)
    ++ [ {
      imports = [
        nixpkgs.nixosModules.notDetected
        extraModule
      ];

      system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      
      nix.registry = {
        nixpkgs.flake = nixpkgs;
        nixcfg.flake = self;
      };
    } ];
  };

  nixosModules =
    let mods = "${self}/nixos/modules"; in mapDir mods
     (name: value: if value == "regular" then import "${mods}/${name}.nix" else import "${mods}/${name}")
     (n: v: n != "default.nix");
in {
  inherit nixosModules;

  loadConfigurations = extraModules:
    {
      inherit nixosModules;
      nixosConfigurations = utils.loadConfigurations "${self}/nixos"
        ({fullName, ... }: lib.nixosSystem
          (fromCommonConfiguration (nixosModules // extraModules)
            (import "${fullName}/configuration.nix")));
    };
}
