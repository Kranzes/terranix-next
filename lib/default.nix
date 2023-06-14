{ lib, pkgs, inputs, self' }:
let
  providerSchemas = provider: (lib.importJSON "${inputs.schemas}/${provider}.json").provider_schemas.${lib.toLower (pkgs.terraform-providers.${provider}.provider-source-address)};
in
rec {
  mkTerraformType = type: import ./mkTerraformType.nix { inherit lib type; };

  mkModuleFromJSON = provider: import ./mkModuleFromJSON.nix { inherit self' provider; };

  mkOptionsFromJSON = block: builtins.mapAttrs
    (_: { description ? null, optional ? false, type ? "raw", ... }: lib.mkOption
      {
        type = mkTerraformType type;
      }
    // lib.optionalAttrs optional { type = lib.types.nullOr (mkTerraformType type); default = null; }
    // lib.optionalAttrs (description != null) { description = lib.mdDoc description; }
    )
    block;

  mkNestedAttrs = schemas:
    let
      mkResource = schema: lib.mkOption ({
        type = lib.types.attrsOf (lib.types.submodule {
          options = mkOptionsFromJSON schema.block.attributes;
        });
      } // lib.optionalAttrs (schema.block ? description) { description = lib.mdDoc schema.block.description; });
    in
    lib.mapAttrs (_: mkResource) schemas;

  mkResourceAttrs = provider: let ps = providerSchemas provider; in lib.optionalAttrs (ps ? resource_schemas) (mkNestedAttrs ps.resource_schemas);

  mkDataAttrs = provider: let ps = providerSchemas provider; in lib.optionalAttrs (ps ? data_source_schemas) (mkNestedAttrs ps.data_source_schemas);

  mkProviderAttrs = provider: let ps = providerSchemas provider; in lib.optionalAttrs (ps ? provider.block.attributes) (mkOptionsFromJSON ps.provider.block.attributes);

  terranixConfiguration = { specialArgs ? { }, modules ? [ ], stripNulls ? true, enabledProviders ? [ ] }:
    (pkgs.formats.json { }).generate "config.tf.json" (import ./eval { inherit lib pkgs stripNulls modules specialArgs enabledProviders self'; }).config;
}
