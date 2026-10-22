{ pkgs, lib, isabelle, unstablePkgs }:

let
  baseIsabelle = if pkgs.stdenv.hostPlatform.isLinux then unstablePkgs.isabelle else isabelle;
  pideMcp = pkgs.callPackage ./components/pide-mcp.nix { isabelle = baseIsabelle; };
  withComponents = baseIsabelle.withComponents (components:
    [
      pideMcp
      (pkgs.callPackage ./components/afp.nix { isabelle = baseIsabelle; })
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      components.isabelle-linter
    ]);
in
withComponents.overrideAttrs (old: {
  passthru = (old.passthru or {}) // {
    inherit pideMcp;
    inherit (baseIsabelle) version;
  };
})
