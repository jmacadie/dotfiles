return {
	"jmacadie/telescope-hierarchy.nvim",
	-- dir = "/home/james/code/telescope-hierarchy.nvim",
	dependencies = { -- note how they're inverted to above example
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
	},
	keys = {
		{ -- lazy style key map
			"<leader>si",
			"<cmd>Telescope hierarchy<cr>",
			desc = "[S]earch [I]ncoming Calls",
		},
	},
	opts = {
		-- don't use `defaults = { }` here, do this in the main telescope spec
		extensions = {
			hierarchy = {
				-- telescope-hierarchy.nvim config, see below
			},
			-- no other extensions here, they can have their own spec too
		},
	},
	config = function(_, opts)
		-- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
		-- configs for us. We won't use data, as everything is in it's own namespace (telescope
		-- defaults, as well as each extension).
		require("telescope").setup(opts)
		require("telescope").load_extension("hierarchy")
	end,
}
