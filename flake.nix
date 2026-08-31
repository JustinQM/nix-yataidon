{
  description = "YataiDON packaged for NixOS";

  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    yataidon-src =
    {
      url = "github:Yonokid/YataiDON";
      flake = false;
    };

    sdl3-src =
    {
      url = "github:libsdl-org/SDL/release-3.4.4";
      flake = false;
    };
    raylib-src =
    {
      url = "github:raysan5/raylib";
      flake = false;
    };
    rapidjson-src =
    {
      url = "github:Tencent/rapidjson";
      flake = false;
    };
    tomlplusplus-src =
    {
      url = "github:marzer/tomlplusplus/v3.4.0";
      flake = false;
    };
    spdlog-src =
    {
      url = "github:gabime/spdlog/v1.15.1";
      flake = false;
    };
    lua-src =
    {
      url = "github:marovira/lua/5.4.8";
      flake = false;
    };
    sol2-src =
    {
      url = "github:ThePhD/sol2/v3.5.0";
      flake = false;
    };
    cpptrace-src =
    {
      url = "github:jeremy-rifkin/cpptrace";
      flake = false;
    };
    libsndfile-src =
    {
      url = "github:libsndfile/libsndfile";
      flake = false;
    };
    rtaudio-src =
    {
      url = "github:thestk/rtaudio/6.0.1";
      flake = false;
    };
    portaudio-src =
    {
      url = "github:PortAudio/portaudio/b0fe9de7ec86ebe5a26086f1d662ab74d7ebfae4";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
    {
      systems = [ "x86_64-linux" ];

      flake.overlays.default = final: prev:
      {
        yataidon = final.callPackage ./pkgs/yataidon
        {
          srcs =
          {
            yataidon     = inputs.yataidon-src;
            sdl3         = inputs.sdl3-src;
            raylib       = inputs.raylib-src;
            rapidjson    = inputs.rapidjson-src;
            tomlplusplus = inputs.tomlplusplus-src;
            spdlog       = inputs.spdlog-src;
            lua          = inputs.lua-src;
            sol2         = inputs.sol2-src;
            cpptrace     = inputs.cpptrace-src;
            libsndfile   = inputs.libsndfile-src;
            rtaudio      = inputs.rtaudio-src;
            portaudio    = inputs.portaudio-src;
          };
        };
      };

      perSystem = { system, ... }:
      let
        pkgs = import inputs.nixpkgs
        {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
        };
      in
      {
        _module.args.pkgs = pkgs;

        packages =
        {
          inherit (pkgs) yataidon;
          default = pkgs.yataidon;
        };

        devShells.default = pkgs.mkShell
        {
          packages = with pkgs;
          [
            cmake
            ninja
            pkg-config
            git
            jujutsu
          ];
        };
      };
    };
}
