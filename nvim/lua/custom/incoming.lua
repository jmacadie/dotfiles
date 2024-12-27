M = {}

local lsp_client
local code_buf
local float_buf
local nodes = {
	root = nil,
	current = nil,
}

local create_floating_scratch_buffer = function()
	float_buf = vim.api.nvim_create_buf(false, true)
	if not float_buf then
		vim.notify("Failed to create buffer", vim.log.levels.ERROR)
		return
	end

	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.7)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(float_buf, true, opts)
	if not win then
		vim.notify("Failed to create floating window", vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_buf_set_keymap(float_buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(float_buf, "n", "<ESC>", "<cmd>bd!<CR>", { noremap = true, silent = true })

	-- vim.api.nvim_buf_set_keymap(float_buf, "n", "<DOWN>", move_down, { noremap = true, silent = true })
	-- vim.api.nvim_buf_set_keymap(float_buf, "n", "<UP>", move_up, { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(
		float_buf,
		"n",
		"<RIGHT>",
		"<cmd>lua require('custom.incoming').expand_current_node()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		float_buf,
		"n",
		"<LEFT>",
		"<cmd>lua require('custom.incoming').collapse_current_node()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		float_buf,
		"n",
		"gh",
		"<cmd>lua require('custom.incoming').debug()<CR>",
		{ noremap = true, silent = true }
	)
end

local add_node_lines
add_node_lines = function(node, prefix, lines)
	table.insert(lines, prefix .. node.text)
	if node.expanded then
		local inner_prefix = "  " .. prefix
		for _, child in ipairs(node.children) do
			add_node_lines(child, inner_prefix, lines)
		end
	end
end

local write_call_window = function()
	local node = nodes.root
	if node == nil then
		vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, {})
		return
	end

	local lines = {}
	add_node_lines(node, "", lines)
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
end

M.debug = function()
	local data = vim.inspect(nodes)
	local lines = vim.split(data, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
end

local make_request = function(method, params, callback)
	lsp_client:request(method, params, function(err, result)
		if err then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
		if result == nil then
			return
		end
		callback(result)
	end, code_buf)
end

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
local get_children = function(root, callback)
	local node = nodes.current
	if node == nil then
		return
	end

	local prepare = "textDocument/prepareCallHierarchy"
	local clients = vim.lsp.get_clients({ bufnr = code_buf, method = prepare })
	if vim.tbl_contains(clients, lsp_client) then
		make_request(prepare, node.search_loc, function(results)
			if root then
				node.text = results[1].name
			end
			for _, item in ipairs(results) do
				make_request("callHierarchy/incomingCalls", { item = item }, callback)
			end
		end)
	end
end

local create_node = function(uri, text, lnum, col, search_loc)
	return {
		filename = vim.uri_to_fname(uri),
		text = text,
		lnum = lnum,
		col = col,
		search_loc = search_loc,
		searched = false,
		expanded = false,
		children = {},
	}
end

M.expand_current_node = function()
	local node = nodes.current
	if node == nil or node.expanded then
		return
	end
	if node.searched then
		node.expanded = true
		write_call_window()
		return
	end

	local at_root = (nodes.current == nodes.root)

	get_children(at_root, function(result)
		for _, call in ipairs(result) do
			local item = call["from"]
			for _, range in ipairs(call.fromRanges) do
				local loc = {
					textDocument = {
						uri = item.uri,
					},
					position = item.range.start,
				}
				table.insert(
					node.children,
					create_node(item.uri, item.name, range.start.line + 1, range.start.character + 1, loc)
				)
			end
		end
		node.searched = true
		node.expanded = true
		write_call_window()
	end)
end

M.collapse_current_node = function()
	local node = nodes.current
	if node == nil or not node.expanded then
		return
	end

	node.expanded = false
	write_call_window()
end

local initialise_nodes = function()
	local current_position = vim.lsp.util.make_position_params(0, lsp_client.offset_encoding)
	local uri = current_position.textDocument.uri
	local lnum = current_position.position.line + 1
	local col = current_position.position.character + 1
	nodes.root = create_node(uri, "", lnum, col, current_position)
	nodes.current = nodes.root
end

M.x = function(client, bufnr)
	lsp_client = client
	code_buf = bufnr

	initialise_nodes()
	create_floating_scratch_buffer()
	M.expand_current_node()
end

return M
