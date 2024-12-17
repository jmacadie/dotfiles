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
	-- Default to the current branch's remote tracking branch if not provided
	if not remote_branch then
		remote_branch = vim.fn.system("git rev-parse --abbrev-ref @{u}"):gsub("\n", "")
	end

	local cmd = "git diff --name-status " .. remote_branch
	local result = vim.fn.systemlist(cmd)

	-- Handle errors
	if vim.v.shell_error ~= 0 then
		vim.notify("Error running git diff: " .. table.concat(result, "\n"), vim.log.levels.ERROR)
		return {}
	end

	return result
end

local function parse_diff_result(diff_list)
	local parsed_result = {}

	for _, line in ipairs(diff_list) do
		local status, filename = line:match("^(%w)%s+(.+)$")
		if status and filename then
			local expanded_status = STATUS_MAP[status] or "UNKNOWN"
			table.insert(parsed_result, {
				filename = filename,
				text = expanded_status,
			})
		end
	end

	return parsed_result
end

local function format_quickfix(info)
	local result = {}

	for _, item in ipairs(vim.fn.getqflist({ id = info.id, items = 0 }).items) do
		local filename = item.bufnr and vim.fn.bufname(item.bufnr) or ""
		local text = item.text or ""
		table.insert(result, string.format("%s | %s", filename, text))
	end

	return result
end

local function populate_quickfix(parsed_files)
	vim.fn.setqflist({}, "r", {
		title = "Git Diff Files",
		items = parsed_files,
		quickfixtextfunc = format_quickfix,
	})
	vim.cmd("copen")
end

M.diff = function()
	local files = get_diff_files()
	local parsed = parse_diff_result(files)
	populate_quickfix(parsed)
end

local keep_one_window_and_qf_win = function()
	local not_qf = {}

	for _, window in ipairs(vim.fn.getwininfo()) do
		if window.quickfix == 0 and window.width > 1 then
			table.insert(not_qf, window)
		end
	end

	local without_current = vim.tbl_filter(function(window)
		return window.winnr ~= vim.fn.winnr()
	end, not_qf)

	-- We want to keep one window. If these two tables have the same size:
	if #without_current == #not_qf then
		-- That mean the focus is on the quickfix window. We remove an arbitrary
		-- window for this list and make it the currently focused window.
		local new_focused = table.remove(without_current, 1)
		vim.api.nvim_set_current_win(new_focused.winid)
	end

	for _, window in ipairs(without_current) do
		vim.cmd("bdelete!" .. window.bufnr)
	end
end

M.next = function()
	keep_one_window_and_qf_win()
	vim.cmd("cnext")
	vim.cmd("Gvdiff @{u}")
	vim.cmd("wincmd p")
end

M.prev = function()
	keep_one_window_and_qf_win()
	vim.cmd("cprev")
	vim.cmd("Gvdiff @{u}")
	vim.cmd("wincmd p")
end

return M
