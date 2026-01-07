local ks = vim.keymap.set

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
ks({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Don't yank to the unamed register with x, throw it away instead
ks("n", "x", '"_x')

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



-- [[ Snippets ]]

-- Jump forwards
ks({ "i", "s" }, "<C-j>", function()
	if vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
		return ""
	end
	return "<C-j>"
end, { expr = true, silent = true })

-- Jump backards
ks({ "i", "s" }, "<C-k>", function()
	if vim.snippet.active({ direction = -1 }) then
		vim.snippet.jump(-1)
		return ""
	end
	return "<C-k>"
end, { expr = true, silent = true })

-- Quit snippet
ks({ "i", "s" }, "<C-e>", function()
	if vim.snippet.active() then
		vim.snippet.stop()
		return ""
	end
	return "<C-k>"
end, { silent = true })
