-- Git related plugins
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiff development<cr>", { desc = "Vim Fugative: [G]it [D]iff development" })
vim.keymap.set("n", "<leader>gg", "<cmd>vertical Git<cr>", { desc = "Vim Fugative: [G]it" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Vim Fugative: [G]it [B]lame" })
vim.keymap.set("n", "<leader>gh", "<cmd>Git<cr>", { desc = "Vim Fugative: [G]it in [H]orizontal split" })
vim.keymap.set("n", "<leader>gl", "<cmd>vertical Git log<cr>", { desc = "Vim Fugative: [G]it [L]og" })

return {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
}
