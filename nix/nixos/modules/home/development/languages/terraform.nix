let
  tools = pkgs: [pkgs.terraform pkgs.terraform-ls pkgs.tflint];
  # Cost and security scanners; Zed only needs the language servers above.
  scanners = pkgs: [pkgs.infracost pkgs.tfsec];

  zedLanguage = {
    language_servers = ["terraform-ls" "tflint" "..."];
    format_on_save = "on";
    formatter.external = {
      command = "terraform";
      arguments = ["fmt" "-"];
    };
    tab_size = 2;
  };
in
  import ./support.nix {
    name = "terraform";
    description = "Terraform development tools";
    packages = pkgs: tools pkgs ++ scanners pkgs;
    vscodeExtensions = pkgs: {terraform = pkgs.vscode-extensions.hashicorp.terraform;};
    zedExtensions = {
      terraform = "terraform";
      tflint = "tflint";
    };
    zedPackages = tools;
    zedSettings = pkgs: {
      languages = {
        Terraform = zedLanguage;
        "Terraform Vars" = zedLanguage;
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
