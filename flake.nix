{
  description = "A collection of flake templates for fun and profit";
  outputs = {self}: {
    python-app = {
      path = ./python-app;
      description = "A python app with dependencies";
    };
  };
}
