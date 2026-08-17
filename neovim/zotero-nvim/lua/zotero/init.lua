-- Cite from Zotero without leaving the buffer.
--
-- Better BibTeX keeps a mirror of the whole Zotero library at `config.library`.
-- This reads that mirror to complete citation keys, and copies the entry you
-- picked into the bibliography the document actually loads, so the thesis' .bib
-- only ever contains what is cited and never changes behind your back.

local bib = require('zotero.bib')

local M = {}

M.config = {
  -- The Better BibTeX auto-export of your library. A manual "Export Library…"
  -- to the same path works too, it just goes stale.
  library = '~/Zotero/library.bib',
  -- Where citations are written. nil means "whatever the document loads with
  -- \addbibresource"; set it only if that guess is wrong.
  bib = nil,
  -- Searched for \addbibresource and, by :ZoteroSync, for \cite keys.
  tex_glob = '**/*.tex',
  -- Skipped when globbing, so build output cannot shadow the real sources.
  ignore = { '/output/', '/build/', '/.git/', '/_minted' },
}

-- Parsed files, reread only when their mtime changes ------------------------

local files = {}

local function read(path)
  local stat = path and vim.uv.fs_stat(path)
  if not stat then return { list = {}, by_key = {} } end

  local mtime = stat.mtime.sec .. '.' .. stat.mtime.nsec
  local cached = files[path]
  if cached and cached.mtime == mtime then return cached end

  local fd = io.open(path, 'r')
  if not fd then return { list = {}, by_key = {} } end
  local list = bib.entries(fd:read('a') or '')
  fd:close()

  local by_key = {}
  for _, entry in ipairs(list) do by_key[entry.key] = entry end

  files[path] = { mtime = mtime, list = list, by_key = by_key, path = path }
  return files[path]
end

function M.library_path()
  return vim.fn.expand(M.config.library)
end

-- Every entry in the Zotero mirror.
function M.library()
  return read(M.library_path())
end

-- Every entry already in the document's bibliography.
function M.bib_entries()
  return read(M.bib_file())
end

-- Locating the document's bibliography --------------------------------------

local function ignored(path)
  for _, pattern in ipairs(M.config.ignore) do
    if path:find(pattern, 1, true) then return true end
  end
  return false
end

function M.root()
  local vimtex = vim.b.vimtex
  if vimtex and vimtex.root and vimtex.root ~= '' then return vimtex.root end
  return vim.fs.root(0, { 'latexmkrc', '.latexmkrc', '.git' }) or vim.fn.getcwd()
end

function M.tex_files(dir)
  local out = {}
  for _, path in ipairs(vim.fn.globpath(dir, M.config.tex_glob, false, true)) do
    if not ignored(path) then out[#out + 1] = path end
  end
  return out
end

-- Everything after an unescaped '%' is a comment, so a commented out
-- \addbibresource must not count.
local function strip_comment(line)
  local i = 1
  while true do
    local pos = line:find('%%', i)
    if not pos then return line end
    if pos == 1 or line:sub(pos - 1, pos - 1) ~= '\\' then return line:sub(1, pos - 1) end
    i = pos + 1
  end
end

local function each_line(path, fn)
  local fd = io.open(path, 'r')
  if not fd then return end
  for line in fd:lines() do fn(strip_comment(line)) end
  fd:close()
end

-- The .bib files registered by the document, as absolute paths. Relative
-- paths resolve against the project root, the way LaTeX resolves them.
function M.registered_bibs()
  local dir = M.root()
  local out, seen = {}, {}

  local function add(spec)
    if not spec:match('%.bib$') then spec = spec .. '.bib' end
    local path = spec:sub(1, 1) == '/' and spec or (dir .. '/' .. spec)
    path = vim.fs.normalize(path)
    if not seen[path] then
      seen[path] = true
      out[#out + 1] = path
    end
  end

  for _, tex in ipairs(M.tex_files(dir)) do
    each_line(tex, function(line)
      for spec in line:gmatch('\\addbibresource%s*%[?[^%]{]*%]?{([^}]+)}') do
        add(vim.trim(spec))
      end
      for specs in line:gmatch('\\bibliography%s*{([^}]+)}') do
        for spec in specs:gmatch('[^,]+') do add(vim.trim(spec)) end
      end
    end)
  end
  return out
end

-- Scanning every .tex is too slow to repeat per keystroke, so the answer is
-- kept per buffer. :ZoteroBib forgets it.
function M.bib_file()
  local none = 'no \\addbibresource found under ' .. M.root()
  if M.config.bib then return vim.fn.expand(M.config.bib) end
  -- '' records "looked, found nothing", so a document without a bibliography
  -- does not rescan the project on every keystroke.
  if vim.b.zotero_bib == '' then return nil, none end
  if vim.b.zotero_bib then return vim.b.zotero_bib end

  local bibs = M.registered_bibs()
  if #bibs == 0 then
    vim.b.zotero_bib = ''
    return nil, none
  end
  if #bibs > 1 then
    vim.notify(
      ('zotero: %d bibliographies registered, writing to %s (set config.bib to override)')
        :format(#bibs, vim.fn.fnamemodify(bibs[1], ':t')),
      vim.log.levels.WARN
    )
  end
  vim.b.zotero_bib = bibs[1]
  return bibs[1]
end

-- Adding entries -------------------------------------------------------------

-- Append `keys` to the document's bibliography, skipping the ones already in
-- it. Returns the keys added and the keys that are not in the library.
function M.add(keys)
  local target, err = M.bib_file()
  if not target then return {}, {}, err end

  -- A copy, because it doubles as the guard against `keys` repeating itself
  -- and must not leak back into the cache if the write fails.
  local present = vim.tbl_extend('force', {}, read(target).by_key)
  local library = M.library().by_key
  local added, unknown, chunks = {}, {}, {}

  for _, key in ipairs(keys) do
    if not present[key] then
      local entry = library[key]
      if entry then
        present[key] = entry -- guards against duplicates within `keys`
        added[#added + 1] = key
        chunks[#chunks + 1] = vim.trim(entry.raw)
      else
        unknown[#unknown + 1] = key
      end
    end
  end

  if #chunks > 0 then
    local fd = io.open(target, 'a')
    if not fd then return {}, unknown, 'cannot write ' .. target end
    fd:write('\n', table.concat(chunks, '\n\n'), '\n')
    fd:close()
    files[target] = nil -- force a reread
    vim.cmd.checktime() -- pick the change up if the .bib is open in a window
  end

  return added, unknown, nil
end

-- Add a single key and say so. Used when accepting a completion.
function M.add_one(key)
  local added, unknown, err = M.add({ key })
  if err then
    vim.notify('zotero: ' .. err, vim.log.levels.ERROR)
  elseif #added > 0 then
    vim.notify(('zotero: added %s to %s'):format(key, vim.fn.fnamemodify(M.bib_file(), ':t')))
  elseif #unknown > 0 then
    vim.notify('zotero: ' .. key .. ' is not in ' .. M.library_path(), vim.log.levels.WARN)
  end
end

-- Reconciling the whole document ---------------------------------------------

-- Keys used by \cite, \parencite[see][p. 5], \textcite*, \nocite, … The
-- [^{}]* swallows the optional pre/postnotes without crossing into a group.
local CITE = '\\%a*[cC][iI][tT][eE]%a*%s*%*?[^{}]*(%b{})'

function M.cited_keys()
  local keys, seen = {}, {}
  for _, tex in ipairs(M.tex_files(M.root())) do
    each_line(tex, function(line)
      for group in line:gmatch(CITE) do
        for key in group:sub(2, -2):gmatch('[^,]+') do
          key = vim.trim(key)
          if key ~= '' and key ~= '*' and not seen[key] then
            seen[key] = true
            keys[#keys + 1] = key
          end
        end
      end
    end)
  end
  return keys
end

-- Pull in every cited key that is missing from the bibliography. Catches
-- citations that arrived by paste rather than through completion.
function M.sync()
  local target, err = M.bib_file()
  if not target then
    return vim.notify('zotero: ' .. err, vim.log.levels.ERROR)
  end
  if #M.library().list == 0 then
    return vim.notify(
      'zotero: no entries in ' .. M.library_path() .. ' -- is the Better BibTeX export set up?',
      vim.log.levels.WARN
    )
  end

  local added, unknown, add_err = M.add(M.cited_keys())
  if add_err then
    return vim.notify('zotero: ' .. add_err, vim.log.levels.ERROR)
  end

  local name = vim.fn.fnamemodify(target, ':t')
  if #added == 0 and #unknown == 0 then
    vim.notify('zotero: ' .. name .. ' is up to date')
  elseif #added > 0 then
    vim.notify(('zotero: added %d entr%s to %s\n  %s')
      :format(#added, #added == 1 and 'y' or 'ies', name, table.concat(added, '\n  ')))
  end
  if #unknown > 0 then
    vim.notify(('zotero: %d cited key%s not in Zotero\n  %s')
      :format(#unknown, #unknown == 1 and '' or 's', table.concat(unknown, '\n  ')),
      vim.log.levels.WARN)
  end
end

-- Presentation ---------------------------------------------------------------

-- "Binosi et al. 2023 · Rainfuzz: Reinforcement-Learning Driven Heat-Maps"
function M.describe(entry, title_width)
  local parts = {}
  local authors = bib.authors(entry.raw)
  local year = bib.field(entry.raw, 'year') or bib.field(entry.raw, 'date')
  if authors then parts[#parts + 1] = authors end
  if year then parts[#parts + 1] = year:sub(1, 4) end

  local title = bib.field(entry.raw, 'title')
  if title then
    if title_width and #title > title_width then
      title = title:sub(1, title_width - 1) .. '…'
    end
    parts[#parts + 1] = '· ' .. title
  end
  return table.concat(parts, ' ')
end

-- The hover window next to the completion popup.
function M.document(entry)
  local lines = {}
  local title = bib.field(entry.raw, 'title')
  if title then lines[#lines + 1] = '**' .. title .. '**' end

  local byline = {}
  local authors = bib.field(entry.raw, 'author') or bib.field(entry.raw, 'editor')
  local year = bib.field(entry.raw, 'year') or bib.field(entry.raw, 'date')
  if authors then byline[#byline + 1] = authors end
  if year then byline[#byline + 1] = '(' .. year:sub(1, 4) .. ')' end
  if #byline > 0 then
    lines[#lines + 1] = ''
    lines[#lines + 1] = table.concat(byline, ' ')
  end

  local venue = bib.field(entry.raw, 'journaltitle')
    or bib.field(entry.raw, 'journal')
    or bib.field(entry.raw, 'booktitle')
    or bib.field(entry.raw, 'publisher')
  if venue then lines[#lines + 1] = '*' .. venue .. '*' end

  local abstract = bib.field(entry.raw, 'abstract')
  if abstract then
    if #abstract > 600 then abstract = abstract:sub(1, 600) .. '…' end
    lines[#lines + 1] = ''
    lines[#lines + 1] = abstract
  end
  return table.concat(lines, '\n')
end

-- Cursor context -------------------------------------------------------------

-- True when the cursor sits inside the braces of a \cite-ish command:
-- \cite{…}, \parencite[see][p. 5]{…}, \textcite*{…}, \citeauthor{a,b…}
function M.in_cite(before)
  local open = before:find('{[^{}]*$')
  if not open then return false end

  local head = before:sub(1, open - 1)
  for _ = 1, 2 do head = head:gsub('%b[]%s*$', '') end -- optional pre/postnote
  local cmd = head:match('\\(%a+)%*?%s*$')
  return cmd ~= nil and cmd:lower():find('cite') ~= nil
end

-- Insert `key` at the cursor, adding \cite{} unless we are already inside one.
function M.cite(key)
  M.add_one(key)

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before = vim.api.nvim_get_current_line():sub(1, col)
  local text = M.in_cite(before) and key or ('\\cite{' .. key .. '}')

  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { text })
  vim.api.nvim_win_set_cursor(0, { row, col + #text })
end

-- Wiring ----------------------------------------------------------------------

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  vim.api.nvim_create_user_command('ZoteroSync', function() M.sync() end, {
    desc = 'Add every cited key missing from the document bibliography',
  })
  vim.api.nvim_create_user_command('ZoteroCite', function()
    require('zotero.picker').pick()
  end, { desc = 'Browse the Zotero library and insert a citation' })
  vim.api.nvim_create_user_command('ZoteroBib', function()
    vim.b.zotero_bib = nil
    local target, err = M.bib_file()
    vim.notify('zotero: ' .. (target or err))
  end, { desc = 'Re-detect and show the bibliography being written to' })

  local ok, cmp = pcall(require, 'cmp')
  if not ok then return end

  cmp.register_source('zotero', require('zotero.cmp').new())
  cmp.setup.filetype({ 'tex', 'plaintex' }, {
    sources = cmp.config.sources(
      { { name = 'zotero' }, { name = 'nvim_lsp' }, { name = 'luasnip' } },
      { { name = 'buffer' }, { name = 'path' } }
    ),
  })

  -- Accepting a completion is what copies the entry across.
  cmp.event:on('confirm_done', function(event)
    local entry = event.entry
    if not entry or entry.source.name ~= 'zotero' then return end
    local item = entry:get_completion_item()
    local key = item and item.data and item.data.key
    if key then M.add_one(key) end
  end)
end

return M
