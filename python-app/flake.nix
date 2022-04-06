# This is a template with some examples showing how to use python with nix:
# - the flake itself packages a python application,
# - you can see in `my_py_env` and `my_py_env_dev` how to get (nix) python
#   environments with dependencies, some exclusive to dev environment (nix develop)
# - `pypi_package`: example on how to use a package from pypi instead of nixpkgs
# - `my_py_tool`: example of python script to be used from the shell
# - `my_help_script`: example of bash script useful for dev
{
  description = "A python application";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem
    (system:
      let
        # Example application name, for convenience.
        packageName = "my-py-app";

        # The packages to use as dependencies.
        pkgs = nixpkgs.legacyPackages.${system};

        # Example package that is not in nixpkgs
        pypi_package = pkgs.python39Packages.buildPythonPackage rec {
          pname = "lark"; # example
          version = "1.1.2";

          # Fetch from pypi or use a path e.g. ./somepackage/
          src = pkgs.python39Packages.fetchPypi {
            inherit pname version;
            sha256 = "sha256-eo0MB9Zj2pOR1/ruG/HX30mYxHykOlk8vvXHVmrNBXo=";
          };

          # Some build inputs might be necessary also at runtime
          propagatedBuildInputs = [ pkgs.python39Packages.aiohttp ];

          doCheck = false;

          meta = with pkgs.lib; {
            homepage = "https://github.com/.../...";
            description = "A package for doing things";
            license = licenses.bsd3;
            maintainers = [ "John Doe" ];
          };
        };

        # A python environment with some dependencies, used for runtime.
        my_py_env = pkgs.python3.withPackages (
          ps: with ps; [
            parse
            pypi_package
          ]
        );

        my_py_env_dev = pkgs.python3.withPackages (
          ps: with ps; [
            pytest
          ]
        );

        # Example of a python script with some dependencies.
        # Note: this is pep8-ed when built.
        my_py_tool = pkgs.writers.writePython3Bin
          "my-py-tool"
          { libraries = [ pkgs.python3Packages.click ]; }
          ''
            import click


            @click.command()
            def hello():
                click.echo("Hello world!")


            if __name__ == '__main__':
                hello()
          '';

        ## Example script that depends on a specific python environment
        my_help_script = pkgs.writeShellScriptBin "my_help_script" ''
          echo "Running tests!"
          ${my_py_env_dev}/bin/pytest
        '';

      in
      rec {
        # The application we are packaging.
        # Can be packaged in various ways, but we use these builders:
        # https://nixos.org/manual/nixpkgs/stable/#python
        # buildPythonPackage would have been used for libraries.
        packages.${packageName} = pkgs.python3Packages.buildPythonApplication rec {
          name = packageName;
          src = ./src;
          # Build and/or runtime dependencies.
          buildInputs = [
            # The environment is used at runtime.
            my_py_env
          ];
        };

        # The default package in this flake.
        defaultPackage = self.packages.${system}.${packageName};

        # A development shell for nix develop.
        devShell = pkgs.mkShell {
          buildInputs = [
            my_help_script
            my_py_tool
            my_py_env
            my_py_env_dev
          ];
        };
      });

}
