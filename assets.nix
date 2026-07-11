{
  fetchPnpmDeps,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
  src,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "demo_web";
  version = "0-unstable";
  inherit src;

  nativeBuildInputs = [
    nodejs # in case scripts are run outside of a pnpm call
    pnpmConfigHook
    pnpm # At least required by pnpmConfigHook, if not other (custom) phases
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-tWsauPFvFB50giZjnjgaKifJ25NO/lZsGjX1EHHIi60=";
  };

  buildPhase = ''
    pnpm build
  '';

  installPhase = ''
    mkdir -p $out/share
    cp -ar priv $out/share
  '';
})
