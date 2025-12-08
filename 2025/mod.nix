{
  perSystem =
    { pkgs, ... }:
    {
      packages."2025" = pkgs.stdenv.mkDerivation {
        pname = "advent_of_code_2025";
        version = "0.0.0";

        nativeBuildInputs = [
          pkgs.zig.hook
        ];

        src = ./.;
      };
      devShells."2025" = pkgs.mkShell {
        name = "advent-of-code-2025";
        nativeBuildInputs = [
          pkgs.zig
          pkgs.zls
        ];
      };
    };
}
