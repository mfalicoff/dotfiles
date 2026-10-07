# Language integrations evaluated against the repository's locked inputs.
{inputs}: let
  inherit (inputs.nixpkgs) lib;
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  home = settings:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        inputs.nixvim.homeModules.nixvim
        ../nix/nixos/modules/home/development
        {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "24.11";
        }
        settings
      ];
    }).config;
  editors = {
    enable = true;
    vscode.enable = true;
    zed.enable = true;
    neovim.enable = true;
  };
  extensionIds = c: map (p: lib.toLower p.vscodeExtUniqueId) c.programs.vscode.profiles.default.extensions;
  packages = c: map lib.getName c.home.packages;
  bare = home {
    development = {
      enable = true;
      inherit editors;
    };
  };
  dotnet = home {
    development = {
      enable = true;
      inherit editors;
      languages.dotnet.enable = true;
    };
  };
  languagesOnly = home {
    development = {
      enable = true;
      languages.dotnet.enable = true;
    };
  };
  editorsDisabled = home {
    development = {
      enable = true;
      editors = editors // {enable = false;};
      languages.dotnet.enable = true;
    };
  };
  disabledDevelopment = home {
    development = {
      inherit editors;
      languages.dotnet = {
        enable = true;
        rider.enable = true;
      };
    };
  };
  disabledLanguage = home {
    development = {
      enable = true;
      inherit editors;
      languages.dotnet.rider.enable = true;
    };
  };
  overrides = home {
    development = {
      enable = true;
      languages = {
        dotnet.enable = true;
        elixir.enable = true;
      };
      editors = lib.recursiveUpdate editors {
        vscode.extensions.csharp = false;
        vscode.extensions.csharpier = false;
        zed.extensions.csharp = false;
        zed.advanced.settings.languages.Elixir.format_on_save = "off";
      };
    };
    programs.nixvim.plugins.lsp.servers.csharp_ls.enable = false;
    programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.cs = [];
  };
  languageNames = ["c" "python" "dotnet" "javascript" "java" "go" "php" "ruby" "sql" "zig" "elixir"];
  allLanguages = home {
    development = {
      enable = true;
      inherit editors;
      nix.enable = true;
      languages = lib.genAttrs languageNames (_: {enable = true;});
    };
  };
  ideChoices = {
    c = "clion";
    python = "pycharm";
    dotnet = "rider";
    javascript = "webstorm";
    java = "intellij";
    go = "goland";
    php = "phpstorm";
    ruby = "rubymine";
    sql = "datagrip";
  };
  idePackages = {
    c = pkgs.jetbrains.clion;
    python = pkgs.jetbrains.pycharm;
    dotnet = pkgs.jetbrains.rider;
    javascript = pkgs.jetbrains.webstorm;
    java = pkgs.jetbrains.idea;
    go = pkgs.jetbrains.goland;
    php = pkgs.jetbrains.phpstorm;
    ruby = pkgs.jetbrains.ruby-mine;
    sql = pkgs.jetbrains.datagrip;
  };
  idesOnly = home {
    development = {
      enable = true;
      languages =
        lib.mapAttrs (_: ide: {
          enable = true;
          ${ide}.enable = true;
        })
        ideChoices;
    };
  };
  checks = {
    dotnetAutomaticallyConfiguresEditors =
      builtins.elem "ms-dotnettools.csharp" (extensionIds dotnet)
      && builtins.elem "csharpier.csharpier-vscode" (extensionIds dotnet)
      && builtins.elem "csharp" dotnet.programs.zed-editor.extensions
      && dotnet.programs.nixvim.plugins.lsp.servers.csharp_ls.enable
      && builtins.elem "c_sharp" dotnet.programs.nixvim.plugins.treesitter.settings.ensure_installed;
    editorsDoNotSelectLanguages =
      !(builtins.elem "ms-dotnettools.csharp" (extensionIds bare))
      && !(builtins.elem "csharp" bare.programs.zed-editor.extensions)
      && !bare.programs.nixvim.plugins.lsp.servers.csharp_ls.enable
      && !bare.programs.nixvim.plugins.lsp.servers.nixd.enable;
    languageDoesNotEnableEditors =
      !languagesOnly.programs.vscode.enable
      && !languagesOnly.programs.zed-editor.enable
      && !languagesOnly.programs.nixvim.enable;
    languagesRespectEditorsParent =
      !editorsDisabled.programs.vscode.enable
      && editorsDisabled.programs.vscode.profiles == {}
      && editorsDisabled.programs.zed-editor.extensions == []
      && !editorsDisabled.programs.nixvim.plugins.lsp.servers.csharp_ls.enable;
    languagesRespectDevelopmentParent =
      !disabledDevelopment.programs.vscode.enable
      && !(builtins.elem (lib.getName pkgs.jetbrains.rider) (packages disabledDevelopment));
    idesRespectLanguageParent =
      !(builtins.elem (lib.getName pkgs.jetbrains.rider) (packages disabledLanguage));
    languageEnableDoesNotSelectJetbrains =
      !(builtins.elem (lib.getName pkgs.jetbrains.rider) (packages dotnet));
    extensionAndServerOverridesWork =
      !(builtins.elem "ms-dotnettools.csharp" (extensionIds overrides))
      && !(builtins.elem "csharpier.csharpier-vscode" (extensionIds overrides))
      && !(builtins.elem "csharp" overrides.programs.zed-editor.extensions)
      && !overrides.programs.nixvim.plugins.lsp.servers.csharp_ls.enable;
    advancedZedSettingsOverrideLanguageDefaults =
      overrides.programs.zed-editor.userSettings.languages.Elixir.format_on_save == "off";
    languageFormattersRespectSelection =
      dotnet.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.cs
      == ["csharpier"]
      && !(bare.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft ? cs)
      && !(editorsDisabled.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft ? cs)
      && !(languagesOnly.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft ? cs);
    languageFormatterOverridesWork =
      overrides.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.cs
      == []
      && overrides.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.elixir == ["mix"];
    allLanguagesSupplyFormatters =
      builtins.all (ft: allLanguages.programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft.${ft} != [])
      ["c" "cpp" "python" "cs" "javascript" "typescript" "java" "go" "php" "ruby" "sql" "zig" "elixir" "heex" "nix"];
    allLanguagesSupplyVscodeSupport = builtins.all (id: builtins.elem id (extensionIds allLanguages)) [
      "llvm-vs-code-extensions.vscode-clangd"
      "ms-python.python"
      "ms-python.vscode-pylance"
      "dbaeumer.vscode-eslint"
      "redhat.java"
      "golang.go"
      "bmewburn.vscode-intelephense-client"
      "shopify.ruby-lsp"
      "inferrinizzard.prettier-sql-vscode"
      "ziglang.vscode-zig"
      "jakebecker.elixir-ls"
      "jnoortheen.nix-ide"
    ];
    allLanguagesSupplyZedExtensions =
      builtins.all (id: builtins.elem id allLanguages.programs.zed-editor.extensions)
      ["csharp" "java" "php" "ruby" "sql" "zig" "elixir" "nix"];
    allLanguagesSupplyNeovimServers =
      builtins.all (server: allLanguages.programs.nixvim.plugins.lsp.servers.${server}.enable)
      ["clangd" "pyright" "csharp_ls" "ts_ls" "html" "cssls" "jdtls" "gopls" "phpactor" "ruby_lsp" "sqls" "zls" "elixirls" "nixd"];
    allLanguagesProduceEditorConfigurations =
      (builtins.toJSON allLanguages.programs.zed-editor.userSettings)
      != ""
      && allLanguages.programs.nixvim.build.package.drvPath != "";
    jetbrainsBelongsToLanguages =
      builtins.all (p: builtins.elem (lib.getName p) (packages idesOnly)) (builtins.attrValues idePackages)
      && !idesOnly.programs.vscode.enable
      && !idesOnly.programs.zed-editor.enable;
  };
in
  lib.mapAttrs (
    name: passed:
      assert lib.assertMsg passed "Development regression: ${name}"; passed
  )
  checks
