{ lib, buildNpmPackage, fetchzip, nodejs_24 }:

buildNpmPackage rec {
  pname = "pi-subagents";
  version = "0.75.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/pi-subagents/-/pi-subagents-${version}.tgz";
    hash = "sha256-rdjhXAuOuVvseFo6t2C4S5Zz+UHf5FJyZZLS4r1hS/Q=";
  };

  nodejs = nodejs_24;
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-rwmDMNjuCV+j8/inYogRBgxP3lX4menaRgTrxjCC2Z4=";
  npmFlags = [ "--ignore-scripts" "--legacy-peer-deps" ];
  dontNpmBuild = true;

  passthru.piExtension = {
    packageSubdir = "lib/node_modules/pi-subagents";
    environment = pi: {
      PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT =
        "${pi}/lib/node_modules/@earendil-works/pi-coding-agent";
    };
  };

  meta = {
    description = "Subagent delegation extension for Pi";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
