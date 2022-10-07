{
  cell,
  inputs,
}: {
  "cardano-prelude/ci" = {
    task = "ci";
    io = ''
      let github = {
        #input: "${cell.library.ciInputName}"
        #repo: "input-output-hk/cardano-prelude"
      }

      #lib.merge
      #ios: [
        #lib.io.github_push & github,
        #lib.io.github_pr   & github,
      ]
    '';
  };
}
