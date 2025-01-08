{
  lib,
  buildGoModule,
}:
buildGoModule {
  pname = "Batmon";
  version = "0.1.0";

  src = builtins.path {
    path = ../.;
    name = "batmon-src";
  };

  vendorHash = null;
  ldflags = ["-s" "-w"];

  meta = {
    license = lib.licenses.gpl3Only;
    maintainers = [lib.maintainers.NotAShelf];
    mainProgram = "batmon";
  };
}
