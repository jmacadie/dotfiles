-- Theme inspired by Atom
return {
    --'navarasu/onedark.nvim',
    'EdenEast/nightfox.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'nordfox'
    end,
}
