local builtin = require('telescope.builtin')

vim.keymap.set('n', '<C-p>', function() builtin.find_files({ no_ignore = true }) end, {})
vim.keymap.set('n', '<C-t>b', builtin.buffers, {})
vim.keymap.set('n', '<C-t>r', builtin.registers, {})
vim.keymap.set('n', '<C-t>k', builtin.keymaps, {})
vim.keymap.set('n', '<C-t>j', builtin.diagnostics, {})
vim.keymap.set('n', '<C-t>q', builtin.quickfix, {})
vim.keymap.set('n', '<C-t>f', builtin.oldfiles, {})
vim.keymap.set('n', '<C-t>h', builtin.help_tags, {})
vim.keymap.set('n', '<C-t>o', builtin.vim_options, {})
vim.keymap.set('n', '<C-t>p', builtin.planets, {})
vim.keymap.set('n', '<C-t>l', builtin.builtin, {})
vim.keymap.set('n', '<C-t>g', builtin.live_grep, {})
vim.keymap.set('n', '<C-t>c', builtin.command_history, {})

require("telescope").setup {
    pickers = {
        find_files = {
            previewer = true
        }
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
                -- even more opts
            }
        }
    }
}

require("telescope").load_extension("ui-select")
