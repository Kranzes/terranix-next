{ pkgs
, lib
, specialArgs
, modules
, stripNulls
, enabledProviders
, self'
}:
let
  sanitize = value: {
    list = map sanitize value;
    set =
      let
        stripped = lib.pipe value [
          (lib.flip builtins.removeAttrs [ "_module" "_ref" ])
          (lib.filterAttrs (_: v: stripNulls -> v != null))
        ];
      in
      lib.mapAttrs (lib.const sanitize) stripped;
  }.${builtins.typeOf value} or value;

  evaluateConfiguration = userModules:
    lib.evalModules {
      modules = [
        ./terraform-options.nix
        { _module.args = { inherit pkgs; }; }
      ] ++ userModules
      ++ (map self'.legacyPackages.lib.mkModuleFromJSON enabledProviders);
      inherit specialArgs;
    };

  terranix = userModules:
    let
      eval = evaluateConfiguration userModules;
      grabAttrs = names: lib.filterAttrs (name: value: (lib.elem name names) && value != { });
    in
    {
      config = lib.flip grabAttrs (sanitize eval).config [
        "data"
        "locals"
        "module"
        "output"
        "provider"
        "resource"
        "terraform"
        "variable"
      ];
    };
in
terranix modules
