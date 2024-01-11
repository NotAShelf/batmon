{
  packagePath,
  callPackage,
  gopls,
  go,
}: let
  mainPkg = callPackage packagePath {};
in
  mainPkg.overrideAttrs (oa: {
    nativeBuildInputs =
      (oa.nativeBuildInputs or [])
      ++ [
        gopls
        go
      ];
  })
