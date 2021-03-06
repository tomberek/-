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
    in {
      overlay = self: super: {
        "-" = self.pkgsMerge;
        "+" = self.pkgsMerge;
        pkgsMerge =
          let
            gen = name: paths: self.buildEnv {
              inherit name paths;
              ignoreCollisions = true;
              meta.mainProgram = let
                last = self.lib.last paths; in last.meta.mainProgram
                or (builtins.parseDrvName last.name).name;

              # Use lists not attrsets because order matters
              passthru = with builtins; mapAttrs (n: v: gen
                  (if length paths > 5 then "merged-environment" else "${name}-${n}")
                  (paths ++ [ v ])
                ) super;
            };
          in gen "merged" [ ];

        python3With =
          let
            gen = name: paths: self.buildEnv {
              inherit name;
              paths = 
              let custom = {buildEnv,pythonPackages}:
              f: let packages = f pythonPackages; in buildEnv.override { extraLibs = packages; makeWrapperArgs = [
                "--set" "PIP_PREFIX" "/root/_build"
                "--set" "PYTHONPATH" "/root/_build/lib/python3.9/site-packages"
                "--prefix" "PATH" ":" "/root/_build/bin"
              ];};
              in
                [
                  (custom {
                    buildEnv=super.python3.buildEnv;
                    pythonPackages=super.python3.packages;
                  }
                   (ps: paths))
              ];
              ignoreCollisions = true;
              meta.mainProgram = let
                last = self.lib.last paths; in last.meta.mainProgram
                or (builtins.parseDrvName last.name).name;

              # Use lists not attrsets because order matters
              passthru = with builtins; mapAttrs (n: v: gen
                  (if length paths > 5 then "merged-environment" else "${name}-${n}")
                  (paths ++ [ v ])
                ) super.python3Packages;
            };
          in gen "merged" [ ];
      };

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system})
        pkgsMerge "+" "-" python3With ;});

      defaultPackage = forAllSystems (system: self.packages."${system}".pkgsMerge);
    };
}
