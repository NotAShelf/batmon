{
  description = "Batmon - battery monitor";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    pkgsForEach = nixpkgs.legacyPackages;
  in {
    nixosModules = {
      batmon = ./nix/module.nix {inherit self;};
    };

    packages = forEachSystem (system: {
      batmon = pkgsForEach.${system}.callPackage ./nix/package.nix {};
      default = self.packages.${system}.batmon;
    });

    devShells = forEachSystem (system: {
      default = pkgsForEach.${system}.callPackage ./nix/shell.nix {
        packagePath = ./nix/package.nix;
      };
    });
  };
}
