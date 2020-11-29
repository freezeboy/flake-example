{ self, nixpkgs }:

let
  inherit (nixpkgs.lib) isDerivation isFunction length intersectLists
    attrByPath filterAttrsRecursive filterAttrs;

  filterDir = pred: path: filterAttrs pred (builtins.readDir path);
  
  mapDir = path: mapper: pred: builtins.mapAttrs mapper (filterDir pred path);

  systems = [
      "x86_64-linux"
      "i686-linux"
      #"x86_64-darwin"
      #"aarch64-linux"
      #"armv6l-linux"
      #"armv7l-linux"
    ];

in {
  inherit filterDir mapDir;

  loadConfigurations = confDir: action:
    let confs = "${confDir}/configurations"; in mapDir confs
    (name: value: action { fullName = "${confs}/${name}"; inherit name; })
    (n: v: v != "regular");

  removeIncompatible = system: let
    isCompatible = n: v:
      !builtins.isAttrs v ||
      !isDerivation v ||
      (length (intersectLists (attrByPath ["meta" "platforms"] [system] v) [system]) > 0);
    in filterAttrsRecursive isCompatible;

  overlay = final: prev: 
    let
      local = self.outputs.legacyPackages.${prev.system};

      # Merge overlay sub attributes
      overload = attrstr: let
        inherit (nixpkgs.lib) attrByPath splitString;
        attrs = splitString "." attrstr;
        getAttr = v: attrByPath attrs {} v;

      in (getAttr prev) // (getAttr local);
    in (local // {
      # Some aliases and nested packages must be overloaded
      lib              = overload "lib";
      linuxPackages    = overload "linuxPackages";
      kdeApplications  = overload "kdeApplications";
      python3Packages  = overload "python3.pkgs";
      python37Packages = overload "python37.pkgs";
      python38Packages = overload "python38.pkgs";
    });

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
}
