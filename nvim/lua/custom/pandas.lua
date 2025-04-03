local dap = require("dap")

M = {}

-- https://github.com/igorlfs/nvim-dap-view/blob/0a7e6395f5bdb79cee233cebd99639713b0a0de2/lua/dap-view/options/winbar.lua#L45
-- https://github.com/mfussenegger/nvim-dap/blob/master/lua/dap/repl.lua#L92
-- https://github.com/mfussenegger/nvim-dap/blob/master/doc/dap.txt#L955
--

-- local function open_floating_window()
-- 	local width = math.floor(vim.o.columns * 0.8)
-- 	local height = math.floor(vim.o.lines * 0.8)
-- 	local col = math.floor((vim.o.columns - width) / 2)
-- 	local row = math.floor((vim.o.lines - height) / 2)
-- 	local winopts = {
-- 		relative = "editor",
-- 		width = width,
-- 		height = height,
-- 		col = col,
-- 		row = row,
-- 		border = "rounded",
-- 		style = "minimal",
-- 	}
-- 	local scratch_buf = vim.api.nvim_create_buf(false, true)
-- 	return vim.api.nvim_open_win(scratch_buf, true, winopts)
-- end

---Will find all Pandas DataFrames and Series that are currently in memory of a paused execution of a
---debugged python process
---The process is aysnc as the discovery of the variables involves making requests to the debug server
---When all dataframes have been found the callback will be called with a list of the found DataFrames
---and Series as dap Variables
---@async
---@param cb fun(dataframes: dap.Variable[])
local function get_pandas_dataframes(cb)
	local session = dap.session()
	if not session then
		vim.notify("No active debug session", vim.log.levels.ERROR)
		return
	end
	local current_frame = session.current_frame
	if not current_frame then
		vim.notify("No current frame information available", vim.log.levels.ERROR)
		return
	end
	if not current_frame.scopes then
		vim.notify("No available scopes in the current frame", vim.log.levels.ERROR)
		return
	end
	vim.notify("Finding all DataFrames and Series in current memory. This can take a little while", vim.log.levels.INFO)

	---@type integer
	local calls_counter = 0
	---@type table
	local visited = {}
	---@type dap.Variable[]
	local dataframes = {}

	---Function to keep track of whether all dap calls have resolved and to call the continuing
	---callback, when that is the case
	local function countdown()
		calls_counter = calls_counter - 1
		if calls_counter == 0 then
			cb(dataframes)
		end
	end

	---Determine whether the given variable is one we want to recursively search inside
	---@param var dap.Variable
	---@return boolean
	local function keep_searching(var)
		if var.variablesReference == 0 then
			return false
		end
		if not var.type or var.type == "method" or var.type == "datetime" then
			return false
		end
		if
			var.name:find("^_") ~= nil -- ignore hidden methods and properties
			or var.name == "special variables"
			or var.name == "function variables"
			or var.name == "class variables"
			or var.name == "model_fields" -- pydantic noise
		then
			return false
		end
		return true
	end

	---Recursively try to find DataFrame varibles in current scope
	---@async
	---@param ref integer
	---@param depth integer
	local function recursive_find(ref, depth)
		-- Stop processing if this is a reference with no children or one we have already searched
		-- Also stop the depth below 10 levels, as no one needs that level of inspection
		if depth > 10 or ref == 0 or visited[ref] then
			return
		end
		visited[ref] = true

		calls_counter = calls_counter + 1
		session:request("variables", { variablesReference = ref }, function(err, vars)
			if err then
				vim.notify("Error retrieving variables: " .. err, vim.log.levels.ERROR)
				countdown()
				return
			end
			-- Debugging :)
			-- if #vars.variables > 10 then
			-- 	vim.notify(name, vim.log.levels.INFO)
			-- end

			for _, var in ipairs(vars.variables) do
				if var.type and (var.type == "DataFrame" or var.type == "Series") then
					table.insert(dataframes, var)
				elseif keep_searching(var) then
					-- Debugging :)
					-- local txt = var.evaluateName or var.name
					-- local txt2 = var.type or ""
					-- recursive_find(var.variablesReference, depth + 1, name .. " -> " .. txt .. " (" .. txt2 .. ")")
					recursive_find(var.variablesReference, depth + 1)
				end
			end
			countdown()
		end)
	end

	-- Kick off the finding process by searching in each of the current scopes
	for _, scope in ipairs(current_frame.scopes) do
		recursive_find(scope.variablesReference, 1)
	end
end

M.open = function()
	-- local winnr = open_floating_window()
	-- local bufnr = dap.repl.open(nil, "lua vim.api.nvim_set_current_win(" .. winnr .. ")")
	get_pandas_dataframes(function(dataframes)
		vim.notify(vim.inspect(dataframes[5]), vim.log.levels.INFO)
		vim.ui.select(dataframes, {
			prompt = "Many, many datframes found. Pick one. Now!",
			format_item = function(item)
				local name = item.evaluateName or item.name
				local type = item.type or ""
				local _, _, size = item.value:find("(%[[^%[]*row[^%]]*%])")
				local _, _, length = item.value:find(", (Length: %d*),")
				size = size or length or ""
				return name .. " (" .. type .. ") " .. size
			end,
		}, function(choice)
			if choice then
				vim.notify("You picked " .. choice.evaluateName, vim.log.levels.INFO)
			else
				vim.notify("No pick, no fair", vim.log.levels.INFO)
			end
		end)
	end)
	--
	-- dap.repl.execute("df = self.cash")
	-- dap.repl.clear()
	-- dap.repl.execute("print(df.T)")
	--
	-- vim.keymap.set("n", "q", function()
	-- 	vim.api.nvim_buf_delete(bufnr, { force = true })
	-- end)
	--
	-- vim.keymap.set("n", "z", function()
	-- 	dap.repl.execute("df = df[(df != 0).any(axis=1)]")
	-- 	dap.repl.clear()
	-- 	dap.repl.execute("print(df.T)")
	-- end)
end

return M
