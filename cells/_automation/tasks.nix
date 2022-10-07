{
  inputs,
  cell,
}: let
  inherit (inputs.nixpkgs) system lib;
  inherit (inputs.tullia) flakeOutputTasks taskSequence;
  inherit (cell.library) ciInputName;

  common = {config, ...}: {
    preset = {
      # needed on top-level task to set runtime options
      nix.enable = true;

      github-ci = {
        enable = config.actionRun.facts != {};
        repo = "input-output-hk/cardano-prelude";
        sha = config.preset.github-ci.lib.getRevision ciInputName null;
      };
    };
  };

  mkJobTask = flakeOutputTask: {config, ...}: {
    imports = [common flakeOutputTask];

    memory = 1024 * 8;
    nomad.resources.cpu = 10000;
  };
  mkJobTasks = lib.mapAttrs (_: mkJobTask);

  jobTasks = mkJobTasks (flakeOutputTasks [system "_automation" "ciJobs"]
    {
      outputs.${system} = inputs.cells;
    });

  ciTaskSeqNames = ["${system}._automation.ciJobs.required" "${system}._automation.ciJobs.nonrequired"];
  ciTaskSeq = taskSequence "ci/" (lib.getAttrs ciTaskSeqNames jobTasks) ciTaskSeqNames;
in
  jobTasks
  // ciTaskSeq
  // {
    "ci" = {lib, ...}: {
      imports = [common];
      after = lib.attrNames ciTaskSeq;
    };
  }
