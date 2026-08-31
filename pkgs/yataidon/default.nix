{ lib
, stdenv
, cmake
, ninja
, pkg-config
, python3
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, srcs
, sdl3
, libGL
, libX11
, libXrandr
, libXinerama
, libXcursor
, libXi
, libXtst
, alsa-lib
, libpulseaudio
, libjack2
, lua5_4
, ffmpeg
, libogg
, libvorbis
, flac
, libopus
, lame
, mpg123
, speex
, libsamplerate
, sqlite
, elfutils
, libdwarf
, zstd
}:

stdenv.mkDerivation
{
  pname = "yataidon";
  version = "1.1.0";

  src = srcs.yataidon;

  nativeBuildInputs =
  [
    cmake
    ninja
    pkg-config
    python3
    makeWrapper
    copyDesktopItems
  ];

  buildInputs =
  [
    sdl3
    libGL
    libX11
    libXrandr
    libXinerama
    libXcursor
    libXi
    libXtst
    alsa-lib
    libpulseaudio
    libjack2
    lua5_4
    ffmpeg
    libogg
    libvorbis
    flac
    libopus
    lame
    mpg123
    speex
    libsamplerate
    sqlite
    elfutils
    libdwarf
    zstd
  ];

  # The skins are git submodules hosted on TJADB's gitea. codegen.cmake
  # reads PyTaikoGreen's skin_config.json to generate a header, so they
  # are a build-time requirement, not just runtime assets.
  postUnpack = ''
    chmod -R u+w "$sourceRoot"
    rm -rf "$sourceRoot/Skins"
    mkdir -p "$sourceRoot/Skins"
    cp -r --no-preserve=mode ${srcs.pytaikogreen} "$sourceRoot/Skins/PyTaikoGreen"
    cp -r --no-preserve=mode ${srcs.yataidonred}  "$sourceRoot/Skins/YataiDONRed"
    cp -r --no-preserve=mode ${srcs.yataidonhss}  "$sourceRoot/Skins/YataiDON-HSS"
  '';

  cmakeFlags =
  [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON"
    "-DCPPTRACE_FIND_LIBDWARF_WITH_PKGCONFIG=ON"
    "-DCPPTRACE_USE_EXTERNAL_ZSTD=ON"
    "-DFETCHCONTENT_SOURCE_DIR_RAYLIB=${srcs.raylib}"
    "-DFETCHCONTENT_SOURCE_DIR_RAPIDJSON=${srcs.rapidjson}"
    "-DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=${srcs.tomlplusplus}"
    "-DFETCHCONTENT_SOURCE_DIR_SPDLOG=${srcs.spdlog}"
    "-DFETCHCONTENT_SOURCE_DIR_LUA=${srcs.lua}"
    "-DFETCHCONTENT_SOURCE_DIR_SOL2=${srcs.sol2}"
    "-DFETCHCONTENT_SOURCE_DIR_CPPTRACE=${srcs.cpptrace}"
    "-DFETCHCONTENT_SOURCE_DIR_LIBSNDFILE=${srcs.libsndfile}"
    "-DFETCHCONTENT_SOURCE_DIR_RTAUDIO=${srcs.rtaudio}"
  ];

  desktopItems =
  [
    (makeDesktopItem
    {
      name = "yataidon";
      exec = "yataidon";
      icon = "yataidon";
      desktopName = "YataiDON";
      genericName = "Rhythm Game";
      comment = "Taiko no Tatsujin simulator";
      categories = [ "Game" "ArcadeGame" ];
      keywords = [ "taiko" "rhythm" "tja" "drum" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/yataidon $out/bin

    cp bin/YataiDON $out/share/yataidon/
    cp -r ../shader $out/share/yataidon/
    cp -r ../Skins $out/share/yataidon/
    cp ../config.toml $out/share/yataidon/

    if [ -d ../Songs ]; then
      cp -r ../Songs $out/share/yataidon/
    else
      mkdir -p $out/share/yataidon/Songs
    fi

    if [ -f ../docs/logo.png ]; then
      install -Dm644 ../docs/logo.png \
        $out/share/icons/hicolor/512x512/apps/yataidon.png
    fi

    substitute ${./launcher.sh} $out/bin/yataidon --subst-var out
    chmod +x $out/bin/yataidon

    runHook postInstall
  '';

  meta =
  {
    description = "Taiko no Tatsujin simulator based on the gen 3 arcade version";
    homepage = "https://github.com/Yonokid/YataiDON";
    platforms = [ "x86_64-linux" ];
    mainProgram = "yataidon";
  };
}
