{ pkgs, ... }:
{
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # single-user official installer does not enable flakes by default; enable declaratively.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.packages = [
    # Add CLIs here, e.g. pkgs.ripgrep pkgs.fd pkgs.jq
  ];
}
