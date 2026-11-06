{ lib, buildNpmPackage, fetchzip, nodejs_24 }:

buildNpmPackage rec {
  pname = "pi-subagents";
  version = "0.86.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/pi-subagents/-/pi-subagents-${version}.tgz";
    hash = "sha256-X+ptBywu1MOPZYItI4fDbltVcBz4IMpnBcEkS9JnQeY=";
  };

  nodejs = nodejs_24;
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-uDVMiKyHNltgFsCv3URZBKy6+LNBNAjlqAN53eSXrS4=";
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
