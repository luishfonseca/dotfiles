{self, ...} @ inputs: let
  system = "x86_64-linux";
  overlays = lib.my.mkOverlays ./overlays;
  pkgs = lib.my.mkPkgs overlays;
  lib = inputs.nixpkgs.lib.extend (final: prev:
    import ./lib {
      inherit inputs pkgs system;
      lib = final;
    });

  # Primary user account
  user = "luis";

  nixosConfigurations = lib.my.mkHosts {
    modulesDir = ./modules;
    profilesDir = ./profiles;
    hostsDir = ./hosts;
    extraArgs = {
      inherit user system inputs nixosConfigurations;
      root = ./.;
    };
    extraModules = [
      inputs.impermanence.nixosModules.impermanence
      inputs.home-manager.nixosModules.home-manager
      inputs.programs-sqlite.nixosModules.programs-sqlite
      inputs.kmonad.nixosModules.default
      inputs.nixos-mailserver.nixosModule
    ];
  };
in {
  inherit nixosConfigurations overlays;

  deploy.nodes =
    lib.mapAttrs
    (host: config: {
      hostname = host;
      fastConnection = true;
      sshOpts = ["-A"];
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos config;
      };
    })
    nixosConfigurations;

  checks = lib.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;

  legacyPackages.${system} = pkgs // {inherit lib;};

  devShells.${system}.default = pkgs.mkShell {
    buildInputs = [
      inputs.deploy-rs.defaultPackage.${system}
      inputs.agenix.packages.${system}.agenix
    ];
  };

  formatter.${system} = pkgs.alejandra;
}
