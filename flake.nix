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
        let
          chart = "${self.packages.${system}.default}/jitsu-0.0.0.tgz";
          rendered =
            pkgs.runCommand "jitsu-chart-rendered" { nativeBuildInputs = [ pkgs.kubernetes-helm ]; }
              ''
                export HOME="$TMPDIR"
                mkdir "$out"
                helm template jitsu ${chart} > "$out/defaults.yaml"
                helm template jitsu ${chart} -f ${./tests/external-services.yaml} > "$out/external-services.yaml"
              '';
        in
        {
          actionlint =
            pkgs.runCommandLocal "actionlint"
              {
                nativeBuildInputs = with pkgs; [
                  actionlint
                  shellcheck
                ];
              }
              ''
                actionlint ${./.github/workflows}/*.yaml
                touch $out
              '';
          ci-coverage =
            pkgs.runCommandLocal "jitsu-chart-ci-coverage"
              {
                checks = lib.concatLines (lib.attrNames self.checks.x86_64-linux);
                passAsFile = [ "checks" ];
              }
              ''
                grep -ohE '\.#checks\.x86_64-linux\.[A-Za-z0-9_-]+' ${./.github/workflows/pull-request.yaml} \
                  | sed 's/^\.#checks\.x86_64-linux\.//' | sort -u > built
                sort -u "$checksPath" > declared
                missing=$(comm -23 declared built)
                if [ -n "$missing" ]; then
                  echo "checks not built by any pull request job:" $missing
                  exit 1
                fi
                touch $out
              '';
          formatting = self.formatter.${system}.check self;
          helm-lint =
            pkgs.runCommandLocal "jitsu-chart-helm-lint" { nativeBuildInputs = [ pkgs.kubernetes-helm ]; }
              ''
                export HOME="$TMPDIR"
                helm lint --strict ${chart}
                helm lint --strict ${chart} -f ${./tests/external-services.yaml}
                touch $out
              '';
          kubeconform =
            pkgs.runCommandLocal "jitsu-chart-kubeconform" { nativeBuildInputs = [ pkgs.kubeconform ]; }
              ''
                kubeconform -strict -summary \
                  -schema-location '${
                    pkgs.fetchFromGitHub {
                      owner = "yannh";
                      repo = "kubernetes-json-schema";
                      rev = "86d045595d3f93b703bbf439cf9eb4bd6830d58f";
                      sparseCheckout = [ "v1.37.2-standalone-strict" ];
                      hash = "sha256-qHKq+eVsJY/NNFoue/wmLowFrCzRMpRvOJqgneuTYp0=";
                    }
                  }/v1.37.2-standalone-strict/{{.ResourceKind}}{{.KindSuffix}}.json' \
                  -schema-location '${
                    pkgs.linkFarm "jitsu-chart-crd-schemas" {
                      "monitoring.coreos.com/servicemonitor_v1.json" = pkgs.fetchurl {
                        url = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/6ab3493622cd387923a2d0da5234f53e80e1bd28/monitoring.coreos.com/servicemonitor_v1.json";
                        hash = "sha256-eAYvTCNkv2BWqN9Az7cDmTb4NgFK/yB4wMWY385pxR4=";
                      };
                    }
                  }/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
                  ${rendered}/defaults.yaml ${rendered}/external-services.yaml
                touch $out
              '';
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
          template = pkgs.runCommandLocal "jitsu-chart-template" { } ''
            ${
              lib.getExe (
                pkgs.writeShellApplication {
                  name = "jitsu-chart-template";
                  runtimeInputs = [ pkgs.yq-go ];
                  text = builtins.readFile ./tests/template.sh;
                }
              )
            } ${rendered}
            touch $out
          '';
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
