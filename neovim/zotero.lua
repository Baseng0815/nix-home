-- Citation completion from Zotero. The library file is written by Better
-- BibTeX ("Export Library…" with "Keep updated" ticked); the entries land in
-- whichever .bib the document registers with \addbibresource.
require('zotero').setup {
  library = '~/Zotero/library.bib',
}

vim.keymap.set('n', '<C-t>z', '<cmd>ZoteroCite<CR>', { desc = 'Cite from Zotero' })
