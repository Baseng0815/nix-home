-- Browse the library rather than remember a key. Telescope if it is around,
-- vim.ui.select otherwise.

local zotero = require('zotero')

local M = {}

local function fallback(entries)
  vim.ui.select(entries, {
    prompt = 'Zotero',
    format_item = function(entry)
      return entry.key .. '  ' .. zotero.describe(entry, 70)
    end,
  }, function(choice)
    if choice then zotero.cite(choice.key) end
  end)
end

function M.pick()
  local library = zotero.library()
  if #library.list == 0 then
    return vim.notify(
      'zotero: no entries in ' .. zotero.library_path() .. ' -- is the Better BibTeX export set up?',
      vim.log.levels.WARN
    )
  end

  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then return fallback(library.list) end

  local finders = require('telescope.finders')
  local previewers = require('telescope.previewers')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local conf = require('telescope.config').values

  pickers.new({}, {
    prompt_title = ('Zotero (%d entries)'):format(#library.list),
    finder = finders.new_table({
      results = library.list,
      entry_maker = function(entry)
        local display = entry.key .. '  ' .. zotero.describe(entry)
        return { value = entry, display = display, ordinal = display }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'BibTeX entry',
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.raw, '\n'))
        vim.bo[self.state.bufnr].filetype = 'bib'
      end,
    }),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(bufnr)
        if selection then zotero.cite(selection.value.key) end
      end)
      return true
    end,
  }):find()
end

return M
