-- Git related plugins
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiff development<cr>", { desc = "Vim Fugative: [G]it [D]iff development" })
vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Vim Fugative: [G]it" })

return {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
}
