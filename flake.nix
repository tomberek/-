{
  description = "Chained packages";
  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ]; #"x86_64-darwin" "aarch64-linux"];

      # Helper functions
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      });

      makeMerger = self: packageset: packagesetfunc:
        let
          gen = name: paths: self.buildEnv {
            inherit name;
            paths = [
              (packagesetfunc (ps: paths))
            ] ++ paths;
            ignoreCollisions = true;
            meta.mainProgram =
              let
                last = self.lib.last paths;
              in
                last.meta.mainProgram
                  or (builtins.parseDrvName last.name).name;

            # Use lists not attrsets because order matters
            passthru = with builtins; mapAttrs
              (n: v: gen
                (if length paths > 5 then "merged-environment" else "${name}-${n}")
                (paths ++ [ v ])
              )
              (self // packageset);
          };
        in
        gen "merged" [ ];

      addLanguage = { lang, langPackages ? lang + "Packages", withPackages ? "withPackages", langWith ? lang + "With" }: {
        inherit lang langPackages withPackages langWith;
      };

      languages = [
        (addLanguage { lang = "python2"; })
        (addLanguage { lang = "python3"; })
        (addLanguage { lang = "python310"; })
        (addLanguage { lang = "python311"; })
        (addLanguage { lang = "python312"; })
        (addLanguage { lang = "python313"; })
        (addLanguage { lang = "perl"; })
        (addLanguage { lang = "haskel"; withPackages = "ghcWithPackages"; })
      ];

      mergeLang = self: super: lang: makeMerger self super.${lang.langPackages} super.${lang.lang}.${lang.withPackages};
    in
    {
      overlays.default = final: prev:
        let
          self = final;
          super = prev;
          mergedLangs = builtins.map (lang: { ${lang.langWith} = mergeLang self super lang; }) languages;
        in
        builtins.foldl' (x: y: x // y)
          {
            "-" = self.pkgsMerge;
            "+" = self.pkgsMerge;
            pkgsMerge = makeMerger self super (paths: paths { });
          }
          mergedLangs;

      legacyPackages = forAllSystems (system: nixpkgsFor.${system});
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) pkgsMerge"+" "-" python3With;
      });

      defaultPackage = forAllSystems (system: self.packages."${system}".pkgsMerge);
    };
}
