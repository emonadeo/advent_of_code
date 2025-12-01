{
  description = "Emonadeo's Advent of Code solutions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          devShells = {
            year2023 = pkgs.mkShell {
              name = "advent-of-code-2023";
              nativeBuildInputs = [
                pkgs.rust
              ];
            };
            year2024 = pkgs.mkShell {
              name = "advent-of-code-2024";
              nativeBuildInputs = [
                pkgs.gleam
              ];
            };
            year2025 = pkgs.mkShell {
              name = "advent-of-code-2025";
              nativeBuildInputs = [
                pkgs.zig
                pkgs.zls
              ];
            };
          };
        };
    };
}
