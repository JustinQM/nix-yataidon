{
    description = "YataiDON packaged for NixOS";

    inputs =
    {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
    {
        systems = [ "x86_64-linux" ];

        flake.overlays.default = final: prev:
        {
            yataidon = final.callPackage ./pkgs/yataidon { };
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
                    git
                    jujutsu
                ];
            };
        };
    };
}
