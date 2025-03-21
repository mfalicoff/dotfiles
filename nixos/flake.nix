{
  description = "Nix configuration for both NixOS and macOS";

  nixConfig = {
    substituters = [
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    # Nixpkgs for different systems
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Linux-specific inputs
    hyprland.url = "github:hyprwm/Hyprland";

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shared inputs
    stylix.url = "github:danth/stylix";

    # System-specific home-manager versions
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
    nix-std.url = "github:chessai/nix-std";

    # macOS specific
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-darwin,
    darwin,
    home-manager,
    home-manager-darwin,
    nix-std,
    nvf,
    ...
  }: let
    # Shared variables
    username = "mazilious";
    useremail = "mfalicoff2001@gmail.com";
    darwinSystem = "aarch64-darwin";
    nixosHostname = "default";
    darwinHostname = "fearful";
    isDarwin = system: (builtins.elem system ["aarch64-darwin" "x86_64-darwin"]);

    # Shared special args
    sharedSpecialArgs = {
      inherit username useremail;
      inherit inputs;
      inherit isDarwin;
    };
  in {
    # NixOS configuration
    nixosConfigurations.${nixosHostname} = nixpkgs.lib.nixosSystem {
      specialArgs = sharedSpecialArgs;
      system = "x86_64-linux";
      modules = [
        inputs.stylix.nixosModules.stylix
        ./hosts/default/nix-core.nix
        ./hosts/default/system.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = sharedSpecialArgs;
          home-manager.users.${username} = import ./hosts/default/home.nix;
        }
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
      ];
    };

    # Darwin configuration
    darwinConfigurations.${darwinHostname} = darwin.lib.darwinSystem {
      system = darwinSystem;
      specialArgs = sharedSpecialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        # home manager
        home-manager-darwin.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = sharedSpecialArgs;
          home-manager.users.${username} = import ./home;
        }
      ];
    };

    # Formatter
    formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.alejandra;
  };
}
