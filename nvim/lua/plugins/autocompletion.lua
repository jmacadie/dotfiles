return {
	-- Autocompletion
	"hrsh7th/nvim-cmp",
	enabled = false,
	dependencies = {
		-- Snippet Engine & its associated nvim-cmp source
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",

		-- Adds LSP completion capabilities
		"hrsh7th/cmp-nvim-lsp",

		-- Completion from the buffer
		"hrsh7th/cmp-buffer",

		-- Completion from the filesystem
		"hrsh7th/cmp-path",

		-- Completion from the command line
		-- "hrsh7th/cmp-cmdline",

		-- Completion engine for lua
		"hrsh7th/cmp-nvim-lua",

		-- Adds a number of user-friendly snippets
		"rafamadriz/friendly-snippets",

		-- Icons for completion
		"onsails/lspkind.nvim",
	},
	config = function()
		-- [[ Configure nvim-cmp ]]
		-- See `:help cmp`
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")
		require("luasnip.loaders.from_vscode").lazy_load()
		luasnip.config.setup({})

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-d>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete({}),
				["<C-y>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
				["<C-l>"] = cmp.mapping(function(fallback)
					if luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-j>"] = cmp.mapping(function(fallback)
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-e>"] = cmp.mapping(function(fallback)
					if luasnip.choice_active() then
						luasnip.change_choice(1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = {
				{ name = "nvim_lsp" },
				{ name = "path" },
				{ name = "luasnip" },
				{ name = "buffer", keyword_length = 5 },
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				format = lspkind.cmp_format({
					preset = "default",
					mode = "symbol_text",
					menu = {
						buffer = "[buf]",
						nvim_lsp = "[LSP]",
						luasnip = "[snip]",
						nvim_lua = "[api]",
						path = "[path]",
					},
				}),
				expandable_indicator = true,
				fields = { "abbr", "kind", "menu" },
			},
		})
	end,
}
