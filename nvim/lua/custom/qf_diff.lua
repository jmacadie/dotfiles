M = {}

local STATUS_MAP = {
	["A"] = "ADDED",
	["B"] = "BROKEN",
	["C"] = "COPIED",
	["D"] = "DELETED",
	["M"] = "MODIFIED",
	["R"] = "RENAMED",
	["T"] = "CHANGED",
	["U"] = "UNMERGED",
	["X"] = "UNKNOWN",
}

---@class FileDiffStatus
---@field filename string The path and filename of the file. If the file has been moved this will be the file *after* the move
---@field source_filename string | nil If the file was moved, what was the source filename
---@field status string
---@field lines_added integer
---@field lines_deleted integer

---Convert the diff between the current worktree and an arbitrary refspec to a table of
---files that have been modified, the type of change, and the number of lines changed
---@param remote_branch string | nil
---@return FileDiffStatus[]
local function get_diff_files(remote_branch)
	local result = {}

	-- Default to the current branch's remote tracking branch if not provided
	if not remote_branch then
		remote_branch = vim.fn.system("git rev-parse --abbrev-ref @{u}"):gsub("\n", "")
	end

	local name_status = vim.fn.systemlist("git diff --name-status " .. remote_branch)
	local numstat = vim.fn.systemlist("git diff --numstat " .. remote_branch)

	local name_status_map = {}
	for _, line in ipairs(name_status) do
		if line:sub(1, 1) == "R" then
			local status, pcnt, filename, rename_filename = line:match("^(%u)(%d*)%s+(%S+)%s+(%S+)$")
			local pcnt_val = tonumber(pcnt)
			local mapped_status = string.format("%s (%d%%)", STATUS_MAP[status], pcnt_val)
			if status and filename then
				name_status_map[rename_filename] = { status = mapped_status, from = filename }
			end
		else
			local status, filename = line:match("^(%u)%s+(%S+)$")
			local mapped_status = STATUS_MAP[status] or "?"
			if status and filename then
				name_status_map[filename] = { status = mapped_status }
			end
		end
	end

	for _, line in ipairs(numstat) do
		---@type string | nil, string | nil, string | nil
		local lines_added, lines_deleted, filename = line:match("^(%d+)%s+(%d+)%s+(.+)$")
		if lines_added and lines_deleted and filename then
			local added = tonumber(lines_added)
			local deleted = tonumber(lines_deleted)
			---@cast filename string
			local prefix, part_1, part_2, suffix = filename:match("^([^{]*){(%S+) => (%S+)}(%S*)")
			if part_1 or part_2 then
				local from_fname = string.format("%s%s%s", prefix, part_1, suffix)
				local to_fname = string.format("%s%s%s", prefix, part_2, suffix)
				table.insert(result, {
					filename = to_fname,
					source_filename = from_fname,
					display = filename,
					status = name_status_map[to_fname].status or "?", -- Default status to "?" if not found
					lines_added = added,
					lines_deleted = deleted,
				})
			else
				table.insert(result, {
					filename = filename,
					source_filename = nil,
					display = filename,
					status = name_status_map[filename].status or "?", -- Default status to "?" if not found
					lines_added = added,
					lines_deleted = deleted,
				})
			end
		end
	end
	-- vim.notify(vim.inspect(result), vim.log.levels.INFO)

	return result
end

local function format_quickfix(info)
	local result = {}

	for _, item in ipairs(vim.fn.getqflist({ id = info.id, items = 0 }).items) do
		local extra = item.user_data
		local display = extra["display"] or ""
		local status = extra["status"] or ""
		local added = extra["lines_added"] or ""
		local deleted = extra["lines_deleted"] or ""
		table.insert(result, string.format("%s | +%d -%d | %s", display, added, deleted, status))
	end

	return result
end

local function populate_quickfix(parsed_files)
	local items = {}

	for _, item in ipairs(parsed_files) do
		table.insert(items, {
			filename = item.filename,
			user_data = {
				display = item.display,
				source = item.source_filename,
				status = item.status,
				lines_added = item.lines_added,
				lines_deleted = item.lines_deleted,
			},
		})
	end

	vim.fn.setqflist({}, "r", {
		title = "Git Diff Files",
		items = items,
		quickfixtextfunc = format_quickfix,
	})
end

local organise_windows = function()
	local not_qf = {}

	for _, window in ipairs(vim.fn.getwininfo()) do
		if window.quickfix == 0 and window.width > 1 then
			table.insert(not_qf, window)
		end
	end

	local without_current = vim.tbl_filter(function(window)
		return window.winnr ~= vim.fn.winnr()
	end, not_qf)

	if #without_current == #not_qf then
		local new_focused = table.remove(without_current, 1)
		vim.api.nvim_set_current_win(new_focused.winid)
	end

	for _, window in ipairs(without_current) do
		vim.cmd("bdelete!" .. window.bufnr)
	end
end

local function qf_diff_running()
	local qf_title = vim.fn.getqflist({ title = 0 }).title
	return qf_title == "Git Diff Files"
end

local function cycle_qf_forward()
	local at_end = (vim.fn.getqflist({ idx = 0 }).idx == vim.fn.getqflist({ size = 0 }).size)
	if at_end then
		vim.cmd("cfirst")
	else
		vim.cmd("cnext")
	end
end

local function cycle_qf_backward()
	local at_start = (vim.fn.getqflist({ idx = 0 }).idx == 1)
	if at_start then
		vim.cmd("clast")
	else
		vim.cmd("cprev")
	end
end

local function diff_current_file()
	local qf_idx = vim.fn.getqflist({ idx = 0 }).idx
	local qf_list = vim.fn.getqflist()
	local data = qf_list[qf_idx].user_data

	if data.status == "ADDED" then
		return
	end

	local source = data.source
	if source then
		vim.cmd(string.format("Gvdiffsplit @{u}:%s", source))
	else
		vim.cmd("Gvdiffsplit @{u}")
	end
	vim.cmd("wincmd p")
end

M.diff = function()
	local files = get_diff_files()
	populate_quickfix(files)
	vim.cmd("copen")
	organise_windows()
	vim.cmd("cc")
	diff_current_file()
end

M.next = function()
	if qf_diff_running() then
		organise_windows()
		cycle_qf_forward()
		diff_current_file()
	else
		cycle_qf_forward()
	end
end

M.prev = function()
	if qf_diff_running() then
		organise_windows()
		cycle_qf_backward()
		diff_current_file()
	else
		cycle_qf_backward()
	end
end

return M
