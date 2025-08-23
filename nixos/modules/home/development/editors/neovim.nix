{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.development.editors.neovim;
in
{
  options.development.editors.neovim = {
    enable = mkEnableOption "Enable Neovim";
  };

  config = mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      # Basic vim options
      viAlias = true;
      vimAlias = true;

      # # General settings
      # clipboard.register = "unnamedplus";
      # mouse = "a";
      # updatetime = 100;
      # swapfile = false;
      # undofile = true;
      # completeopt = ["menu" "menuone" "noselect"];

      # # UI settings
      opts = {
        number = true; # Show line numbers
        relativenumber = true; # Show relative line numbers
        shiftwidth = 2; # Tab width should be 2
        termguicolors = true;
      };
      # relativenumber = true;
      # cursorline = true;
      # signcolumn = "yes";
      # colorcolumn = ["80" "120"];
      # scrolloff = 8;
      # wrap = false;

      # # Tab settings
      # tabstop = 4;
      # shiftwidth = 4;
      # expandtab = true;
      # autoindent = true;
      # smartindent = true;

      # # Search settings
      # hlsearch = true;
      # ignorecase = true;
      # smartcase = true;

      # # Split settings
      # splitbelow = true;
      # splitright = true;

      # # Backup settings
      # backup = false;
      # writebackup = false;

      # Global options
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      # Theme
      colorschemes.catppuccin = {
        enable = true;
        settings = {
          integrations = {
            cmp = true;
            gitsigns = true;
            nvimtree = true;
            treesitter = true;
            notify = true;
            mini.enabled = true;
            native_lsp.enabled = true;
            telescope.enabled = true;
            which_key = true;
          };
        };
      };

      # # Essential plugins
      plugins = {
        # Lua line - status line
        lualine = {
          enable = true;
          settings = {
            options = {
              globalstatus = true;
              theme = "catppuccin";
            };
            sections = {
              lualine_a = [ "mode" ];
              lualine_b = [
                "branch"
                "diff"
              ];
              lualine_c = [
                {
                  filename = {
                    path = 1;
                  };
                }
              ];
              lualine_x = [
                "encoding"
                "fileformat"
                "filetype"
              ];
              lualine_y = [ "progress" ];
              lualine_z = [ "location" ];
            };
          };
        };

        mini = {
          enable = true;
          modules.icons = { };
          mockDevIcons = true;
        };

        # LSP
        lsp = {
          enable = true;
          inlayHints = false;
          servers = {
            csharp_ls.enable = true;
            nixd.enable = true;
            html.enable = true;
            cssls.enable = true;
            jsonls.enable = true;
            lua_ls.enable = true;
          };

          # LSP Keymaps
          keymaps = {
            lspBuf = {
              "<leader>ca" = "code_action";
              "<leader>cr" = "rename";
              "gd" = "definition";
              "gD" = "declaration";
              "gi" = "implementation";
              "gr" = "references";
              "K" = "hover";
              "<C-k>" = "signature_help";
              "<leader>D" = "type_definition";
              "<leader>ff" = "format";
            };
            diagnostic = {
              "<leader>e" = "open_float";
              "[d" = "goto_prev";
              "]d" = "goto_next";
              "<leader>q" = "setloclist";
            };
          };
        };

        # LSP handlers
        lsp-format.enable = true;

        # LSP UI improvements
        lspkind = {
          enable = true;
          settings = {
            cmp = {
              enable = true;
              menu = {
                nvim_lsp = "[LSP]";
                nvim_lua = "[Lua]";
                path = "[Path]";
                luasnip = "[Snippet]";
                buffer = "[Buffer]";
              };
            };
          };
        };

        # Completions
        cmp = {
          enable = true;
          settings = {
            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-e>" = "cmp.mapping.close()";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
              "<Tab>" = "cmp.mapping.select_next_item()";
            };
            snippet.expand = "luasnip";
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "path"; }
              { name = "buffer"; }
              { name = "nvim_lua"; }
            ];
          };
        };

        # Snippets
        luasnip.enable = true;
        friendly-snippets.enable = true;

        # Treesitter for syntax highlighting
        treesitter = {
          enable = true;
          nixGrammars = true;
          settings = {
            ensure_installed = [
              "c_sharp"
              "html"
              "css"
              "json"
              "xml"
              "yaml"
              "markdown"
              "lua"
              "vim"
              "vimdoc"
              "regex"
              "bash"
            ];
          };
        };

        # Code actions
        trouble = {
          enable = true;
          settings = {
            auto_open = false;
            auto_close = true;
          };
        };

        # File explorer
        nvim-tree = {
          enable = true;
          settings = {
            disable_netrw = true;
            hijack_netrw = true;
            hijack_cursor = true;
            sync_root_with_cwd = true;
            respect_buf_cwd = true;
            update_focused_file = {
              enable = true;
            };
            diagnostics = {
              enable = true;
            };
            git = {
              enable = true;
            };
            renderer = {
              highlight_git = true;
              icons = {
                git_placement = "before";
              };
            };
          };
        };

        #   # Git integration
        #   gitsigns = {
        #     enable = true;
        #     settings = {
        #       signs = {
        #         add = { text = "▎"; };
        #         change = { text = "▎"; };
        #         delete = { text = "▎"; };
        #         topdelete = { text = "▎"; };
        #         changedelete = { text = "▎"; };
        #       };
        #       current_line_blame = true;
        #       on_attach = ''
        #         function(bufnr)
        #           local gs = package.loaded.gitsigns
        #           local function map(mode, l, r, opts)
        #             opts = opts or {}
        #             opts.buffer = bufnr
        #             vim.keymap.set(mode, l, r, opts)
        #           end

        #           -- Navigation
        #           map('n', ']c', function()
        #             if vim.wo.diff then return ']c' end
        #             vim.schedule(function() gs.next_hunk() end)
        #             return '<Ignore>'
        #           end, {expr=true})

        #           map('n', '[c', function()
        #             if vim.wo.diff then return '[c' end
        #             vim.schedule(function() gs.prev_hunk() end)
        #             return '<Ignore>'
        #           end, {expr=true})

        #           -- Actions
        #           map('n', '<leader>hs', gs.stage_hunk)
        #           map('n', '<leader>hr', gs.reset_hunk)
        #           map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        #           map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        #           map('n', '<leader>hS', gs.stage_buffer)
        #           map('n', '<leader>hu', gs.undo_stage_hunk)
        #           map('n', '<leader>hR', gs.reset_buffer)
        #           map('n', '<leader>hp', gs.preview_hunk)
        #           map('n', '<leader>hb', function() gs.blame_line{full=true} end)
        #           map('n', '<leader>tb', gs.toggle_current_line_blame)
        #           map('n', '<leader>hd', gs.diffthis)
        #           map('n', '<leader>hD', function() gs.diffthis('~') end)
        #           map('n', '<leader>td', gs.toggle_deleted)
        #         end
        #       '';
        #     };
        #   };

        #   # Autopairing
        #   nvim-autopairs = {
        #     enable = true;
        #     checkTs = true;
        #   };

        #   # Comments
        #   comment-nvim = {
        #     enable = true;
        #     settings.sticky = true;
        #   };

        #   # Terminal integration
        #   toggleterm = {
        #     enable = true;
        #     direction = "float";
        #     openMapping = "<C-t>";
        #     insertMapping = "<C-t>";
        #   };

        # Fuzzy finding
        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
          };
          keymaps = {
            "<leader>fb" = "buffers";
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
            "<leader>fh" = "help_tags";
            "<leader>fr" = "oldfiles";
            "<leader>fc" = "commands";
            "<leader>fs" = "lsp_document_symbols";
          };
        };

        # UI improvements
        which-key = {
          enable = true;
          settings.spec = [ ];
        };

        #   # Git UI
        #   diffview.enable = true;

        #   # Indent guides
        #   indent-blankline = {
        #     enable = true;
        #     settings = {
        #       indent = {
        #         char = "│";
        #       };
        #       scope = {
        #         enabled = true;
        #         show_start = true;
        #         show_end = true;
        #       };
        #     };
        #   };

        #   # Code actions lightbulb
        #   nvim-lightbulb = {
        #     enable = true;
        #     settings = {
        #       autocmd = {
        #         enabled = true;
        #       };
        #     };
        #   };

        #   # Debug
        #   dap = {
        #     enable = true;
        #     extensions = {
        #       dap-ui.enable = true;
        #       dap-virtual-text.enable = true;
        #     };
        #   };

        #   # Additional C# support
        #   netcoredbg = {
        #     enable = true;
        #   };

        # Buffer and statusline
        bufferline = {
          enable = true;
          settings = {
            options = {
              diagnostics = "nvim_lsp";
              separator_style = "slant";
              show_buffer_close_icons = true;
              show_close_icon = false;
            };
          };
        };

        #   # Quick navigation
        #   leap.enable = true;

        # Startup screen
        alpha = {
          enable = true;
          theme = "dashboard";
        };

        #   # Highlighting for TODO comments
        #   todo-comments.enable = true;

        # Project management
        project-nvim = {
          enable = true;
          settings = {
            detection_methods = [ "pattern" ];
            patterns = [
              ".git"
              "*.sln"
              "*.csproj"
            ];
          };
        };
      };

      #   # Extra configuration using Lua
      #   extraConfigLua = ''
      #     -- Configure netcoredbg for C# debugging
      #     local dap = require('dap')
      #     dap.adapters.coreclr = {
      #       type = 'executable',
      #       command = '${pkgs.netcoredbg}/bin/netcoredbg',
      #       args = {'--interpreter=vscode'}
      #     }

      #     dap.configurations.cs = {
      #       {
      #         type = "coreclr",
      #         name = "launch - netcoredbg",
      #         request = "launch",
      #         program = function()
      #           local cwd = vim.fn.getcwd()
      #           local function find_dll()
      #             local dll_path = vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      #             return dll_path
      #           end
      #           return find_dll()
      #         end,
      #       }
      #     }

      #     -- Add keymappings for debug
      #   vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
      #   vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
      #  vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
      #  vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
      # vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end)
      #vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
      #vim.keymap.set('n', '<leader>dl', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
      #vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end)
      #vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end)

      #     -- Setup C# custom commands
      #     vim.api.nvim_create_user_command('DotnetBuild', function()
      #       vim.cmd('!dotnet build')
      #     end, {})

      #     vim.api.nvim_create_user_command('DotnetRun', function()
      #       vim.cmd('!dotnet run')
      #     end, {})

      #     vim.api.nvim_create_user_command('DotnetTest', function()
      #       vim.cmd('!dotnet test')
      #     end, {})

      #     -- Solution explorer integration
      #     local function find_sln()
      #       local cwd = vim.fn.getcwd()
      #       local found_files = vim.fn.glob(cwd .. '/**/*.sln', false, true)
      #       if #found_files > 0 then
      #         return found_files[1]
      #       end
      #       return nil
      #     end

      #     vim.api.nvim_create_user_command('OpenSolution', function()
      #       local sln_file = find_sln()
      #       if sln_file then
      #         vim.cmd('e ' .. sln_file)
      #       else
      #         vim.notify('No solution file found', vim.log.levels.ERROR)
      #       end
      #     end, {})

      #     -- Additional keymappings for C# development
      #     vim.keymap.set('n', '<leader>cs', ':OpenSolution<CR>', { silent = true })
      #     vim.keymap.set('n', '<leader>cb', ':DotnetBuild<CR>', { silent = true })
      #     vim.keymap.set('n', '<leader>cr', ':DotnetRun<CR>', { silent = true })
      #     vim.keymap.set('n', '<leader>ct', ':DotnetTest<CR>', { silent = true })

      #     -- Format on save for C# files
      #     vim.api.nvim_create_autocmd("BufWritePre", {
      #       pattern = "*.cs",
      #       callback = function()
      #         vim.lsp.buf.format()
      #       end,
      #     })

      #     -- Configure file associations
      #     vim.filetype.add({
      #       extension = {
      #         ['cshtml'] = 'html',
      #         ['razor'] = 'razor',
      #         ['csproj'] = 'xml',
      #         ['sln'] = 'xml',
      #       },
      #     })

      #     -- Improve diagnostics display
      #     vim.diagnostic.config({
      #       virtual_text = {
      #         prefix = '●',
      #         source = "if_many",
      #       },
      #       float = {
      #         source = "always",
      #         border = "rounded",
      #       },
      #       signs = true,
      #       underline = true,
      #       update_in_insert = false,
      #       severity_sort = true,
      #     })
      #   '';

      # Additional keymaps
      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = ":NvimTreeToggle<CR>";
          options = {
            silent = true;
            desc = "Toggle file explorer";
          };
        }
        {
          mode = "n";
          key = "<Esc>";
          action = ":noh<CR>";
          options = {
            silent = true;
            desc = "Clear search highlights";
          };
        }
        {
          mode = "n";
          key = "<leader>w";
          action = ":w<CR>";
          options = {
            silent = true;
            desc = "Save file";
          };
        }
        {
          mode = "n";
          key = "<leader>q";
          action = ":q<CR>";
          options = {
            silent = true;
            desc = "Quit";
          };
        }
        {
          mode = "n";
          key = "<leader>tt";
          action = ":TroubleToggle<CR>";
          options = {
            silent = true;
            desc = "Toggle trouble";
          };
        }
      ];
    };
  };
}