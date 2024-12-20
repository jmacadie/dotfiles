local M = {}

M.on_attach = function(client, bufnr)
	M.nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { silent = true, buffer = bufnr, desc = desc })
	end

	M.nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	M.nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	M.nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	M.nmap("<leader>sr", require("telescope.builtin").lsp_references, "[S]earch [R]eferences")
	M.nmap("<leader>si", require("telescope.builtin").lsp_incoming_calls, "[S]earch [I]ncoming Call Hierachy")
	M.nmap("<leader>so", require("telescope.builtin").lsp_outgoing_calls, "[S]earch [O]utgoing Call Hierachy")
	M.nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	M.nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	M.nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	M.nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	M.nmap("[d", function()
		vim.diagnostic.goto_prev()
		vim.cmd("normal! zz")
	end, "Go to previous diagnostic message")
	M.nmap("]d", function()
		vim.diagnostic.goto_next()
		vim.cmd("normal! zz")
	end, "Go to next diagnostic message")
	M.nmap("<leader>e", vim.diagnostic.open_float, "Open floating diagnostic message")
	M.nmap("<leader>q", vim.diagnostic.setloclist, "Open diagnostics list")
	M.nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	M.nmap("<A-k>", vim.lsp.buf.signature_help, "Signature Documentation")
	M.nmap("<leader>xx", function()
		require("custom.incoming").x(client, bufnr)
	end, "E[x]tra Special")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

local nvim_capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = vim.tbl_deep_extend("force", nvim_capabilities, require("blink.cmp").get_lsp_capabilities())

return M
