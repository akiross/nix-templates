{
  description = "A collection of flake templates for fun and profit";
  outputs = {self}: {
    python-app = {
      path = ./python-app;
      description = "A python app with dependencies";
    };
    python-notebook = {
      path = ./python-notebook;
      description = "A python notebook for development";
    };
  };
}
