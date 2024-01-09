{
  lib,
  rustPlatform,
  ...
}: let
  pname = "batmon";
  version = "unstable-2024-01-08";
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = lib.cleanSource ./.;
    cargoHash = "sha256-d9wWr17BnlRwa3CLcfDeby60a2BPwpBy1xjY6oTgyG0=";

    meta = {
      description = "Nananananananana batmon";
      homepage = "https://github.com/NotAShelf/batmon.git";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [NotAShelf];
      mainProgram = "batmon";
      platforms = lib.platforms.linux;
    };
  }
