-- ============================================================
-- Minimal Neovim config (no plugins)
-- ============================================================

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.wrap = false

-- Editing
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Responsiveness
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Clipboard + undo
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true

-- Diagnostics (built-in)
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  severity_sort = true,
  float = { border = "rounded" },
})

-- Keymaps helper
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Save/quit
map("n", "<leader>w", "<cmd>w<cr>", "Save")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")
map("n", "<leader>/", "<cmd>nohlsearch<cr>", "Clear search highlight")

-- Diagnostics navigation
map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic float")

-- LSP keymaps (only active when an LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "K", vim.lsp.buf.hover, "Hover")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")
  end,
})

-- ------------------------------------------------------------
-- Optional: basic LSP setup (requires you to install servers)
-- ------------------------------------------------------------
-- If you don't want LSP at all, delete everything below.

local lsp = vim.lsp
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")

if lspconfig_ok then
  -- Example servers. Install these on your system:
  --   clangd, gopls, rust-analyzer, pyright, typescript-language-server
  lspconfig.clangd.setup({})
  lspconfig.gopls.setup({})
  lspconfig.rust_analyzer.setup({})
  lspconfig.pyright.setup({})
  lspconfig.ts_ls.setup({})
else
  -- If you want LSP with zero plugins, remove lspconfig usage entirely
  -- and use `:LspStart <server>` with Neovim's builtin LSP configs (advanced).
end

