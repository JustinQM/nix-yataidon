{ lib
, stdenv
, fetchurl
, unzip
, autoPatchelfHook
, copyDesktopItems
, makeDesktopItem
, alsa-lib
, libjack2
, libpulseaudio
, sqlite
, libX11
, libxcb
, libGL
, libXcursor
, libXrandr
, libXi
, libXScrnSaver
, libXtst
, wayland
, libxkbcommon
, libdecor
, pipewire
, vulkan-loader
, libusb1
}:

let
    release = lib.importJSON ./release.json;

    logo = fetchurl
    {
        url = "https://raw.githubusercontent.com/Yonokid/YataiDON/9b9886ba200edb57c179b1db0b902b245ebd097e/docs/logo.png";
        hash = "sha256-TjbagoilaCDYuwZqXPKfXDZ+liojBAw0xpAu6yFWLIY=";
    };
in
stdenv.mkDerivation
{
    pname = "yataidon";
    inherit (release) version;

    src = fetchurl
    {
        url = "https://github.com/Yonokid/YataiDON/releases/download/latest/YataiDON-Linux.zip";
        inherit (release) hash;
    };

    sourceRoot = ".";

    nativeBuildInputs =
    [
        unzip
        autoPatchelfHook
        copyDesktopItems
    ];

    buildInputs =
    [
        stdenv.cc.cc.lib
        alsa-lib
        libjack2
        libpulseaudio
        sqlite
        libX11
        libxcb
        libGL
        libXcursor
        libXrandr
        libXi
        libXScrnSaver
        libXtst
        wayland
        libxkbcommon
        libdecor
        pipewire
        vulkan-loader
        libusb1
    ];

    autoPatchelfIgnoreMissingDeps =
    [
        "libGLES_CM.so.1"
        "libopenxr_loader.so.1"
        "libsndio.so.7"
        "libsteam_api.so"
    ];

    dontConfigure = true;
    dontBuild = true;

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

        cp -r YataiDON lib shader Skins Songs $out/share/yataidon/
        chmod +x $out/share/yataidon/YataiDON

        install -Dm644 ${logo} $out/share/icons/hicolor/512x512/apps/yataidon.png

        substitute ${./launcher.sh} $out/bin/yataidon --subst-var out
        chmod +x $out/bin/yataidon

        runHook postInstall
    '';

    meta =
    {
        description = "Taiko no Tatsujin simulator with gen 4 (shinuchi) scoring";
        homepage = "https://github.com/Yonokid/YataiDON";
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
        mainProgram = "yataidon";
    };
}
