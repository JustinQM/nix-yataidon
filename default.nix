{ lib
, stdenv
, cmake
, ninja
, pkg-config
, makeWrapper
, srcs
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
    makeWrapper
  ];

  buildInputs =
  [
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
  ];

  cmakeFlags =
  [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DFETCHCONTENT_SOURCE_DIR_SDL3=${srcs.sdl3}"
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
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/yataidon $out/bin
    cp bin/YataiDON $out/share/yataidon/
    cp -r $src/shader $out/share/yataidon/
    cp -r $src/Songs $out/share/yataidon/ 2>/dev/null || mkdir -p $out/share/yataidon/Songs
    cp $src/config.toml $out/share/yataidon/

    makeWrapper $out/share/yataidon/YataiDON $out/bin/yataidon \
      --run 'cd "''${YATAIDON_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/yataidon}"'

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
