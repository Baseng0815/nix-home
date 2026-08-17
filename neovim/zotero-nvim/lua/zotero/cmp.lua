-- nvim-cmp source. Offers the Zotero library inside \cite{…} and nowhere else.

local zotero = require('zotero')

local source = {}

function source.new()
  return setmetatable({ cache = {} }, { __index = source })
end

function source:get_debug_name()
  return 'zotero'
end

function source:is_available()
  return vim.bo.filetype == 'tex' or vim.bo.filetype == 'plaintex'
end

function source:get_trigger_characters()
  return { '{', ',' }
end

-- A citation key runs up to the enclosing brace or the comma separating it
-- from the previous key, and may contain ':', '-' and '.'.
function source:get_keyword_pattern()
  -- A long bracket one level up, because the pattern itself contains ']]'.
  return [=[[^{},[:blank:]]\+]=]
end

-- Building the item list is linear in the size of the library, so it is done
-- once per version of the file on disk.
local function items(library)
  local out = {}
  for _, entry in ipairs(library.list) do
    local summary = zotero.describe(entry, 60)
    out[#out + 1] = {
      label = summary == '' and entry.key or (entry.key .. '  ' .. summary),
      -- Only the key is written into the buffer.
      insertText = entry.key,
      word = entry.key,
      -- …but typing an author or a title word finds it too.
      filterText = entry.key .. ' ' .. summary,
      sortText = entry.key,
      kind = require('cmp.types').lsp.CompletionItemKind.Reference,
      data = { key = entry.key },
    }
  end
  return out
end

function source:complete(params, callback)
  if not zotero.in_cite(params.context.cursor_before_line) then
    return callback({ items = {}, isIncomplete = false })
  end

  local library = zotero.library()
  if not self.cache.items or self.cache.mtime ~= library.mtime then
    self.cache = { mtime = library.mtime, items = items(library) }
  end

  -- texlab already completes the keys that are in the document's .bib, so
  -- offering those again would just double every entry. What is left is
  -- exactly the citations that still need to be copied across. If texlab is
  -- not attached, nothing else would offer them, so show everything.
  local texlab = #vim.lsp.get_clients({ bufnr = 0, name = 'texlab' }) > 0
  if not texlab then
    return callback({ items = self.cache.items, isIncomplete = false })
  end

  local existing = zotero.bib_entries().by_key
  local out = {}
  for _, item in ipairs(self.cache.items) do
    if not existing[item.data.key] then out[#out + 1] = item end
  end
  callback({ items = out, isIncomplete = false })
end

-- The details only matter for the entry the cursor is on, so they are built
-- on demand rather than for the whole library.
function source:resolve(item, callback)
  local entry = zotero.library().by_key[item.data and item.data.key]
  if entry then
    item.documentation = { kind = 'markdown', value = zotero.document(entry) }
  end
  callback(item)
end

return source
