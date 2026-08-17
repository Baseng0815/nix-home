-- A small BibTeX reader. Just enough to split a file into entries and pull
-- single fields back out -- no attempt at a full parser, since everything it
-- reads is machine written by Zotero.

local M = {}

-- Position of the '}' that closes the '{' at `open`, or nil if unbalanced.
function M.matching_brace(text, open)
  local depth, i = 0, open
  while true do
    local pos = text:find('[{}\\]', i)
    if not pos then return nil end
    local c = text:sub(pos, pos)
    if c == '\\' then
      i = pos + 2 -- an escaped character, braces included
    elseif c == '{' then
      depth, i = depth + 1, pos + 1
    else
      depth, i = depth - 1, pos + 1
      if depth == 0 then return pos end
    end
  end
end

-- Split `text` into a list of { key, kind, raw } entries, in file order.
function M.entries(text)
  local out, i = {}, 1
  while true do
    local at = text:find('@', i, true)
    if not at then return out end
    local open = text:find('{', at, true)
    if not open then return out end
    local close = M.matching_brace(text, open)
    if not close then return out end

    local kind = text:sub(at + 1, open - 1):gsub('%s', ''):lower()
    if kind ~= 'comment' and kind ~= 'string' and kind ~= 'preamble' then
      local key = text:sub(open + 1, close - 1):match('^%s*([^,%s}]+)')
      if key then
        out[#out + 1] = { key = key, kind = kind, raw = text:sub(at, close) }
      end
    end
    i = close + 1
  end
end

-- Drop the braces LaTeX uses to protect capitalisation, and squash the
-- newlines Zotero wraps long fields at.
function M.clean(s)
  s = s:gsub('[{}]', ''):gsub('%s+', ' ')
  return vim.trim(s)
end

-- Value of the `name` field of a raw entry, or nil. The leading [,{] anchors
-- the match to a whole field name, so `title` does not match `booktitle`.
function M.field(raw, name)
  local lower = raw:lower()
  local _, eq = lower:find('[,{]%s*' .. name .. '%s*=%s*')
  if not eq then return nil end

  local c = raw:sub(eq + 1, eq + 1)
  if c == '{' then
    local close = M.matching_brace(raw, eq + 1)
    if not close then return nil end
    return M.clean(raw:sub(eq + 2, close - 1))
  elseif c == '"' then
    local close = raw:find('"', eq + 2, true)
    return M.clean(raw:sub(eq + 2, (close or eq + 2) - 1))
  end
  return M.clean(raw:sub(eq + 1):match('^[^,}\n]*'))
end

-- "Binosi et al." / "Watkins" -- handles both "Last, First" and "First Last".
function M.authors(raw)
  local list = M.field(raw, 'author') or M.field(raw, 'editor')
  if not list then return nil end

  local first = list:match('^(.-) and ') or list
  local last = first:find(',') and first:match('^([^,]+)') or first:match('(%S+)%s*$')
  if not last then return nil end
  return list:find(' and ') and (last .. ' et al.') or last
end

return M
