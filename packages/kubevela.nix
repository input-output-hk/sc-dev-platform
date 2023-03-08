{ buildGoModule, fetchFromGitHub }:
buildGoModule {
  pname = "kubevela";
  version = "v1.7.4";
  src = fetchFromGitHub {
    owner = "kubevela";
    repo = "kubevela";
    rev = "v1.7.4";
    sha256 = "sha256-y9i23YpiN0LeygKUDJ/du+jnjA79i1buVamusdS+oUk=";
  };
  vendorHash = "sha256-pumANncR9/QV6EXqrCCe9vjJEumhZhk+vqMFU9cHQ7Y=";
  postInstall = ''
    cd $out/bin
    for f in * ; do mv -- "$f" "vela-$f" ; done
    cd -
  '';
  doCheck = false;
}
