-- Git related plugins
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiff development<cr>", { desc = "Vim Fugative: [G]it [D]iff development" })

return {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
}
