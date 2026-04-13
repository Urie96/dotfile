let
  inherit (import "${builtins.getEnv "HOME"}/nix" { }) pkgs;

  python-with-pkg = pkgs.python3.withPackages (ps: with ps; [ mitmproxy ]);
in

pkgs.mkShellNoCC {
  packages = [ python-with-pkg ];
}
