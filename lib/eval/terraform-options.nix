{ lib, ... }:

let
  terraformTypes = with lib.types; [
    number
    bool
    str
  ];

  mkUnionOption = { description, example ? { }, default ? { } }:
    lib.mkOption {
      inherit example description default;
      type = with lib.types; submodule {
        freeformType =
          let
            valueType = nullOr
              (oneOf (terraformTypes ++ [
                (attrsOf valueType)
                (listOf valueType)
              ])) // {
              description = lib.mdDoc "Terraform configuration union type";
              emptyValue.value = { };
            };
          in
          valueType;
      };
    };
in
{
  options = {
    data = mkUnionOption {
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/data-sources";
    };

    locals = mkUnionOption {
      example = {
        locals = {
          service_name = "forum";
          owner = "Community Team";
        };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/values/locals";
    };

    module = mkUnionOption {
      example = {
        module.consul = { source = "github.com/hashicorp/example"; };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/modules";
    };

    output = mkUnionOption {
      example = {
        output.instance_ip_addr.value = "aws_instance.server.private_ip";
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/values/outputs";
    };

    provider = mkUnionOption {
      example = {
        provider.google = {
          project = "acme-app";
          region = "us-central1";
        };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/providers";
    };

    resource = mkUnionOption {
      example = {
        resource.aws_instance.web = {
          ami = "ami-a1b2c3d4";
          instance_type = "t2.micro";
        };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/resources";
    };

    terraform = mkUnionOption {
      example = {
        terraform = {
          backend.s3 = {
            bucket = "mybucket";
            key = "path/to/my/key";
            region = "us-east-1";
          };
        };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/settings";
    };

    variable = mkUnionOption {
      example = {
        variable.image_id = {
          type = "string";
          description = lib.mdDoc "The id of the machine image (AMI) to use for the server.";
        };
      };
      description = lib.mdDoc "Details: https://developer.hashicorp.com/terraform/language/values/variables";
    };
  };
}
