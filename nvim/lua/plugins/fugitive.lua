-- Git related plugins
vim.keymap.set("n", "<leader>gd", ":Gvdiff ", { desc = "Vim Fugative: [G]it [D]iff (provide your own refspec)" })
vim.keymap.set("n", "<leader>gg", "<cmd>vertical Git<cr>", { desc = "Vim Fugative: [G]it" })
vim.keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Vim Fugative: [G]it [W]rite 'Stage whole file'" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Vim Fugative: [G]it [B]lame" })
vim.keymap.set("n", "<leader>gh", "<cmd>Git<cr>", { desc = "Vim Fugative: [G]it in [H]orizontal split" })
vim.keymap.set(
	"n",
	"<leader>gl",
	"<cmd>vertical Git log --pretty='format:%C(auto)%h %d %<|(70)%s %Cblue%aN, %ad' --date=format:'%a %Y-%m-%d %H:%I' --graph<cr>",
	{ desc = "Vim Fugative: [G]it [L]og" }
)
-- vim.keymap.set("n", "<leader>gcl", "<cmd>vertical Git log %<cr>", { desc = "Vim Fugative: [G]it [C]urrent file [L]og" })
vim.keymap.set("n", "<leader>gm", "<cmd>Gvdiffsplit!<cr>", { desc = "Vim Fugative: [G]it 3 Way [M]erge split" })
vim.keymap.set("n", "<leader>ga", "<cmd>diffget //2<cr>", { desc = "[G]it: Get changes from <<<<< HEAD" })
vim.keymap.set("n", "<leader>go", "<cmd>diffget //3<cr>", { desc = "[G]it: Get changes from Target >>>>>" })

return {
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
}
