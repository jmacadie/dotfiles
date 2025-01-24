return {
	"dustinblackman/oatmeal.nvim",
	cmd = { "Oatmeal" },
	keys = {
		{ "<leader>om", mode = "n", desc = "Start Oatmeal session" },
	},
	opts = {
		backend = "openai",
		model = "gpt-4o",
	},
}
