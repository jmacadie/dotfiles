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

---Get the commit to compare to
---If a revision has been provided the use that, else default to the upstream tracking branch
---Notify with an error if there is no upstream tracking branch and return nil in that case
---@param revision string | nil
---@return string | nil
local function get_comparison_target(revision)
	if revision then
		local check = vim.system({ "git", "rev-parse", "--verify", "--quiet", revision }, { text = true }):wait()
		if check.code == 0 then
			return revision
		end
		vim.notify(revision .. " is not a valid revision in this repository", vim.log.levels.WARN)
	end

	local upstream = vim.system({ "git", "rev-parse", "--abbrev-ref", "@{u}" }, { text = true }):wait()
	if upstream.code == 0 then
		local upstream_ref = upstream.stdout:gsub("\n", "")
		vim.notify("Comparing to upstream branch " .. upstream_ref, vim.log.levels.INFO)
		return upstream_ref
	end

	vim.notify(
		"No revision provided and no upstream tracking branch, so we have nothing to diff against",
		vim.log.levels.ERROR
	)
	return nil
end

---Get the list of changed files and their statuses
---Returned as a map of filename to status, so it can be joined
---to the the list of filenames from diff --numstat
---@param revision string
---@return table<string, string>, integer
local function get_files_status(revision)
	local map = {}

	local name_status = vim.fn.systemlist("git diff --name-status " .. revision)
	local count = #name_status
	for _, line in ipairs(name_status) do
		if line:sub(1, 1) == "R" then
			local status, pcnt, filename = line:match("^(%u)(%d*)%s+%S+%s+(%S+)$")
			if status and pcnt and filename then
				local pcnt_val = tonumber(pcnt)
				local mapped_status = string.format("%s (%d%%)", STATUS_MAP[status], pcnt_val)
				map[filename] = mapped_status
			end
		else
			local status, filename = line:match("^(%u)%s+(%S+)$")
			if status and filename then
				local mapped_status = STATUS_MAP[status] or "?"
				map[filename] = mapped_status
			end
		end
	end

	return map, count
end

---Make the filename from the parts that git diff --numstat will give us
---In particular if the substitute part is a blank string then we need to
---handle the double file path separator that will otherwise occur when we
---join the prefix and suffix together
---@param prefix string
---@param substitute string
---@param suffix string
---@return string
local function make_path(prefix, substitute, suffix)
	if substitute:len() > 0 then
		return string.format("%s%s%s", prefix, substitute, suffix)
	end

	if prefix:len() > 0 and prefix:sub(-1) == "/" then
		return string.format("%s%s", prefix:sub(1, -2), suffix)
	end

	if suffix:len() > 0 and suffix:sub(1, 1) == "/" then
		return string.format("%s%s", prefix, suffix:sub(2))
	end

	return string.format("%s%s", prefix, suffix)
end

---@class FileDiffStatus
---@field filename string The path and filename of the file. If the file has been moved this will be the file *after* the move
---@field source_filename string | nil If the file was moved, what was the source filename
---@field display string The text to show in the quickfix list
---@field status string The status of the change, as determined by `git diff --name-status`
---@field lines_added integer
---@field lines_deleted integer
---@field comparison_revision string

---Convert the diff between the current worktree and an arbitrary revision to a table of
---files that have been modified, the type of change, and the number of lines changed
---@param revision string | nil
---@return FileDiffStatus[]
local function get_diff_files(revision)
	local result = {}

	local comp = get_comparison_target(revision)
	if not comp then
		return result
	end

	local name_status_map, map_count = get_files_status(comp)
	if map_count == 0 then
		vim.notify("There are no differences to report", vim.log.levels.INFO)
		return result
	end

	local numstat = vim.fn.systemlist("git diff --numstat " .. comp)
	if #numstat ~= map_count then
		vim.notify(
			"git diff --name-status and git diff --numstat are returning different results, cannot proceed",
			vim.log.levels.ERROR
		)
		return result
	end

	for _, line in ipairs(numstat) do
		---@type string | nil, string | nil, string | nil
		local lines_added, lines_deleted, filename = line:match("^(%d+)%s+(%d+)%s+(.+)$")

		if lines_added and lines_deleted and filename then
			local added = tonumber(lines_added)
			local deleted = tonumber(lines_deleted)
			-- See if the format of the filname indicates a moved file
			---@type string | nil, string | nil, string | nil, string | nil
			local prefix, part_1, part_2, suffix = filename:match("^([^{]*){(%S*) => (%S*)}(%S*)")

			if part_1 or part_2 then
				--Moved file
				local from_fname = make_path(prefix, part_1, suffix)
				local to_fname = make_path(prefix, part_2, suffix)
				table.insert(result, {
					filename = to_fname,
					source_filename = from_fname,
					display = filename,
					status = name_status_map[to_fname] or "?", -- Default status to "?" if not found
					lines_added = added,
					lines_deleted = deleted,
					comparison_revision = comp,
				})
			else
				-- Not a moved file
				table.insert(result, {
					filename = filename,
					source_filename = filename,
					display = filename,
					status = name_status_map[filename] or "?", -- Default status to "?" if not found
					lines_added = added,
					lines_deleted = deleted,
					comparison_revision = comp,
				})
			end
		end
	end

	return result
end

---@class QuickFixInfo
---@field quickfix integer set to 1 when called for a quickfix list and 0 when called for a location list
---@field winid integer for a location list, set to the id of the window with the location list. For a quickfix list, set to 0. Can be used in getloclist() to get the location list entry.
---@field id integer quickfix or location list identifier
---@field start_idx integer index of the first entry for which text should be returned
---@field end_idx integer index of the last entry for which text should be returned

---Format the quickfix window as per the vim documentation
---https://neovim.io/doc/user/quickfix.html#quickfix-window-function
---@param info QuickFixInfo
---@return string[]
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

---Populate the quickfix list as per the vim documentation
---https://neovim.io/doc/user/builtin.html#setqflist()
---@param parsed_files FileDiffStatus[]
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
				comparison_revision = item.comparison_revision,
			},
		})
	end

	vim.fn.setqflist({}, "r", {
		title = "Git Diff Files",
		items = items,
		quickfixtextfunc = format_quickfix,
	})
end

---Organise the displayed windows so that the next file's diff can be correctly shown
---The function will close all visible windows that are not the quichfix list and the current window
---The quickfix list is maintained as it is to stay visible for the PR session (although it may be manually closed)
---The current window is maintained so that there is a code window to open the next file into, if
---this window the code would be opened in the quickfix window, losing it in the process
---If the currently active window is the quickfix list, then make a special case of randomly selecting one of
---the other windows to keep open
local organise_windows = function()
	local not_qf = {}

	for _, window in ipairs(vim.fn.getwininfo()) do
		if window.quickfix == 0 and window.width > 1 then
			table.insert(not_qf, window)
		end
	end

	local current_winnr = vim.fn.winnr()
	local without_current = vim.tbl_filter(function(window)
		return window.winnr ~= current_winnr
	end, not_qf)

	-- Special case where the qf window is currently selected
	if #without_current == #not_qf then
		local new_focused = table.remove(without_current, 1)
		vim.api.nvim_set_current_win(new_focused.winid)
	end

	for _, window in ipairs(without_current) do
		vim.cmd("bdelete!" .. window.bufnr)
	end
end

---Is a PR session currently running?
---Determined by looking at the title of the quickfix list, which is ever so slightly flakey
---@return boolean
local function qf_diff_running()
	local qf_title = vim.fn.getqflist({ title = 0 }).title
	return qf_title == "Git Diff Files"
end

---Move the quickfix list forwards one entry
---By default, the quickfix list stops when it reaches the end
---This function allows for wrapping behaviour by moving to the first entry if we are at the end
local function cycle_qf_forward()
	local at_end = (vim.fn.getqflist({ idx = 0 }).idx == vim.fn.getqflist({ size = 0 }).size)
	if at_end then
		vim.cmd("cfirst")
	else
		vim.cmd("cnext")
	end
end

---Move the quickfix list backwards one entry
---By default, the quickfix list stops if it is at the start
---This function allows for wrapping behaviour by moving to the last entry if we are at the start
local function cycle_qf_backward()
	local at_start = (vim.fn.getqflist({ idx = 0 }).idx == 1)
	if at_start then
		vim.cmd("clast")
	else
		vim.cmd("cprev")
	end
end

---Load up a vertical diff of the currently edited file
local function diff_current_file()
	local qf_idx = vim.fn.getqflist({ idx = 0 }).idx
	local qf_list = vim.fn.getqflist()
	local data = qf_list[qf_idx].user_data

	-- If the file was added then it won't exist in the comparison revision tree
	-- There is no point trying to diff to this file as it won't exist and will generate an error
	-- So just quit out early
	if data.status == "ADDED" then
		return
	end

	local source = data.source
	local revision = data.comparison_revision
	vim.cmd(string.format("Gvdiffsplit %s:%s", revision, source))
	-- TODO: Might be able to get rid of the vim-fugitive dependency with
	-- `:vnew | r !git show revision:source | setlocal buftype=nowrite`, and
	-- `:diffthis`
	-- but it looks like a lot of faff and anyway, I use vim-fugitive

	-- Move focus back to the originating window
	-- this is the real file we have in the working directory
	vim.cmd("wincmd p")
end

-- The API
-- ============================

---Start a Pull Review session
---Will find all the files that are different between the current workspace files and whatever is
---in the comparison branch or commit as determined by the revision
---The first diff will be auto-loaded
---Use the `next` and `prev` functions to cycle through the differences
---@param revision string | nil The revision to compare against, if ommitted will use the upstream tracking branch
M.diff = function(revision)
	local files = get_diff_files(revision)
	if not files or #files == 0 then
		-- got a revision error or there are no differences to report
		-- quit out now
		return
	end
	populate_quickfix(files)
	vim.cmd("copen")
	organise_windows()
	vim.cmd("cc")
	diff_current_file()
end

---Move to the next file in the quickfix list
---If a PR session is not running this will fall back on normal quickfix list behaviour
---If a PR session is running but you have a mess of other windows loaded, this function will recover the
---window state back to a clean diff
---The only thing that won't be recovered is the quickfix window, which if closed will remain so. It is
---perfectly fine to cycle through the differences without the quickfix window but if you want it back
---you'll need `:copen`
M.next = function()
	if qf_diff_running() then
		organise_windows()
		cycle_qf_forward()
		diff_current_file()
	else
		cycle_qf_forward()
	end
end

---Move to the previous file in the quickfix list
---If a PR session is not running this will fall back on normal quickfix list behaviour
---If a PR session is running but you have a mess of other windows loaded, this function will recover the
---window state back to a clean diff
---The only thing that won't be recovered is the quickfix window, which if closed will remain so. It is
---perfectly fine to cycle through the differences without the quickfix window but if you want it back
---you'll need `:copen`
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
