{ lib
, rustPlatform
, fetchFromGitHub
, fetchpatch
, testers
, difftastic
}:

rustPlatform.buildRustPackage rec {
  pname = "difftastic";
  version = "0.43.0";

  src = fetchFromGitHub {
    owner = "wilfred";
    repo = pname;
    rev = version;
    sha256 = "sha256-YL2rKsP5FSoG1gIyxQtt9kovBAyu8Flko5RxXRQy5mQ=";
  };

  depsExtraArgs = {
    postBuild = let
      mimallocPatch = fetchpatch {
        name = "mimalloc-older-macos-fixes.patch";
        url = "https://github.com/microsoft/mimalloc/commit/40e0507a5959ee218f308d33aec212c3ebeef3bb.patch";
        stripLen = 1;
        extraPrefix = "libmimalloc-sys/c_src/mimalloc/";
        sha256 = "1cqgay6ayzxsj8v1dy8405kwd8av34m4bjc84iyg9r52amlijbg4";
      };
    in ''
      pushd $name
      patch -p1 < ${mimallocPatch}
      substituteInPlace libmimalloc-sys/.cargo-checksum.json \
        --replace \
          '6a2e9f0db0d3de160f9f15ddc8a870dbc42bba724f19f1e69b8c4952cb36821a' \
          '201ab8874d9ba863406e084888e492b785a7edae00a222f395c079028d21a89a' \
        --replace \
          'a87a27e8432a63e5de25703ff5025588afd458e3a573e51b3c3dee2281bff0d4' \
          'ab98a2da81d2145003a9cba7b7025efbd2c7b37c7a23c058c150705a3ec39298'
      popd
    '';
  };
  cargoSha256 = "sha256-SUNBnJP8B/HvlozcCbehL1A2/WudYE20DIPc7/fYF/k=";

  checkFlags = [
    # test is broken
    # https://github.com/Wilfred/difftastic/issues/479
    "--skip=files::tests::test_gzip_is_binary"
  ];

  passthru.tests.version = testers.testVersion { package = difftastic; };

  meta = with lib; {
    description = "A syntax-aware diff";
    homepage = "https://github.com/Wilfred/difftastic";
    changelog = "https://github.com/Wilfred/difftastic/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ethancedwards8 figsoda ];
    mainProgram = "difft";
  };
}
