# Flake structure

## Objective

This is an example of how I structure my configurations,
not necessarily the perfect match for every setup.

## Features

This flake example shows how to group several common tools:

* Ability to have custom packages in the system
* Ability to present this packages as an overlay
* Ability to handle one or multiple `nixos` configurations
* Ability to handle one or multiple `nix-darwin` configurations
* Ability to handle one or multiple `home-manager` configurations

## Usage

1) Enter the devShell environment (using `direnv` or `nix develop`).
2) Update the `inputs` using `flake-mgr update`
3) Generate the system configuration using `flake-mgr switch`
  * This will define in the flake registy two local variations
    `nixpkgs` to pin it for the system and `nixcfg` to this current
    flake.
  * Will apply `nixos-rebuild switch` using current flake (a flag
    might be required to select the correct configuration).
4) Generate the home configuration using `flake-mgr home-switch`

## Limitations

Currently, all the features were not used / tested (most notable
`nix-darwin`). Flake-mgr doesn't include yet a darwin-switch action.

Secrets handling is still a WIP, I target the integration of
`sops-nix` but other solutions might also apply.

Even though the current flake has an overlay, it is not propagated to
the `nixpkgs` entry in the registry, you will have to combine
explicitely the different overlays from other flakes/shells.

## Directory layout

* `darwin/configurations`: Configurations for `nix-darwin`
* `darwin/modules`: Modules for `nix-darwin`
* `home/configurations`: Configurations for the users
  using `home-manager`
* `home/modules`: Modules for `home-manager`
* `lib`: Nix libraries to help handling the flake
* `nixos/configurations`: Configurations for `nixos`
* `nixos/modules`: Modules for `nixos`
* `pkgs`: Local packages
* `secrets`:  Not yey implemented, but should contain
  keys, credentials and tokens protected by `sops-nix`
  or `git-crypt` 
