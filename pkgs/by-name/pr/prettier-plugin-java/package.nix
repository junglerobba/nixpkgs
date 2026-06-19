{
  lib,
  stdenv,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  fetchFromGitHub,
  fetchYarnDeps,
  jq,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prettier-plugin-java";
  version = "2.9.7";

  src = fetchFromGitHub {
    owner = "jhipster";
    repo = "prettier-java";
    rev = "${finalAttrs.pname}@${finalAttrs.version}";
    hash = "sha256-98z6gpy1EfM4vXCOODyqfwaDVFaV7nFdPLVdjbtYgAM=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-T4z9Qe2SYsjnYs6QAOD2pvR4DubqXaC/je4+oOImglY=";
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # Move prettier from devDependencies to dependencies
  # Fixes error: Cannot find module 'prettier'
  postPatch = ''
     cat <<< $(${jq}/bin/jq '
      .dependencies.prettier = .devDependencies.prettier
      | del(.devDependencies.prettier)
    ' package.json) > package.json
  '';

  meta = {
    description = "Prettier Java Plugin";
    mainProgram = "prettier-plugin-java";
    homepage = "https://github.com/jhipster/prettier-java";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ junglerobba ];
  };
})
