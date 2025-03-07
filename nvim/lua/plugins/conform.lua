local function ensure_eof_newline(lines) end

return {
	"stevearc/conform.nvim",
	opts = {
		formatters = {
			ensure_eof_newline = {
				format = function(_, _, lines, callback)
					-- If the file is empty, just return a single empty line
					if #lines == 0 then
						callback(nil, { "" })
					end
					-- If the last line is not empty, add an empty line
					if lines[#lines] ~= "" then
						table.insert(lines, "")
					end
					callback(nil, lines)
				end,
			},
		},
		formatters_by_ft = {
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			rust = { "rustfmt" },
			lua = { "stylua" },
			ruby = { "rubocop" },
			json = { "trim_whitespace", "ensure_eof_newline" },
			["*"] = { "trim_whitespace" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	},
}
