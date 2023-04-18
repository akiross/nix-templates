{
  description = "A collection of flake templates for fun and profit";
  outputs = { self }: {
    android-emulator = {
      path = ./android-emulator;
      description = "Android emulator via nix flake";
    };
    python-app = {
      path = ./python-app;
      description = "A python app with dependencies";
    };
    python-notebook = {
      path = ./python-notebook;
      description = "A python notebook for development";
    };
    rust-cross = {
      path = ./rust-cross;
      description = "Rust project with cross-compilation";
    };
  };
}
