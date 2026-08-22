# NOTE: Use ./update.sh to bump the version and hashes.
{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  makeWrapper,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
let
  manifest = lib.importJSON ./manifest.json;
  platformKey = "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "codegraph";
  inherit (manifest) version;

  # The release tarball is a self-contained bundle: a vendored node runtime,
  # the compiled JS, and the native tree-sitter kernel. The npm package only
  # wraps these same archives, so we skip npm entirely.
  src = fetchurl {
    url = "https://github.com/colbymchenry/codegraph/releases/download/v${finalAttrs.version}/codegraph-${platformKey}.tar.gz";
    sha256 = manifest.platforms.${platformKey};
  };

  sourceRoot = "codegraph-${platformKey}";

  dontBuild = true;
  # The vendored node must keep its build id intact for the V8 snapshot.
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  strictDeps = true;

  # bin/codegraph derives the bundle root from its own location and execs
  # ../node, so the tree has to stay together; only the outer wrapper is
  # linked into $out/bin. That script also calls dirname/readlink, hence
  # coreutils on PATH — the ambient PATH is empty under an MCP host.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/codegraph
    cp -r bin lib node $out/libexec/codegraph/
    patchShebangs $out/libexec/codegraph/bin/codegraph

    makeWrapper $out/libexec/codegraph/bin/codegraph $out/bin/codegraph \
      --set CODEGRAPH_NO_UPDATE_CHECK 1 \
      --prefix PATH : ${lib.makeBinPath [ coreutils ]}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Pre-indexed code knowledge graph and MCP server for coding agents";
    homepage = "https://github.com/colbymchenry/codegraph";
    changelog = "https://github.com/colbymchenry/codegraph/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "codegraph";
  };
})
