M = {}

local client
local bufnr
local nodes = {
	root = nil,
	current = nil,
}

local create_floating_scratch_buffer = function(data)
	-- Create a new scratch buffer
	local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
	if not buf then
		vim.notify("Failed to create buffer", vim.log.levels.ERROR)
		return
	end

	-- Configure floating window dimensions
	local width = math.floor(vim.o.columns * 0.5) -- 50% of screen width
	local height = math.floor(vim.o.lines * 0.7) -- 70% of screen height
	local row = math.floor((vim.o.lines - height) / 2) -- Center vertically
	local col = math.floor((vim.o.columns - width) / 2) -- Center horizontally

	-- Floating window options
	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded", -- Optional: rounded, single, double, shadow, none
	}

	-- Open the floating window
	local win = vim.api.nvim_open_win(buf, true, opts) -- Focus the window
	if not win then
		vim.notify("Failed to create floating window", vim.log.levels.ERROR)
		return
	end

	-- Use vim.inspect to convert the table to a string
	local inspected_data = vim.inspect(data)

	-- Set the buffer content to the inspected data
	local lines = vim.split(inspected_data, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Optional: Map `q` to close the floating window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end

local make_request = function(method, params, callback)
	client:request(method, params, function(err, result)
		if err then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
		if result == nil then
			return
		end
		callback(result)
	end, bufnr)
end

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
local get_children = function(root, callback)
	local prepare_method = "textDocument/prepareCallHierarchy"
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = prepare_method })
	if vim.tbl_contains(clients, client) then
		make_request(prepare_method, root.search_loc, function(results)
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

local expand_current_node = function()
	local node = nodes.current
	if node == nil or node.expanded then
		return
	end
	if node.searched then
		node.expanded = true
		return
	end

	get_children(node, function(result)
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
		create_floating_scratch_buffer(nodes)
	end)
end

local initialise_nodes = function(current_position)
	local uri = current_position.textDocument.uri
	local lnum = current_position.position.line + 1
	local col = current_position.position.character + 1
	nodes.root = create_node(uri, "", lnum, col, current_position)
	nodes.current = nodes.root
end

M.x = function(c, b)
	client = c
	bufnr = b

	local current_position = vim.lsp.util.make_position_params(0, client.offset_encoding)
	initialise_nodes(current_position)
	expand_current_node()
end

return M
