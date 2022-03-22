{
  description = "Jupyter notebook project";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      py_dev_env = pkgs.python39.withPackages (ps: with ps; [
        numpy
        matplotlib
        notebook
        pytorch
      ]);
    in
    {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ py_dev_env ];
      };
    };
}

