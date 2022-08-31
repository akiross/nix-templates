{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;

        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          buildInputs = [
            cargo
            fontconfig
            pkg-config
            rustPackages.clippy
            rustc
            rustfmt
            xorg.libxcb
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;

          APPEND_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            xorg.libX11
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            libGL
          ];
          shellHook = ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$APPEND_LIBRARY_PATH"
          '';
        };
      });
}
