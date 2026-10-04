{
  description = "Development environment with .NET 9 and Node.js 23";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # .NET SDK 9
            dotnet-sdk_9

            # Node.js 23 with npm
            nodejs_23
          ];

          shellHook = ''
            echo ".NET 9 and Node.js 23 development environment"
            echo "-------------------------------------------"
            echo ".NET version: $(dotnet --version)"
            echo "Node.js version: $(node --version)"
            echo "npm version: $(npm --version)"
            echo "-------------------------------------------"
            echo "Environment ready!"
          '';

          # Set up environment variables
          DOTNET_ROOT = "${pkgs.dotnet-sdk_9}";
          # Enable .NET telemetry opt-out
          DOTNET_CLI_TELEMETRY_OPTOUT = 1;
        };
      }
    );
}
