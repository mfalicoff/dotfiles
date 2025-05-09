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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Linux-specific inputs
    hyprland.url = "github:hyprwm/Hyprland";

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shared inputs
    stylix.url = "github:danth/stylix";
    base16.url = "github:SenchoPens/base16.nix";

    # System-specific home-manager versions
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-darwin = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    textfox.url = "github:adriankarlen/textfox";

    nix-std.url = "github:chessai/nix-std";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    home-manager-darwin,
    nix-std,
    nixvim,
    ...
  }: let
    # Shared variables
    username = "mazilious";
    useremail = "mfalicoff2001@gmail.com";
    darwinSystem = "aarch64-darwin";
    desktopHostname = "fear";
    laptopHostname = "laptop";
    darwinHostname = "fearful";
    isDarwin = system: (builtins.elem system ["aarch64-darwin" "x86_64-darwin"]);

    # Shared special args
    sharedSpecialArgs = {
      inherit username useremail desktopHostname darwinHostname laptopHostname;
      inherit inputs;
      inherit isDarwin;
    };
  in {
    # NixOS configuration
    nixosConfigurations.${desktopHostname} = nixpkgs.lib.nixosSystem {
      specialArgs = sharedSpecialArgs;
      system = "x86_64-linux";
      modules = [
        inputs.stylix.nixosModules.stylix
        ./nix-core.nix
        ./hosts/fear/system.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = sharedSpecialArgs;
          home-manager.users.${username} = import ./hosts/fear/home.nix;
        }
        {nixpkgs.overlays = [inputs.hyprpanel.overlay inputs.nur.overlays.default];}
      ];
    };

    nixosConfigurations.${laptopHostname} = nixpkgs.lib.nixosSystem {
      specialArgs = sharedSpecialArgs;
      system = "x86_64-linux";
      modules = [
        inputs.stylix.nixosModules.stylix
        ./nix-core.nix
        ./hosts/laptop/system.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = sharedSpecialArgs;
          home-manager.users.${username} = import ./hosts/laptop/home.nix;
        }
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
      ];
    };

    # Darwin configuration
    darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
      system = darwinSystem;
      specialArgs = sharedSpecialArgs;
      modules = [
        inputs.stylix.darwinModules.stylix
        ./nix-core.nix
        ./hosts/fearful/system.nix
        ./hosts/fearful/host-users.nix
        # home manager
        inputs.home-manager-darwin.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = sharedSpecialArgs;
          home-manager.users.${username} = import ./hosts/fearful/home.nix;
        }
      ];
    };
  };
}
