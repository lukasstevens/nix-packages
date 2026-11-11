{ pkgs, stdenvNoCC, lib, isabelle }:

stdenvNoCC.mkDerivation rec {
  pname = "AFP";
  version = "2025-2";

  src = pkgs.fetchhg {
    url = "https://foss.heptapod.net/isa-afp/afp-2025-2";
    rev = "d73fde1397faa1257158b1f704d42975616d2d3f";
    sha256 = "sha256-xbWPBv0RpPXJ5qccmLk+u5AHIyOUOJ1jDaze88Nu0yw=";
  };

  dontConfigure = true;
  dontBuild = true;

  # Registration is done by isabelle.withComponents.
  installPhase = ''
    runHook preInstall

    dir=$out/${isabelle.dirname}/contrib/${pname}-${version}
    mkdir -p $dir
    cp -r thys/* $dir/
    rm -rf $dir/Go/test

    runHook postInstall
  '';

  meta = with lib; {
    description = "Archive of Formal Proofs";
    homepage = "https://isa-afp.org";
  };
}
