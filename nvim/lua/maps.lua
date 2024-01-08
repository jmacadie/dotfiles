local ks = vim.keymap.set

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
ks({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- ks({ "i" }, "kj", "<Esc>", { silent = true })

-- [[ Navigation ]]

-- Move between windows
ks("n", "<a-j>", "<C-w>j", { silent = true })
ks("n", "<a-k>", "<C-w>k", { silent = true })
ks("n", "<a-h>", "<C-w>h", { silent = true })
ks("n", "<a-l>", "<C-w>l", { silent = true })

-- Remap for dealing with word wrap
ks("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
ks("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Scroll with find
ks("n", "n", "nzz", { silent = true })
ks("n", "N", "Nzz", { silent = true })
ks("n", "*", "*zz", { silent = true })
ks("n", "#", "#zz", { silent = true })

-- [[ LSP ]]

-- Diagnostic keymaps
ks("n", "[q", ":cp<CR>", { desc = "Go to previous quickfix entry" })
ks("n", "]q", ":cn<CR>", { desc = "Go to next quickfix entry" })
