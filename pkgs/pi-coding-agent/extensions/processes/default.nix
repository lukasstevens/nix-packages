{ lib, buildNpmPackage, fetchzip, nodejs_24, jq, bash }:

buildNpmPackage rec {
  pname = "pi-processes";
  version = "2.5.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@mjakl/pi-processes/-/pi-processes-${version}.tgz";
    hash = "sha256-pf0U6H1Iv1rXUPLsh+I35TO8tLnC36l5xScNTrinuzg=";
  };

  nodejs = nodejs_24;
  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json

    substituteInPlace src/utils/command-executor.ts \
      --replace-fail \
        'const DEFAULT_KNOWN_SHELL_PATHS = [' \
        'const DEFAULT_KNOWN_SHELL_PATHS = [ "${lib.getExe bash}",'
  '';
  npmDepsHash = "sha256-bl3bDhyBydjPeybKQfKmHP9EzdsLXrI7fGbNtHDIwgM=";
  npmFlags = [ "--ignore-scripts" "--legacy-peer-deps" ];
  dontNpmBuild = true;

  passthru.piExtension = {
    packageSubdir = "lib/node_modules/@mjakl/pi-processes";
  };

  meta = {
    description = "Manage long-running commands from Pi without blocking the conversation";
    homepage = "https://github.com/mjakl/pi-processes";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
