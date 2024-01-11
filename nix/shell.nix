{
  callPackage,
  gopls,
  go,
}: let
  mainPkg = callPackage ./default.nix {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      (oa.nativeBuildInputs or [])
      ++ [
        gopls
        go
      ];
  })
