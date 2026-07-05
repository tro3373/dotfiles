{
  description = "portable home-manager config (username-agnostic)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem;            # impure: needs --impure
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          {
            home.username = builtins.getEnv "USER";       # impure
            home.homeDirectory = builtins.getEnv "HOME";  # impure
          }
        ];
      };
    };
}
