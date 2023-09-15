-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'lazy_init'
require('lazy').setup('plugins')

require 'opts'
require 'maps'

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337#issuecomment-1397639999
vim.api.nvim_create_autocmd({ "BufEnter" }, { pattern = { "*" }, command = "normal zx", })

-- TODO: luasnips
-- TODO: nvim-cmp
-- TODO: review plugins I used to have e.g. devicons

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
