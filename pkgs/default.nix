{ pkgs, unstable, home-manager }:

let
  callPackage = pkgs.newScope self;
  self = (with pkgs; {
    unstable = {
      # Keep unstable packages in a specific attribute to
      # let configurations and modules choose between stable
      # and unstable versions
      inherit (unstable) vivaldi vscodium tdesktop;
      # Home-manager from upstream flake to get up-te-date modules
      inherit home-manager;
    };

    # Script used to ease flake updates
    flake-mgr = callPackage ./tools/flake-mgr {};

    # Allow customization of the available kernel modules
    #linuxPackages = with (pkgs.linuxPackages); {
    #  akvcam = callPackage ./os-specific/linux/akvcam.nix { };
    #};
    
    # Shell helpers
    mkShellDerivation = callPackage ./build-support/mk-shell-derivation {};
    mkUserShell = callPackage ./build-support/mk-user-shell {};
    mkHoistedShell = callPackage ./build-support/mk-hoisted-shell {};

    python3 = pkgs.python3.override {
      packageOverrides = pself: pythonPackages:
        import ./python-modules { inherit pkgs pythonPackages; };
    };
  });
in
self
