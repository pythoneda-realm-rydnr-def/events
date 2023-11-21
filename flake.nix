# flake.nix
#
# This file packages pythoneda-realm-rydnr/events as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-realm-rydnr-def/events
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Events for pythoneda-realm-rydnr/realm";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    pythoneda-shared-pythoneda-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-pythoneda-def/banner/0.0.2";
    };
    pythoneda-shared-pythoneda-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-pythoneda-banner.follows =
        "pythoneda-shared-pythoneda-banner";
      url = "github:pythoneda-shared-pythoneda-def/domain/0.0.2";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-realm-rydnr";
        repo = "events";
        version = "0.0.2";
        sha256 = "sha256-nk67pq3Eg9YEI9Sm9ytWUlWqnmfRIJXBu5cQVMfFJ74=";
        pname = "${org}-${repo}";
        pythonpackage = "pythoneda.realm.rydnr.events";
        pkgs = import nixos { inherit system; };
        description = "Events for pythoneda-realm-rydnr/realm";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "rydnr <github@acm-sl.org>" ];
        archRole = "E";
        space = "D";
        layer = "D";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease = "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-pythoneda-banner}/nix/shared.nix";
        pythoneda-realm-rydnr-events-for =
          { python, pythoneda-shared-pythoneda-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              pythonedaSharedPythonedaDomainVersion =
                pythoneda-shared-pythoneda-domain.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs;
              [ pythoneda-shared-pythoneda-domain ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-realm-rydnr-events-default;
          pythoneda-realm-rydnr-events-default =
            pythoneda-realm-rydnr-events-python311;
          pythoneda-realm-rydnr-events-python38 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38
              }/bin/banner.sh";
            package = packages.pythoneda-realm-rydnr-events-python38;
            python = pkgs.python38;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python38;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
            inherit archRole layer nixpkgsRelease org pkgs repo space;
          };
          pythoneda-realm-rydnr-events-python39 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39
              }/bin/banner.sh";
            package = packages.pythoneda-realm-rydnr-events-python39;
            python = pkgs.python39;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python39;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
            inherit archRole layer nixpkgsRelease org pkgs repo space;
          };
          pythoneda-realm-rydnr-events-python310 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310
              }/bin/banner.sh";
            package = packages.pythoneda-realm-rydnr-events-python310;
            python = pkgs.python310;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python310;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
            inherit archRole layer nixpkgsRelease org pkgs repo space;
          };
          pythoneda-realm-rydnr-events-python311 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311
              }/bin/banner.sh";
            package = packages.pythoneda-realm-rydnr-events-python311;
            python = pkgs.python311;
            pythoneda-shared-pythoneda-banner =
              pythoneda-shared-pythoneda-banner.packages.${system}.pythoneda-shared-pythoneda-banner-python311;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
            inherit archRole layer nixpkgsRelease org pkgs repo space;
          };
        };
        packages = rec {
          default = pythoneda-realm-rydnr-events-default;
          pythoneda-realm-rydnr-events-default =
            pythoneda-realm-rydnr-events-python311;
          pythoneda-realm-rydnr-events-python38 =
            pythoneda-realm-rydnr-events-for {
              python = pkgs.python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python38;
            };
          pythoneda-realm-rydnr-events-python39 =
            pythoneda-realm-rydnr-events-for {
              python = pkgs.python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python39;
            };
          pythoneda-realm-rydnr-events-python310 =
            pythoneda-realm-rydnr-events-for {
              python = pkgs.python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python310;
            };
          pythoneda-realm-rydnr-events-python311 =
            pythoneda-realm-rydnr-events-for {
              python = pkgs.python311;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-python311;
            };
        };
      });
}
