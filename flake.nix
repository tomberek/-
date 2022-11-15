{
  description = "Chained packages";
  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ]; #"x86_64-darwin" "aarch64-linux"];

      # Helper functions
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system;
          overlays = [ self.overlay ]; });

      makeMerger = self: packageset: packagesetfunc:
          let
            gen = name: paths: self.buildEnv {
              inherit name;
              paths = [
                (packagesetfunc (ps: paths))
              ];
              ignoreCollisions = true;
              meta.mainProgram = let
                last = self.lib.last paths; in last.meta.mainProgram
                or (builtins.parseDrvName last.name).name;

              # Use lists not attrsets because order matters
              passthru = with builtins; mapAttrs (n: v: gen
                  (if length paths > 5 then "merged-environment" else "${name}-${n}")
                  (paths ++ [ v ])
                ) packageset;
            };
          in gen "merged" [ ];
    in {
      overlay = self: super: {
        "-" = self.pkgsMerge;
        "+" = self.pkgsMerge;
        pkgsMerge = makeMerger self super (paths: paths {});
        python2With = makeMerger self super.python2Packages super.python2.withPackages;
        python3With = makeMerger self super.python3Packages super.python3.withPackages;
        python39With = makeMerger self super.python39Packages super.python39.withPackages;
        python310With = makeMerger self super.python310Packages super.python310.withPackages;
        haskellWith = makeMerger self super.haskellPackages super.haskellPackages.ghcWithPackages;
        perlWith = makeMerger self super.perlPackages super.perl.withPackages;
      };

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system})
        pkgsMerge "+" "-" python3With ;});

      defaultPackage = forAllSystems (system: self.packages."${system}".pkgsMerge);
    };
}
