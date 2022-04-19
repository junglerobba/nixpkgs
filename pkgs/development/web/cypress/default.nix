{ callPackage
, lib
, fetchzip
, stdenv
}:

let
  availableBinaries = {
    x86_64-linux = {
      platform = "linux-x64";
      checksum = "sha256-9o0nprGcJhudS1LNm+T7Vf0Dwd1RBauYKI+w1FBQ3ZM=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      checksum = "sha256-aW3cUZqAdiOLzOC9BQM/bTkDVyw24Dx9nBSXgbiKe4c=";
    };
    x86_64-darwin = {
      platform = "darwin-x64";
      checksum = "sha256-88aXujeZIphqWq37WT9Xb1NrTZ6l3eqg5I7fu1xQJ5o=";
    };
    aarch64-darwin = {
      platform = "darwin-arm64";
      checksum = "sha256-rBcN3dA8qLxNVl7cpgXSE53ttjU4Qa88HLUIRJNW/ZQ=";
    };
  };
  inherit (stdenv.hostPlatform) system;
  binary = availableBinaries.${system} or (throw "cypress: No binaries available for system ${system}");
  inherit (binary) platform checksum;

  src = fetchzip {
    url = "https://cdn.cypress.io/desktop/${version}/${platform}/cypress.zip";
    sha256 = checksum;
    stripRoot = false;
  };
  pname = "cypress";
  version = "13.2.0";

  passthru = {
    updateScript = ./update.sh;

    tests = {
      # We used to have a test here, but was removed because
      #  - it broke, and ofborg didn't fail https://github.com/NixOS/ofborg/issues/629
      #  - it had a large footprint in the repo; prefer RFC 92 or an ugly FOD fetcher?
      #  - the author switched away from cypress.
      # To provide a test once more, you may find useful information in
      # https://github.com/NixOS/nixpkgs/pull/223903
    };
  };

  meta = with lib; {
    description = "Fast, easy and reliable testing for anything that runs in a browser";
    homepage = "https://www.cypress.io";
    mainProgram = "Cypress";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = lib.attrNames availableBinaries;
    maintainers = with maintainers; [ tweber mmahut Crafter ];
  };

  package = if stdenv.isLinux then ./linux.nix else ./darwin.nix;
  mkPackage = callPackage package {};
in mkPackage { inherit meta pname src version passthru; }
