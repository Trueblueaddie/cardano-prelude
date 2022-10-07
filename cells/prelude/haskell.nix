{
  haskell-nix,
  src,
}: let
  inherit (haskell-nix) haskellLib;
  extra-compilers = ["ghc924"];
in
  haskell-nix.cabalProject' ({
    config,
    pkgs,
    lib,
    ...
  }: {
    # Uncomment for your system you want to see `nix flake show` without build agent for other systems:
    #evalSystem = "x86_64-linux";
    #evalSystem = "x86_64-darwin";
    #evalSystem = "aarch64-darwin";

    name = "cardano-prelude";
    # default-compiler
    compiler-nix-name = lib.mkDefault "ghc8107";
    # extra-compilers
    flake.variants = lib.genAttrs extra-compilers (x: {compiler-nix-name = x;});
    # We clean-up src to avoid rebuild for unrelated changes:
    src = haskellLib.cleanSourceWith {
      inherit src;
      name = "cardano-prelude-src";
      filter = path: type: let
        relPath = lib.removePrefix "${src}/" path;
      in
        # excludes top-level directories not part of cabal project:
        (type
          != "directory"
          || (builtins.match ".*/.*" relPath != null)
          || (!(lib.elem relPath [
              "cells"
            ])
            && !(lib.hasPrefix "." relPath)))
        # exclude ".gitignore" files
        && !(lib.hasSuffix ".gitignore" relPath)
        # only keep cabal.project from files at root:
        && (type == "directory" || builtins.match ".*/.*" relPath != null || (relPath == "cabal.project"));
    };
    # Cross compilation support:
    crossPlatforms = p:
      lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        [p.musl64]
        ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 p.mingwW64
      );
    shell = {
      # not used
      withHoogle = false;
      # Skip cross compilers for the shell
      crossPlatforms = p: [];
    };
    modules = let
      # deduce package names from the cabal project to avoid hard-coding them:
      projectPackageNames =
        builtins.attrNames (haskellLib.selectProjectPackages
          (haskell-nix.cabalProject' (builtins.removeAttrs config ["modules"])).hsPkgs);
    in [
      {
        # compile all local project packages with -Werror
        packages =
          lib.genAttrs projectPackageNames
          (name: {configureFlags = ["--ghc-option=-Werror"];});
      }
    ];
  })
