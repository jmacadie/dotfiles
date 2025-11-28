local M = {}

M.nmap = function(keys, func, bufnr, desc)
	if desc then
		desc = "LSP: " .. desc
	end
	vim.keymap.set("n", keys, func, { silent = true, buffer = bufnr, desc = desc })
end

M.on_attach = function(_, bufnr)
	local function map(keys, func, desc)
		M.nmap(keys, func, bufnr, desc)
	end
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	map("<leader>sr", require("telescope.builtin").lsp_references, "[S]earch [R]eferences")
	map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	map("[d", function()
		vim.diagnostic.jump({ count = -1 })
		vim.cmd("normal! zz")
	end, "Go to previous diagnostic message")
	map("]d", function()
		vim.diagnostic.jump({ count = 1 })
		vim.cmd("normal! zz")
	end, "Go to next diagnostic message")
	map("<leader>e", vim.diagnostic.open_float, "Open floating diagnostic message")
	map("<leader>q", vim.diagnostic.setloclist, "Open diagnostics list")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("<A-k>", vim.lsp.buf.signature_help, "Signature Documentation")
	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

return M
