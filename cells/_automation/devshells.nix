{
  cell,
  inputs,
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs.std) std presets;
  inherit (inputs.std.lib) dev;
  inherit (inputs.cells) prelude;
  inherit (prelude.library) project;

  mkDevShell = variant: project:
    dev.mkShell {
      name = "Cardano Prelude${lib.optionalString (variant != "") " - ${variant}"}";
      imports = [
        std.devshellProfiles.default
        (prelude.devshellProfiles.mkDev project)
      ];
      nixago = lib.attrValues cell.nixago;
      commands = [
        {
          package = inputs.tullia.tullia.apps.tullia;
          name = "tullia";
          category = "ci";
        }
      ];
    };
in
  lib.mapAttrs mkDevShell project.projectVariants
  // {
    default = mkDevShell "" project;
  }
