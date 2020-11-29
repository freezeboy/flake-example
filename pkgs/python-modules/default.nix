{ pkgs, pythonPackages }:

let
  inherit (self) callPackage;

  self = pythonPackages // (with self; {
    #local-pkg = callPackage ./local-pkg { };
  });
in
self
