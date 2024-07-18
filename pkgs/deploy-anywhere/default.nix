{
  stdenv,
  makeWrapper,
  lib,
  bash,
  nixos-anywhere,
  agenix,
}:
stdenv.mkDerivation rec {
  name = "deploy-anywhere";
  src = ./.;

  buildInputs = [bash nixos-anywhere agenix];
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    mkdir -p $out/bin
    cp ${name}.sh $out/bin/${name}
    chmod +x $out/bin/${name}
    wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath buildInputs}
  '';
}