{ callPackage
, fetchzip
, makeWrapper
, stdenvNoCC
}:

{ meta
, pname
, src
, version
, passthru
}:

stdenvNoCC.mkDerivation {
  inherit pname version meta src passthru;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{Applications,bin}
    mv Cypress.app $out/Applications/
    makeWrapper $out/Applications/Cypress.app/Contents/MacOS/Cypress $out/bin/Cypress

    runHook postInstall
  '';
}
