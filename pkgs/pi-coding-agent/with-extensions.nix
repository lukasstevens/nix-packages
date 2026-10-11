{ lib, symlinkJoin, makeWrapper }:

{ pi, extensions }:

assert lib.assertMsg (lib.all (extension: extension ? piExtension) extensions)
  "pi.withExtensions: every extension must provide piExtension metadata";

let
  selected = lib.unique extensions;
  packagePaths = map (extension:
    "${extension}/${extension.piExtension.packageSubdir}"
  ) selected;
  environment = lib.foldl' (acc: extension:
    let
      values = (extension.piExtension.environment or (_: {})) pi;
      conflicts = lib.filter (name:
        builtins.hasAttr name acc && acc.${name} != values.${name}
      ) (builtins.attrNames values);
    in
    assert lib.assertMsg (conflicts == [])
      "pi.withExtensions: conflicting environment variables: ${lib.concatStringsSep ", " conflicts}";
    acc // values
  ) {} selected;
  wrapperArgs = lib.concatLists (lib.mapAttrsToList (name: value:
    [ "--set" name value ]
  ) environment) ++ [ "--run" ''
    # Pi dispatches management subcommands using the first argument. Do not
    # prepend resource flags to those commands; only session invocations.
    case "''${1-}" in
      install|remove|uninstall|update|list|config|auth|mcp) ;;
      *) set -- ${lib.escapeShellArgs (lib.concatMap (path: [ "--extension" path ]) packagePaths)} "$@" ;;
    esac
  '' ];
in
  if selected == [] then pi else symlinkJoin {
    name = "${pi.pname}-with-extensions-${pi.version}";
    paths = [ pi ];
    nativeBuildInputs = [ makeWrapper ];
  
    postBuild = ''
      # Replace only the executable symlink; never modify the base package.
      rm "$out/bin/pi"
      makeWrapper ${pi}/bin/pi "$out/bin/pi" ${lib.escapeShellArgs wrapperArgs}
    '';
  
    passthru = {
      inherit (pi) pname version;
      unwrapped = pi;
      extensionPackages = selected;
      inherit packagePaths;
    };
    meta = pi.meta;
  }
