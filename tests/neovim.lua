-- Run with the built Nixvim package and its nixvim-print-init output as -u.
-- Uses an isolated XDG environment; does not touch a real editor session.
local function check()
  assert(vim.v.errmsg == "", "Startup error: " .. vim.v.errmsg)
  for _, module in ipairs({ "snacks", "blink.cmp", "conform", "gitsigns", "flash", "noice", "trouble", "persistence" }) do
    assert(require(module), "Missing module: " .. module)
  end
  assert(require("blink.cmp").get_lsp_capabilities().textDocument.completion.completionItem.snippetSupport)
  local palette = require("catppuccin.palettes").get_palette("mocha")
  assert(
    vim.api.nvim_get_hl(0, { name = "SnacksDashboardHeader", link = false }).fg == tonumber(palette.lavender:sub(2), 16),
    "Another theme overwrote the dashboard accent"
  )
  assert(require("lualine.themes.catppuccin-nvim"), "Status-line theme could not be loaded")

  -- An LSP attachment must preserve explorer, file, window, and quit bindings.
  vim.api.nvim_exec_autocmds("LspAttach", { group = "nixvim_binds_LspAttach", buffer = 0, data = { client_id = 0 } })
  local expected = {
    ["<leader>ff"] = "Find Files (Root)",
    ["<leader>e"] = "Explorer (Root)",
    ["<leader>cf"] = "Format Buffer",
    ["<leader>ca"] = "Code Action",
    ["<leader>cr"] = "Rename",
    ["<leader>qq"] = "Quit All",
    ["<C-k>"] = "Go to up Window",
  }
  for key, desc in pairs(expected) do
    assert(vim.fn.maparg(key, "n", false, true).desc == desc, "Overridden or missing mapping: " .. key)
  end
  assert(vim.fn.maparg("<leader>q", "n") == "", "Quit/session group is shadowed")

  -- Exercise project/cwd dispatch without creating picker UI.
  local project = vim.fn.stdpath("cache") .. "/root-test-" .. vim.fn.getpid()
  vim.fn.mkdir(project .. "/src", "p")
  vim.fn.writefile({}, project .. "/test.sln")
  vim.api.nvim_buf_set_name(0, project .. "/src/test.txt")
  local picker_files = Snacks.picker.files
  local captured
  Snacks.picker.files = function(opts)
    captured = opts
  end
  vim.fn.maparg("<leader>ff", "n", false, true).callback()
  assert(captured.cwd == project, ".NET project root not found")
  vim.fn.maparg("<leader>fF", "n", false, true).callback()
  assert(captured.cwd == nil, "cwd picker unexpectedly uses project root")
  Snacks.picker.files = picker_files

  -- Prove actual formatting and both save toggles, using the Nix-provided binary.
  vim.lsp.enable("jsonls", false)
  local file = project .. "/format.json"
  vim.cmd("enew")
  vim.api.nvim_buf_set_name(0, file)
  vim.bo.filetype = "json"
  assert(vim.fn.executable("prettier") == 1, "Formatter is absent from wrapped PATH")
  local unformatted = '{"hello":"world"}'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { unformatted })
  vim.cmd.write()
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= unformatted, "Save did not format JSON")
  vim.g.autoformat = false
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { unformatted })
  vim.cmd.write()
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == unformatted, "Global autoformat toggle ignored")
  vim.g.autoformat = true
  vim.b.autoformat = false
  vim.cmd.write()
  assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == unformatted, "Buffer autoformat toggle ignored")
  require("conform").format({ async = false })
  assert(
    vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= unformatted,
    "Explicit formatting should work with autoformat off"
  )
  assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()], "Treesitter highlighting did not start")

  -- Root/cwd mappings must also be able to create real picker/explorer windows.
  local picker = Snacks.picker.files({ cwd = project })
  assert(picker and not picker.closed, "File picker failed to open")
  picker:close()
  local explorer = Snacks.explorer({ cwd = project })
  assert(explorer and not explorer.closed, "Explorer failed to open")
  explorer:close()

  require("persistence").stop()
  assert(vim.v.errmsg == "", "Runtime error: " .. vim.v.errmsg)
  io.stdout:write("Neovim runtime checks passed\n")
  io.stdout:flush()
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    io.stderr:write(err .. "\n")
    io.stderr:flush()
    vim.cmd("cquit 1")
  else
    vim.cmd("qa!")
  end
end)
