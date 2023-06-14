{ type, lib }:

let
  inherit (lib)
    types
    ;

  refOr = types.either (types.strMatching "\\$\\{.*}" // { description = "Terraform reference"; });

  terraformTypes = {
    inherit (types)
      number
      bool
      raw
      ;
    string = types.str;
    dynamic = types.raw;
  };

  mkTerraformType = type: if lib.isString type then refOr terraformTypes.${type} else
  let
    containerType = lib.elemAt type 0;
    containedType = lib.elemAt type 1;
  in
  refOr rec {
    list = types.listOf (mkTerraformType containedType);
    set = list;
    map = types.attrsOf (mkTerraformType containedType);
    object = types.submodule {
      options = lib.mapAttrs
        (_: option: lib.mkOption {
          type = mkTerraformType option;
        })
        containedType;
    };
  }.${containerType};
in
mkTerraformType type
