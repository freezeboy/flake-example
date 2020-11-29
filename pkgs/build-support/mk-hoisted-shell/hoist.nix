{ runCommand, makeWrapper }:

let
  hoister = {custom ? "", name, home, pkg, }: 
    let
      pkgIsPath = builtins.typeOf pkg == "set";
      wrapper = if pkgIsPath then ''
          for exe in ${pkg}/bin/*; do
            if [ -f $exe -a -x $exe ]; then
              makeWrapper $exe $out/bin/`basename $exe` ${custom} \
                --set XDG_CONFIG_HOME "${home}/.config" \
                --set XDG_DATA_HOME "${home}/.local/share" \
                --set XDG_CACHE_HOME "${home}/.cache" \
                --set HOME "${home}"
            fi
          done
        '' else ''
          makeWrapper ${pkg} $out/bin/${name} ${custom} \
            --set XDG_CONFIG_HOME "${home}/.config" \
            --set XDG_DATA_HOME "${home}/.local/share" \
            --set XDG_CACHE_HOME "${home}/.cache" \
            --set HOME "${home}"
        '';
    in
    runCommand name { buildInputs = [ makeWrapper ]; } ''
      mkdir -p $out/bin
      ${wrapper}
      '';
in
  { pkg, home, javaHome ? null }:
  let
    pkgIsPath = builtins.typeOf pkg == "set";
    pkgName = if pkgIsPath then (builtins.parseDrvName pkg.name).name else baseNameOf pkg;
    useJava = if isNull javaHome
      then pkgName == "openjdk"
      else javaHome;
    custom = if useJava then "--add-flags -Duser.home=\"${home}\"" else "";
  in
  hoister {
    inherit home pkg custom;
    name = pkgName;
  }
