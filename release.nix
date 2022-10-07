############################################################################
#
# Hydra release jobset.
#
# The purpose of this file is to select jobs defined in default.nix and map
# them to all supported build platforms.
#
############################################################################
# The project sources
{
  cardano-prelude ? {
    outPath = ./.;
    rev = "abcdef";
  },
  system ? builtins.currentSystem,
  supportedSystems ? ["x86_64-linux" "x86_64-darwin"],
}: let
  inherit
    (
      import
      (
        let
          lock = builtins.fromJSON (builtins.readFile ./flake.lock);
        in
          fetchTarball {
            url = "https://github.com/input-output-hk/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
            sha256 = lock.nodes.flake-compat.locked.narHash;
          }
      )
      {src = cardano-prelude;}
    )
    defaultNix
    ;

  inherit (defaultNix.inputs.nixpkgs.legacyPackages.${system}) pkgs lib;

  jobs = lib.getAttrs supportedSystems defaultNix.hydraJobs;

  required = pkgs.releaseTools.aggregate {
    name = "github-required";
    meta.description = "All jobs required to pass CI";
    constituents =
      lib.mapAttrsToList (_: s: s.required) jobs
      ++ [
        # Added to be sure that hydra notify even if there is no change in above jobs:
        (pkgs.writeText "revision.txt" cardano-prelude.rev)
      ];
  };
in
  jobs
  // {
    inherit required;
  }
