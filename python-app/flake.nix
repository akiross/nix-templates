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

        # A python environment with some dependencies, used for runtime.
        my_py_env = pkgs.python3.withPackages (
          ps: with ps; [
            parse
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
