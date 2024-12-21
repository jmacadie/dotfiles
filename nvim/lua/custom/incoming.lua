M = {}
local _client
local _bufnr

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
	_client:request(method, params, function(err, result)
		if err then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end
		if result == nil then
			return
		end
		callback(result)
	end, _bufnr)
end

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#callHierarchy_incomingCalls
local get_children = function(root, callback)
	local prepare_method = "textDocument/prepareCallHierarchy"
	local clients = vim.lsp.get_clients({ bufnr = _bufnr, method = prepare_method })
	if vim.tbl_contains(clients, _client) then
		make_request(prepare_method, root, function(results)
			for _, item in ipairs(results) do
				make_request("callHierarchy/incomingCalls", { item = item }, callback)
			end
		end)
	end
end

M.x = function(client, bufnr)
	_client = client
	_bufnr = bufnr
	local current_position = vim.lsp.util.make_position_params(0, _client.offset_encoding)
	get_children(current_position, function(result)
		local output = {}
		for _, call in ipairs(result) do
			local item = call["from"]
			for _, range in ipairs(call.fromRanges) do
				table.insert(output, {
					filename = vim.uri_to_fname(item.uri),
					text = item.name,
					lnum = range.start.line + 1,
					col = range.start.character + 1,
					child_search = {
						textDocument = {
							uri = item.uri,
						},
						position = item.range.start,
					},
				})
			end
		end
		create_floating_scratch_buffer(output)
	end)
end

return M
