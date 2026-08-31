{ lib
, stdenv
, cmake
, ninja
, pkg-config
, python3
, makeWrapper
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

  cmakeFlags =
  [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DFETCHCONTENT_SOURCE_DIR_RAYLIB=${srcs.raylib}"
    "-DFETCHCONTENT_SOURCE_DIR_RAPIDJSON=${srcs.rapidjson}"
    "-DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=${srcs.tomlplusplus}"
    "-DFETCHCONTENT_SOURCE_DIR_SPDLOG=${srcs.spdlog}"
    "-DFETCHCONTENT_SOURCE_DIR_LUA=${srcs.lua}"
    "-DFETCHCONTENT_SOURCE_DIR_SOL2=${srcs.sol2}"
    "-DFETCHCONTENT_SOURCE_DIR_CPPTRACE=${srcs.cpptrace}"
    "-DFETCHCONTENT_SOURCE_DIR_LIBSNDFILE=${srcs.libsndfile}"
    "-DFETCHCONTENT_SOURCE_DIR_RTAUDIO=${srcs.rtaudio}"
    "-DFETCHCONTENT_SOURCE_DIR_PORTAUDIO=${srcs.portaudio}"
    "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON"
    "-DCPPTRACE_FIND_LIBDWARF_WITH_PKGCONFIG=ON"
    "-DCPPTRACE_USE_EXTERNAL_ZSTD=ON"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/yataidon $out/bin
    cp bin/YataiDON $out/share/yataidon/
    cp -r $src/shader $out/share/yataidon/
    cp $src/config.toml $out/share/yataidon/
    if [ -d $src/Songs ]; then
      cp -r $src/Songs $out/share/yataidon/
    else
      mkdir -p $out/share/yataidon/Songs
    fi

    makeWrapper $out/share/yataidon/YataiDON $out/bin/yataidon

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
