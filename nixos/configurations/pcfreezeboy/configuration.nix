{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pcfreezeboy";

  users.extraUsers = {
    freezeboy = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      uid = 1000;
    };    
  };
}
