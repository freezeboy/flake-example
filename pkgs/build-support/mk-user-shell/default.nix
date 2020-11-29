{ mkShell }:

a@{ shellHook ? "", ... }:

# Helper shell filtering nix env variables when the goal is to use direnv
mkShell ((removeAttrs a ["shellHook"]) // {
  shellHook = ''
    unset AR AS CC CONFIG_SHELL CXX HOST_PATH LD NIX_BINTOOLS
    unset NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu NIX_BUILD_CORES
    unset NIX_BUILD_TOP NIX_CC NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu
    unset NIX_ENFORCE_NO_NATIVE NIX_HARDENING_ENABLE NIX_INDENT_MAKE NIX_LDFLAGS
    unset NIX_STORE NM OBJCOPY OBJDUMP RANLIB READELF SIZE SOURCE_DATE_EPOCH STRINGS
    unset STRIP TEMP TEMPDIR TMP TMPDIR buildInputs builder configureFlags
    unset depsBuildBuild depsBuildBuildPropagated depsBuildTarget depsBuildTargetPropagated
    unset depsHostHost depsHostHostPropagated depsTargetTarget depsTargetTargetPropagated
    unset doCheck doInstallCheck dontAddDisableDepTrack nativeBuildInputs nobuildPhase
    unset out outputs patches phases propagatedBuildInputs propagatedNativeBuildInputs
    unset shell shellHook stdenv strictDeps system
  '' + shellHook;
})
