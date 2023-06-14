{
  description = "Terranix - Terraform, but in Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    schemas = { url = "github:Kranzes/terraform-schemas/schemas"; flake = false; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, lib, self', ... }: {
        legacyPackages = {
          lib = import ./lib { inherit pkgs lib self' inputs; };
          allModulesEvaluated = lib.evalModules { modules = (map self'.legacyPackages.lib.mkModuleFromJSON (lib.remove "google-beta" (builtins.attrNames pkgs.terraform-providers.actualProviders))); };
          docs = (pkgs.nixosOptionsDoc { inherit (self'.legacyPackages.allModulesEvaluated) options; warningsAreErrors = false; });
        };
      };
    };
}
