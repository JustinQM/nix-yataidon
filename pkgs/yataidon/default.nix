{ lib
, stdenv
, fetchgit
, cmake
, ninja
, pkg-config
, python3
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, git
, git-lfs
, cacert
, srcs
, version
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
, openssl
, curl
}:

let
    pytaikogreen = stdenv.mkDerivation
    {
        name = "PyTaikoGreen-d4c694a";

        nativeBuildInputs =
        [
            git
            git-lfs
            cacert
        ];

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-nWjMsW4x02f2SZq+EzXUoPu6q71Bjg5DbWy9anyYoV0=";

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        buildCommand = ''
            export HOME=$TMPDIR
            export GIT_LFS_SKIP_SMUDGE=1

            git -c http.sslVerify=false clone \
                --single-branch --branch main \
                https://ese.tjadataba.se/Yonokid/PyTaikoGreen.git repo

            cd repo
            git config http.sslVerify false
            git checkout d4c694a61a23aa4ff157cb4409b58c45e3582b41
            git lfs install --local
            git lfs pull
            rm -rf .git
            cd ..

            mv repo $out
        '';
    };
in
stdenv.mkDerivation
{
    pname = "yataidon";
    inherit version;

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
        openssl
        curl
    ];

    postUnpack = ''
        chmod -R u+w "$sourceRoot"
        rm -rf "$sourceRoot/Skins"
        mkdir -p "$sourceRoot/Skins"

        cp -r --no-preserve=mode ${pytaikogreen} "$sourceRoot/Skins/PyTaikoGreen"

        ${lib.concatStringsSep "\n" (lib.mapAttrsToList
            (name: src: ''cp -r --no-preserve=mode ${src} "$sourceRoot/Skins/${name}"'')
            srcs.skins)}

        if [ ! -f "$sourceRoot/Skins/PyTaikoGreen/Graphics/skin_config.json" ]; then
            echo "Skins/PyTaikoGreen/Graphics/skin_config.json is missing" >&2
            exit 1
        fi

        stubs=$(find "$sourceRoot/Skins" -type f -size -1k \
            -exec grep -l 'git-lfs.github.com' {} + 2>/dev/null | wc -l)
        if [ "$stubs" != 0 ]; then
            echo "$stubs unresolved Git LFS pointers in Skins — the media is missing" >&2
            exit 1
        fi

        echo "skins: $(ls "$sourceRoot/Skins" | tr '\n' ' ')"
    '';

    cmakeFlags =
    [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DNETWORK_URL=https://127.0.0.1"
        "-DNETWORK_AUTH_KEY=disabled"
        "-DCPR_USE_SYSTEM_CURL=ON"
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
        "-DFETCHCONTENT_SOURCE_DIR_LIBG719=${srcs.libg719}"
        "-DFETCHCONTENT_SOURCE_DIR_CPR=${srcs.cpr}"
        "-DFETCHCONTENT_SOURCE_DIR_MINIZ=${srcs.miniz}"
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
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
        description = "Taiko no Tatsujin simulator with gen 4 (shinuchi) scoring";
        homepage = "https://github.com/Yonokid/YataiDON";
        platforms = [ "x86_64-linux" ];
        mainProgram = "yataidon";
    };
}
