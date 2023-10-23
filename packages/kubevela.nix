{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "kubevela";
  version = "v1.9.6";
  src = fetchFromGitHub {
    owner = "kubevela";
    repo = "kubevela";
    rev = "v1.9.6";
    sha256 = "sha256-eRlJP7TREtg/gDMDJUFuVwIIfyY40uFQA9Ua/o24hwg=";
  };
  vendorHash = "sha256-UOq3iHi9aJD0veYiz6THdLJhXhK0Y6hwoViC3ma2cqM=";
  postInstall = ''
    cd $out/bin
    for f in * ; do mv -- "$f" "vela-$f" ; done
    ln -s $out/bin/vela-cli $out/bin/vela
    cd -
  '';
  doCheck = false;
}
