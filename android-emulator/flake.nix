{
  description = "android-emu";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.android_sdk.accept_license = true;
        config.allowUnfree = true;
      };
      android = pkgs.androidenv.composeAndroidPackages {
        # TODO: Find a way to pin these
        # toolsVersion = "26.1.1";
        # platformToolsVersion = "33.0.3";
        # buildToolsVersions = [ "33.0.0" ];
        includeEmulator = true;
        # emulatorVersion = "31.3.14";
        platformVersions = [ "33" ];
        # includeSources = false;
        includeSystemImages = true;
        # systemImageTypes = [ "default" ];
        abiVersions = [ "x86_64" "armeabi-v7a" "arm64-v8a" ];
        # includeNDK = false;
        # useGoogleAPIs = false;
        # useGoogleTVAddOns = false;
      };
      pinnedJDK = pkgs.jdk11;
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          # flutterPackages.beta
          pinnedJDK
          android.platform-tools
          android.emulator
          android.androidsdk
          android.system-images
          # flutterPackages.dart-beta # Flutter
          # gitlint # Code hygiene
        ];

        ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
        JAVA_HOME = pinnedJDK;
        ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
      };
    });
}

