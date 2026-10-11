# nix-packages

Custom Nix packages, exported as `packages.<system>` and `overlays.default`.

Package definitions and their supporting files live in `pkgs/`.

To use the overlay in another flake, add this repository as an input and include `inputs.nix-packages.overlays.default` in `nixpkgs.overlays`. The `nixpkgs` and `nixpkgs-unstable` inputs can follow the consuming flake's inputs.
