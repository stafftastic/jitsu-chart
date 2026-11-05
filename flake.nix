{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      argsFor = system: {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      };
      forAllSystems = f: lib.genAttrs systems (system: f (argsFor system));
    in
    {
      devShells = forAllSystems (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              kubernetes-helm
            ];
          };
        }
      );

      packages = forAllSystems (
        { pkgs, system, ... }:
        {
          default = self.packages.${system}.jitsu-chart;
          jitsu-chart = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "jitsu-chart";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./.helmignore
                ./Chart.lock
                ./Chart.yaml
                ./LICENSE
                ./README.md
                ./scripts
                ./templates
                ./values.yaml
              ];
            };

            chartDependencies = pkgs.stdenvNoCC.mkDerivation {
              name = "jitsu-chart-dependencies";
              src = lib.fileset.toSource {
                root = ./.;
                fileset = lib.fileset.unions [
                  ./Chart.lock
                  ./Chart.yaml
                ];
              };
              nativeBuildInputs = [ pkgs.kubernetes-helm ];
              impureEnvVars = lib.fetchers.proxyImpureEnvVars;
              SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
              buildPhase = ''
                runHook preBuild
                export HOME="$TMPDIR"
                helm dependency build --skip-refresh .
                runHook postBuild
              '';
              installPhase = ''
                runHook preInstall
                mv charts "$out"
                runHook postInstall
              '';
              dontFixup = true;
              outputHashMode = "recursive";
              outputHashAlgo = "sha256";
              outputHash = "sha256-3tZiwFsYPBXHTKSqaYGMilY7exPxJAqxvB3rKnJ3fRw=";
            };

            nativeBuildInputs = [ pkgs.kubernetes-helm ];
            buildPhase = ''
              runHook preBuild
              export HOME="$TMPDIR"
              cp -r ${finalAttrs.chartDependencies} charts
              chmod -R u+w charts
              helm package --destination "$out" .
              runHook postBuild
            '';
            dontInstall = true;
            dontFixup = true;
          });
        }
      );

      checks = forAllSystems (
        { pkgs, system, ... }:
        {
          formatting = self.formatter.${system}.check self;
          nix-lint =
            pkgs.runCommandLocal "nix-lint"
              {
                nativeBuildInputs = with pkgs; [
                  deadnix
                  statix
                ];
              }
              ''
                cd ${self}
                statix check .
                deadnix --fail .
                touch $out
              '';
          package = self.packages.${system}.default;
        }
      );

      formatter = forAllSystems (
        { pkgs, ... }:
        pkgs.treefmt.withConfig {
          settings = {
            on-unmatched = "info";
            formatter = {
              nixfmt = {
                command = lib.getExe pkgs.nixfmt;
                includes = [ "*.nix" ];
              };
              oxfmt = {
                command = lib.getExe pkgs.oxfmt;
                includes = [
                  "*.yaml"
                  "*.yml"
                ];
                excludes = [ "templates/**" ];
              };
              ruff = {
                command = lib.getExe pkgs.ruff;
                options = [ "format" ];
                includes = [
                  "*.py"
                  "*.pyi"
                ];
              };
            };
          };
        }
      );
    };
}
