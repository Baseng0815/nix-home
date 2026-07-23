vim.g.vimtex_view_method = 'zathura'
-- completion comes from texlab via nvim-cmp, so vimtex's own omnifunc is not needed
vim.g.vimtex_complete_enabled = 0
-- keep quickfix from stealing focus on warnings; open it only on errors
vim.g.vimtex_quickfix_open_on_warning = 0
