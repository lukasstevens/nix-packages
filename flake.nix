{
  description = "Custom packages for Lukas Stevens' Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      overlays.default = final: prev: {
        pi = final.callPackage ./pkgs/pi-coding-agent {};
        pi-subagents = final.pi.extensions.subagents;
        isabelle-with-mcp = final.callPackage ./pkgs/isabelle/with-mcp.nix {
          unstablePkgs = import nixpkgs-unstable {
            system = final.stdenv.hostPlatform.system;
          };
        };
      };

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in {
          inherit (pkgs) pi pi-subagents isabelle-with-mcp;
          pi-with-subagents = pkgs.pi.withExtensions (extensions: [ extensions.subagents ]);
        });
    };
}
