{
  lib,
  mkYarnPackage,
  fetchYarnDeps,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:
let
  version = "18.0.4";

  src' = fetchFromGitHub {
    owner = "angular";
    repo = "angular-cli";
    rev = version;
    hash = "sha256-MMT222rA01Ih8HNYPTZ2y3qjO3M8a5DZI3GRKSQ3yJQ=";
  };

  yarnLock = "${src'}/yarn.lock";

  offlineCache = fetchYarnDeps {
    inherit yarnLock;
    hash = "sha256-6Wg+gXiQTLu1hccf99bmn4uDuy8XS+wsbpmorS27Jf0=";
  };

  angular-devkit-core = mkYarnPackage {
    pname = "@angular-devkit/core";
    src = "${src'}/packages/angular_devkit/core";
    inherit version offlineCache yarnLock;

    packageJSON = "${src'}/packages/angular_devkit/core/package.json";
  };

  angular-devkit-architect = mkYarnPackage {
    pname = "@angular-devkit/architect";
    src = "${src'}/packages/angular_devkit/architect";
    inherit version offlineCache yarnLock;

    packageJSON = "${src'}/packages/angular_devkit/architect/package.json";
    packageResolutions = {
      "@angular-devkit/core" = "${angular-devkit-core}/libexec/@angular-devkit/core";
    };
  };

  angular-devkit-schematics = mkYarnPackage {
    pname = "@angular-devkit/schematics";
    src = "${src'}/packages/angular_devkit/schematics";
    inherit version offlineCache yarnLock;

    packageJSON = "${src'}/packages/angular_devkit/schematics/package.json";
    packageResolutions = {
      "@angular-devkit/core" = "${angular-devkit-core}/libexec/@angular-devkit/core";
    };
  };

  schematics-angular = mkYarnPackage {
    pname = "@schematics/angular";
    src = "${src'}/packages/schematics/angular";
    inherit version offlineCache yarnLock;

    packageJSON = "${src'}/packages/schematics/angular/package.json";
    packageResolutions = {
      "@angular-devkit/core" = "${angular-devkit-core}/libexec/@angular-devkit/core";
      "@angular-devkit/schematics" = "${angular-devkit-schematics}/libexec/@angular-devkit/schematics";
    };
  };
in
mkYarnPackage {
  pname = "@angular/cli";
  src = "${src'}/packages/angular/cli";
  inherit version offlineCache yarnLock;

  packageJSON = "${src'}/packages/angular/cli/package.json";
  packageResolutions = {
    "@angular-devkit/core" = "${angular-devkit-core}/libexec/@angular-devkit/core";
    "@angular-devkit/architect" = "${angular-devkit-architect}/libexec/@angular-devkit/architect";
    "@angular-devkit/schematics" = "${angular-devkit-schematics}/libexec/@angular-devkit/schematics";
    "@schematics/angular" = "${schematics-angular}/libexec/@schematics/angular";
  };

  nativeBuildInputs = [ installShellFiles ];

  prePatch = ''
    export NG_CLI_ANALYTICS=false
  '';

  buildPhase = ''
    runHook preBuild

    yarn admin build

    runHook postBuild
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash zsh; do
      $out/bin/ng completion script > ng.$shell
      installShellCompletion ng.$shell
    done
  '';

  meta = {
    description = "CLI tool for Angular";
    homepage = "https://github.com/angular/angular-cli";
    license = lib.licenses.mit;
    mainProgram = "ng";
  };
}
