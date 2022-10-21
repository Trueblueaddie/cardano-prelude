{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std presets;
in {
  treefmt = presets.nixago.treefmt {
    configData.formatter = {
      haskell = {
        command = "ormolu";
        options = [
          "--ghc-opt"
          "-XBangPatterns"
          "--ghc-opt"
          "-XPatternSynonyms"
          "--ghc-opt"
          "-XTypeApplications"
          "--mode"
          "inplace"
          "--check-idempotence"
        ];
        includes = ["*.hs"];
      };
    };
    packages = [nixpkgs.ormolu];
  };

  editorconfig = presets.nixago.editorconfig {
    configData = {
      "*.hs" = {
        indent_style = "space";
        indent_size = 2;
        trim_trailing_whitespace = "true";
        insert_final_newline = "true";
        charset = "utf-8";
        end_of_line = "lf";
      };
    };
  };

  conform = presets.nixago.conform;

  lefthook = presets.nixago.lefthook;
}
