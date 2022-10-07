{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs iohk-nix;
  inherit (nixpkgs) lib;
  inherit (inputs.cells.prelude.library) project;

  ciJobs =
    project.flake'.ciJobs
    // {
      devShells = cell.devshells;
    };

  # path prefixes of jobs that should not be required for CI to pass (end up in `nonrequired`), empty for now:
  nonRequiredPaths = map lib.hasPrefix [];
in
  nixpkgs.callPackages iohk-nix.utils.ciJobsAggregates {inherit ciJobs nonRequiredPaths;}
  // ciJobs
