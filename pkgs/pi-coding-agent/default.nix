{ callPackage, fetchFromGitHub }:

let
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-AsutbwnjiwwLkB5tqLW+1GdGZyLmXsU0W+SNdNhJu7U=";
  };
  extensions = {
    subagents = callPackage ./extensions/subagents {};
  };
  compose = callPackage ./with-extensions.nix {};
  # Recent npm releases omit npm-shrinkwrap.json. Use upstream's Nix recipe
  # and pinned install lock instead of reconstructing the npm dependency tree.
  upstream = callPackage "${src}/nix/package.nix" { source = src; };
  pi = upstream.overrideAttrs (old: {
    # Retain the package layout expected by the subagents launcher metadata.
    postInstall = (old.postInstall or "") + ''
      ln -s pi/node_modules "$out/lib/node_modules"
    '';
    postFixup = (old.postFixup or "") + ''
      wrapProgram "$out/bin/pi" \
        --set PI_PACKAGE_DIR "$out/lib/node_modules/@earendil-works/pi-coding-agent" \
        --set-default PI_SKIP_VERSION_CHECK 1 \
        --set-default PI_TELEMETRY 0
    '';
    passthru = (old.passthru or {}) // {
      inherit extensions;
      withExtensions = select: compose {
        inherit pi;
        extensions = select extensions;
      };
    };
  });
in
pi
