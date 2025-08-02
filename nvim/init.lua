-- ~/.config/nvim/init.lua or init file depending on your setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install using lazy.nvim or packer (this example assumes lazy.nvim)

-- 1. Plugin Setup
require("lazy").setup({
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { "neovim/nvim-lspconfig" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },
  { "hrsh7th/nvim-cmp" },                -- completion engine
  { "hrsh7th/cmp-nvim-lsp" },            -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" },              -- buffer source
  { "hrsh7th/cmp-path" },                -- path source
  { "L3MON4D3/LuaSnip" },                -- snippet engine
  { "saadparwaiz1/cmp_luasnip" },
  {"nvim-treesitter/nvim-treesitter",build = ":TSUpdate"},
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  {"kawre/leetcode.nvim",build = ":TSUpdate html",dependencies = "nvim-lua/plenary.nvim","MunifTanjim/nui.nvim","nvim-telescope/telescope.nvim","nvim-tree/nvim-web-devicons",
  },
  cmd = "Leet",               -- lazy-load when you run :Leet (recommended)
  opts = {
    -- Start in the language you use most
    lang = "golang",          -- or "cpp", "python3", etc.
    picker = { provider = "telescope" }, -- use the picker you installed
    plugins = {
      -- If you want to run inside your normal session (without a blank Neovim)
      -- turn this on; otherwise keep false and start in an empty session.
      non_standalone = true,
    },
  },
})

-- 2. Mason + LSP Configuration
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "clangd",       -- C/C++
    "gopls",         -- Go
  },
})


local lspconfig = require("lspconfig")

local servers = {
  clangd = {},
  gopls = {},
}

for server, config in pairs(servers) do
  lspconfig[server].setup(config)
end

-- 3. Editor Options
vim.opt.tabstop = 4       -- Number of visual spaces per TAB
vim.opt.shiftwidth = 4    -- Indent width
vim.opt.expandtab = true  -- Tabs are spaces
vim.opt.number = true     -- Show line numbers

-- 4. File Explorer Setup
require("nvim-tree").setup({
  view = {
    side = "right",
    width = 30,
  },
  renderer = {
    icons = {
      show = {
        git = false,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
})
vim.g.mapleader = " "
-- Optional: Map key to toggle file explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Replace Ctrl-C mapping to use Command-C on macOS GUI (maps to Escape)
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true, silent = true })

-- Optional: cycle windows with Tab
vim.keymap.set('n', '<Tab>', '<C-w>w', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', '<C-w>W', { noremap = true, silent = true })

-- 5. Enable true color if using terminal
-- 6. Autocompletion Setup
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]     = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip'  },
  }, {
    { name = 'buffer'  },
    { name = 'path'    },
  }),
})
