-- Vault editing: following and completing [[wiki links]], backlinks, note
-- search. Completion is served by the plugin's own in-process LSP server, so
-- nvim-cmp picks it up through the nvim_lsp source without extra wiring.

-- The defaults map ]o and [o for link navigation, which shadow vim-unimpaired's
-- option-toggle prefix in every note. Register only <CR> below instead.
vim.g.obsidian_default_keymap = false

require('obsidian').setup {
  workspaces = {
    -- The vault root is the repo itself; .obsidian/ lives next to the notes.
    { name = 'opcua-knowledge', path = '~/o6/opcua-knowledge' },
  },

  picker = { name = 'telescope.nvim' },

  -- Only :Obsidian <subcommand>; the deprecated :ObsidianFoo aliases are
  -- dropped in 4.0 anyway.
  legacy_commands = false,

  -- No conceal-based rendering, the buffer stays plain markdown.
  ui = { enable = false },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'ObsidianNoteEnter',
  callback = function(ev)
    -- Follow the link under the cursor, or toggle the checkbox on a task line.
    vim.keymap.set('n', '<CR>', require('obsidian.actions').smart_action,
      { expr = true, buffer = ev.buf, desc = 'Obsidian smart action' })
  end,
})

-- `syntax on` in options.lua detects the filetype of the buffers made from the
-- command line arguments, which happens long before this file registers the
-- plugin's FileType hook. Without replaying the events `nvim note.md` opens a
-- note the plugin never attaches to, while a later `:edit` works fine.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buf].filetype == 'markdown' then
    vim.api.nvim_exec_autocmds('FileType', { group = 'obsidian_setup', buffer = buf })
    vim.api.nvim_exec_autocmds('BufEnter', { group = 'obsidian_setup', buffer = buf })
  end
end
