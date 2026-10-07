{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.development.editors.neovim;
in {
  options.development.editors.neovim.enable = lib.mkEnableOption "Neovim";

  config = lib.mkIf (config.development.enable && config.development.editors.enable && cfg.enable) (lib.mkMerge [
    {
      programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        extraPackages = [pkgs.ripgrep pkgs.fd pkgs.git];
        globals = {
          mapleader = " ";
          maplocalleader = "\\";
          autoformat = true;
        };
        clipboard.register = "unnamedplus";
        opts = {
          number = true;
          relativenumber = true;
          termguicolors = true;
          cursorline = true;
          signcolumn = "yes";
          scrolloff = 4;
          sidescrolloff = 8;
          wrap = false;
          mouse = "a";
          tabstop = 2;
          shiftwidth = 2;
          softtabstop = 2;
          expandtab = true;
          smartindent = true;
          ignorecase = true;
          smartcase = true;
          splitbelow = true;
          splitright = true;
          splitkeep = "screen";
          undofile = true;
          updatetime = 200;
          timeoutlen = 300;
          completeopt = "menu,menuone,noselect";
          pumheight = 10;
          laststatus = 3;
          conceallevel = 2;
          inccommand = "nosplit";
          wildmode = "longest:full,full";
          fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldclose:";
          winborder = "rounded";
        };
        diagnostic.settings = {
          severity_sort = true;
          underline = true;
          update_in_insert = false;
          virtual_text = {
            spacing = 4;
            prefix = "●";
          };
          float.border = "rounded";
          signs.text.__raw = "{ [vim.diagnostic.severity.ERROR] = ' ', [vim.diagnostic.severity.WARN] = ' ', [vim.diagnostic.severity.INFO] = ' ', [vim.diagnostic.severity.HINT] = '󰌵 ' }";
        };
        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "mocha";
            transparent_background = false;
            show_end_of_buffer = false;
            styles = {
              comments = ["italic"];
              keywords = ["italic"];
            };
            custom_highlights.__raw = ''
              function(c)
                return {
                  NormalFloat = { bg = c.mantle },
                  FloatBorder = { fg = c.surface2, bg = c.mantle },
                  FloatTitle = { fg = c.lavender, bg = c.mantle, bold = true },
                  WinSeparator = { fg = c.surface0 },
                  CursorLineNr = { fg = c.lavender, bold = true },
                  SnacksDashboardHeader = { fg = c.lavender },
                  SnacksDashboardTitle = { fg = c.mauve, bold = true },
                  SnacksDashboardIcon = { fg = c.lavender },
                  SnacksDashboardKey = { fg = c.peach, bold = true },
                  SnacksDashboardDesc = { fg = c.text },
                  SnacksDashboardFooter = { fg = c.overlay1, italic = true },
                  SnacksIndent = { fg = c.surface0 },
                  SnacksIndentScope = { fg = c.lavender },
                  SnacksPickerBorder = { fg = c.surface2, bg = c.mantle },
                  SnacksPickerTitle = { fg = c.lavender, bold = true },
                  SnacksPickerMatch = { fg = c.peach, bold = true },
                  SnacksPickerDir = { fg = c.overlay1 },
                  BlinkCmpMenu = { bg = c.mantle },
                  BlinkCmpMenuBorder = { fg = c.surface2, bg = c.mantle },
                  BlinkCmpDoc = { bg = c.mantle },
                  BlinkCmpDocBorder = { fg = c.surface2, bg = c.mantle },
                }
              end
            '';
          };
          settings.integrations = {
            blink_cmp = true;
            gitsigns = true;
            treesitter = true;
            mini.enabled = true;
            native_lsp.enabled = true;
            which_key = true;
            noice = true;
            lualine = {
              mocha.__raw = "function(c) return { normal = { a = { bg = c.lavender }, b = { fg = c.lavender } } } end";
            };
            snacks.enabled = true;
            bufferline = true;
          };
        };
        plugins = {
          mini = {
            enable = true;
            mockDevIcons = true;
            modules = {
              icons = {};
              ai.n_lines = 500;
              pairs = {};
            };
          };
          lualine = {
            enable = true;
            settings = {
              options = {
                globalstatus = true;
                theme = "catppuccin-nvim";
                component_separators = {
                  left = "";
                  right = "";
                };
                section_separators = {
                  left = "";
                  right = "";
                };
                disabled_filetypes.statusline = ["snacks_dashboard"];
              };
              sections = {
                lualine_a = [
                  {
                    "__unkeyed-1" = "mode";
                    icon = "";
                  }
                ];
                lualine_b = [
                  {
                    "__unkeyed-1" = "branch";
                    icon = "";
                  }
                  "diff"
                ];
                lualine_c = [
                  {
                    "__unkeyed-1" = "filename";
                    path = 1;
                    symbols = {
                      modified = "●";
                      readonly = "";
                      unnamed = "Untitled";
                    };
                  }
                  {
                    "__unkeyed-1" = "diagnostics";
                    symbols = {
                      error = " ";
                      warn = " ";
                      info = " ";
                      hint = "󰌵 ";
                    };
                  }
                ];
                lualine_x = ["filetype"];
                lualine_y = ["progress"];
                lualine_z = ["location"];
              };
            };
          };
          bufferline = {
            enable = true;
            settings.highlights.__raw = "require('catppuccin.special.bufferline').get_theme()";
            settings.options = {
              diagnostics = "nvim_lsp";
              always_show_bufferline = false;
              show_close_icon = false;
              separator_style = "thin";
              indicator.style = "icon";
              modified_icon = "●";
              buffer_close_icon = "󰅖";
              offsets = [
                {
                  filetype = "snacks_layout_box";
                  text = "Explorer";
                  text_align = "left";
                }
              ];
            };
          };
          lsp = {
            enable = true;
            inlayHints = true;
            servers = {
              jsonls.enable = true;
              lua_ls = {
                enable = true;
                settings.Lua = {
                  diagnostics.globals = ["vim" "Snacks"];
                  workspace.checkThirdParty = false;
                  codeLens.enable = true;
                };
              };
            };
            # Buffer-local actions must not shadow file/explorer/window shortcuts.
            keymaps.lspBuf = {
              "<leader>ca" = {
                action = "code_action";
                desc = "Code Action";
              };
              "<leader>cr" = {
                action = "rename";
                desc = "Rename";
              };
              "gd" = {
                action = "definition";
                desc = "Goto Definition";
              };
              "gD" = {
                action = "declaration";
                desc = "Goto Declaration";
              };
              "gI" = {
                action = "implementation";
                desc = "Goto Implementation";
              };
              "gr" = {
                action = "references";
                desc = "References";
              };
              "gy" = {
                action = "type_definition";
                desc = "Goto Type Definition";
              };
              "K" = {
                action = "hover";
                desc = "Hover";
              };
              "gK" = {
                action = "signature_help";
                desc = "Signature Help";
              };
            };
          };
          blink-cmp = {
            enable = true;
            settings = {
              keymap = {
                preset = "enter";
                "<C-y>" = ["select_and_accept"];
                "<Tab>" = ["snippet_forward" "fallback"];
                "<S-Tab>" = ["snippet_backward" "fallback"];
              };
              appearance.nerd_font_variant = "mono";
              completion = {
                accept.auto_brackets.enabled = true;
                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 200;
                  window.border = "rounded";
                };
                menu.border = "rounded";
                menu.draw.treesitter = ["lsp"];
              };
              sources.default = ["lsp" "path" "snippets" "buffer"];
              snippets.preset = "default";
            };
          };
          friendly-snippets.enable = true;
          conform-nvim = {
            enable = true;
            # Resolve configured formatter binaries from Nix, rather than Mason.
            autoInstall.enable = true;
            settings = {
              default_format_opts = {
                lsp_format = "fallback";
                timeout_ms = 3000;
              };
              format_on_save = ''
                function(bufnr)
                  if not vim.g.autoformat or vim.b[bufnr].autoformat == false then
                    return
                  end
                  return { timeout_ms = 3000, lsp_format = "fallback" }
                end
              '';
              formatters_by_ft = {
                lua = ["stylua"];
                sh = ["shfmt"];
                bash = ["shfmt"];
                json = ["prettier"];
                jsonc = ["prettier"];
                yaml = ["prettier"];
                markdown = ["prettier"];
              };
            };
          };
          treesitter = {
            enable = true;
            nixGrammars = true;
            highlight.enable = true;
            indent.enable = true;
            settings.ensure_installed = ["json" "xml" "yaml" "markdown" "markdown_inline" "lua" "vim" "vimdoc" "regex" "bash"];
          };
          ts-comments.enable = true;
          flash.enable = true;
          gitsigns = {
            enable = true;
            settings.signs = {
              add.text = "▎";
              change.text = "▎";
              delete.text = "";
              topdelete.text = "";
              changedelete.text = "▎";
              untracked.text = "▎";
            };
          };
          trouble = {
            enable = true;
            settings = {
              auto_close = true;
              focus = false;
            };
          };
          persistence.enable = true;
          grug-far.enable = true;
          todo-comments.enable = true;
          noice = {
            enable = true;
            settings = {
              # Snacks owns vim.notify; Noice handles command-line and LSP UI.
              notify.enabled = false;
              lsp.override = {
                "vim.lsp.util.convert_input_to_markdown_lines" = true;
                "vim.lsp.util.stylize_markdown" = true;
              };
              presets = {
                bottom_search = true;
                command_palette = true;
                long_message_to_split = true;
              };
              views = {
                cmdline_popup.border.style = "rounded";
                popupmenu.border.style = "rounded";
                mini.win_options.winblend = 0;
              };
            };
          };
          snacks = {
            enable = true;
            settings = {
              bigfile.enabled = true;
              quickfile.enabled = true;
              picker = {
                enabled = true;
                layout = {
                  preset = "default";
                  layout = {
                    width = 0.85;
                    min_width = 80;
                    height = 0.8;
                  };
                };
                win = {
                  input.border = "rounded";
                  list.border = "rounded";
                  preview.border = "rounded";
                };
              };
              explorer.enabled = true;
              input.enabled = true;
              notifier = {
                enabled = true;
                style = "compact";
                timeout = 2500;
              };
              indent = {
                enabled = true;
                indent.char = "┊";
                scope.char = "│";
                animate.enabled = false;
              };
              scope.enabled = true;
              words.enabled = true;
              statuscolumn.enabled = true;
              dashboard = {
                enabled = true;
                width = 60;
                preset = {
                  header = ''
                    ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
                    ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
                    ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
                    ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
                    ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
                    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝ ╚═╝╚═╝     ╚═╝
                  '';
                  keys = [
                    {
                      icon = " ";
                      key = "f";
                      desc = "Find File";
                      action = ":lua Snacks.picker.files()";
                    }
                    {
                      icon = " ";
                      key = "n";
                      desc = "New File";
                      action = ":ene | startinsert";
                    }
                    {
                      icon = " ";
                      key = "g";
                      desc = "Find Text";
                      action = ":lua Snacks.picker.grep()";
                    }
                    {
                      icon = " ";
                      key = "r";
                      desc = "Recent Files";
                      action = ":lua Snacks.picker.recent()";
                    }
                    {
                      icon = " ";
                      key = "s";
                      desc = "Restore Session";
                      action = ":lua require('persistence').load()";
                    }
                    {
                      icon = " ";
                      key = "q";
                      desc = "Quit";
                      action = ":qa";
                    }
                  ];
                };
                sections = [
                  {
                    section = "header";
                    padding = 1;
                  }
                  {
                    text = "N E O V I M";
                    align = "center";
                    hl = "SnacksDashboardFooter";
                    padding = 1;
                  }
                  {
                    section = "keys";
                    gap = 1;
                    padding = 1;
                  }
                  {
                    section = "recent_files";
                    title = "Recent files";
                    icon = " ";
                    limit = 4;
                    indent = 2;
                    padding = 1;
                  }
                  {
                    text = "Space ff  ·  find files       Space ?  ·  shortcuts";
                    align = "center";
                    hl = "SnacksDashboardFooter";
                  }
                ];
              };
            };
          };
          which-key = {
            enable = true;
            settings = {
              preset = "helix";
              win.border = "rounded";
              spec =
                map (entry: {
                  "__unkeyed-1" = builtins.elemAt entry 0;
                  group = builtins.elemAt entry 1;
                }) [
                  ["<leader>b" "buffer"]
                  ["<leader>c" "code"]
                  ["<leader>f" "file/find"]
                  ["<leader>g" "git"]
                  ["<leader>gh" "hunks"]
                  ["<leader>q" "quit/session"]
                  ["<leader>s" "search"]
                  ["<leader>u" "ui"]
                  ["<leader>w" "windows"]
                  ["<leader>x" "diagnostics/quickfix"]
                  ["<leader><tab>" "tabs"]
                ];
            };
          };
        };
        extraConfigLua = builtins.readFile ./neovim/keymaps.lua;
      };
    }
    # Keep Stylix's base16 mini module from replacing Catppuccin's highlights.
    (lib.optionalAttrs (options ? stylix.targets.nixvim.enable) {
      stylix.targets.nixvim.enable = false;
    })
  ]);
}
