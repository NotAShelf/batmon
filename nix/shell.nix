{
  mkShellNoCC,
  gopls,
  go,
}:
mkShellNoCC {
  name = "batmon";
  packages = [
    gopls
    go
  ];
}
