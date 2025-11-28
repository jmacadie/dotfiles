local M = {}

M.on_attach = function(_, bufnr)
	local function nmap(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { silent = true, buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("<leader>sr", require("telescope.builtin").lsp_references, "[S]earch [R]eferences")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	nmap("[d", function()
		vim.diagnostic.jump({ count = -1 })
		vim.cmd("normal! zz")
	end, "Go to previous diagnostic message")
	nmap("]d", function()
		vim.diagnostic.jump({ count = 1 })
		vim.cmd("normal! zz")
	end, "Go to next diagnostic message")
	nmap("<leader>e", vim.diagnostic.open_float, "Open floating diagnostic message")
	nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostics list")
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<A-k>", vim.lsp.buf.signature_help, "Signature Documentation")
	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

return M
