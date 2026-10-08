import ./support.nix {
  name = "terraform";
  description = "Terraform development tools";
  packages = pkgs: [pkgs.terraform pkgs.terraform-ls pkgs.tflint];
  vscodeExtensions = pkgs: {terraform = pkgs.vscode-extensions.hashicorp.terraform;};
  zedExtensions = {
    terraform = "terraform";
    tflint = "tflint";
  };
  zedPackages = pkgs: [pkgs.terraform pkgs.terraform-ls pkgs.tflint];
  zedSettings = pkgs: {
    languages = let
      terraform = {
        language_servers = ["terraform-ls" "tflint" "..."];
        format_on_save = "on";
        formatter.external = {
          command = "terraform";
          arguments = ["fmt" "-"];
        };
        tab_size = 2;
      };
    in {
      Terraform = terraform;
      "Terraform Vars" = terraform;
    };
    lsp = {
      terraform-ls = {
        binary = {
          path = pkgs.lib.getExe pkgs.terraform-ls;
          arguments = ["serve"];
        };
        # terraform-ls resolves local and `terraform init`-fetched modules itself,
        # giving cross-module go-to-definition, completion, and validation.
        initialization_options = {
          ignoreSingleFileWarning = true;
          experimentalFeatures = {
            prefillRequiredFields = true;
            validateOnSave = true;
          };
        };
      };
      tflint.binary = {
        path = pkgs.lib.getExe pkgs.tflint;
        arguments = ["--langserver"];
      };
    };
  };
  neovimServers = ["terraformls" "tflint"];
  neovimGrammars = ["terraform" "hcl"];
  neovimFormatters = {
    terraform = ["terraform_fmt"];
    terraform-vars = ["terraform_fmt"];
    hcl = ["terraform_fmt"];
  };
}
