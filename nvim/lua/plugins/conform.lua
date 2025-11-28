---@diagnostic disable-next-line unused-function
local function ensure_eof_newline(lines) end

return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		local opts = {
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
		}
		conform.setup(opts)
		vim.keymap.set("n", "<leader>f", function()
			conform.format()
		end, { desc = "[F] ormat file" })
	end,
}
