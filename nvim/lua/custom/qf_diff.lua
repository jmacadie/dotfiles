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
		local status, filename = line:match("^(%S+)%s+(.+)$")
		if status and filename then
			name_status_map[filename] = STATUS_MAP[status] or "?"
		end
	end

	for _, line in ipairs(numstat) do
		local lines_added, lines_deleted, filename = line:match("^(%d+)%s+(%d+)%s+(.+)$")
		if lines_added and lines_deleted and filename then
			table.insert(result, {
				filename = filename,
				status = name_status_map[filename] or "?", -- Default status to "?" if not found
				lines_added = tonumber(lines_added),
				lines_deleted = tonumber(lines_deleted),
			})
		end
	end

	return result
end

local function format_quickfix(info)
	local result = {}

	for _, item in ipairs(vim.fn.getqflist({ id = info.id, items = 0 }).items) do
		local filename = item.bufnr and vim.fn.bufname(item.bufnr) or ""
		local extra = item.user_data
		local status = extra["status"] or ""
		local added = extra["lines_added"] or ""
		local deleted = extra["lines_deleted"] or ""
		table.insert(result, string.format("%s | +%d -%d | %s", filename, added, deleted, status))
	end

	return result
end

local function populate_quickfix(parsed_files)
	local items = {}

	for _, item in ipairs(parsed_files) do
		table.insert(items, {
			filename = item.filename,
			user_data = {
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

M.diff = function()
	local files = get_diff_files()
	populate_quickfix(files)
	vim.cmd("copen")
	organise_windows()
	vim.cmd("cc")
	vim.cmd("Gvdiff @{u}")
	vim.cmd("wincmd p")
end

M.next = function()
	if qf_diff_running() then
		organise_windows()
		vim.cmd("cnext")
		vim.cmd("Gvdiff @{u}")
		vim.cmd("wincmd p")
	else
		vim.cmd("cnext")
	end
end

M.prev = function()
	if qf_diff_running() then
		organise_windows()
		vim.cmd("cprev")
		vim.cmd("Gvdiff @{u}")
		vim.cmd("wincmd p")
	else
		vim.cmd("cprev")
	end
end

return M
