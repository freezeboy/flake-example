#! /usr/bin/env bash

QUIET=unset
SYSTEM=unset
FLAKE=.
HOSTNAME=
HM_USER=$USER

usage()
{
  echo "Usage: flake-mgr [ -q ] 
                 [ -s | --system   SYSTEM   ] 
                 [ -f | --flake    FLAKE    ] 
                 [ -h | --hostname HOSTNAME ] 
                 [ -u | --user     USERNAME ] action
                 [ -- ... ]"
  echo "system action is one of: build | boot | test | dry-activate | switch"
  echo "user action is one of: home-build | home-switch"
  echo "flake action is one of: update"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n flake-mgr \
    -o     qs:u:h:f: \
    --long quiet,system:,user:,hostname:,flake: \
    -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

#echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -q)              QUIET=1     ; shift   ;;
    -s | --system)   SYSTEM="$2" ; shift 2 ;;
    -u | --user)     HM_USER="$2"; shift 2 ;;
    -f | --flake)    FLAKE="$2"  ; shift 2 ;;
    -h | --hostname) HOSTNAME="$2"; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

exec_action() {
  if [[ $QUIET = 1 ]]; then
    "$@" 2>/dev/null 1>&2
  else
    "$@"
  fi
}

switch_if_needed() {
  profile="$1"
  shift
  if [[ -e result ]]; then
    old_gen=$(readlink -f /nix/var/nix/profiles/$profile)
    new_gen=$(readlink -f result)
    if [[ "$old_gen" != "$new_gen" ]]; then
      exec_action "$@"
    else
      echo "No changes required"
    fi
    rm result
  fi
}

if [[ "$SYSTEM" = unset ]]; then
  SYSTEM=$(nix eval --raw nixpkgs#pkgs.system)
fi

action="$1"
shift

NIX_BUILD="nix build --no-update-lock-file"
case "$action" in
  update)
    NIX_INPUTS=$(nix flake "$@" list-inputs --json | jq -r --tab '.nodes.root.inputs | keys | .[]')
    FLAKE_INPUTS=(nix flake update)
    for i in $NIX_INPUTS; do
      FLAKE_INPUTS+=(--update-input $i)
    done
    ${FLAKE_INPUTS[*]} "$@"
  ;;
  home-build)
    exec_action $NIX_BUILD "$FLAKE#homeConfigurations.$SYSTEM.$HM_USER.activationPackage" "$@"
  ;;
  home-switch)
    exec_action $NIX_BUILD "$FLAKE#homeConfigurations.$SYSTEM.$HM_USER.activationPackage" "$@"
    switch_if_needed "per-user/$HM_USER/home-manager" "result/activate"
  ;;
  boot|switch)
    exec_action $NIX_BUILD "$FLAKE#nixosConfigurations.$HOSTNAME.config.system.build.toplevel" "$@" && \
    switch_if_needed "system" sudo nixos-rebuild "$action" --flake "$FLAKE" "$@"
  ;;
  build|test|dry-activate)
    exec_action nixos-rebuild "$action" --flake "$FLAKE" "$@"
  ;;
  *) echo "Unexpected action: $action."
       usage ;;
esac
