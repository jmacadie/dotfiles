local ks = vim.keymap.set

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
ks({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- [[ Navigation ]]

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
