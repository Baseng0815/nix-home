{ lib, pkgs, ... }:

let
  # Citation completion from the Zotero library, see neovim/zotero-nvim.
  zotero-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "zotero-nvim";
    version = "0.1.0";
    src = ./neovim/zotero-nvim;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      ${builtins.readFile ./neovim/options.lua}
      ${builtins.readFile ./neovim/lsp.lua}
      ${builtins.readFile ./neovim/keybinds.lua}
      ${builtins.readFile ./neovim/telescope.lua}
      ${builtins.readFile ./neovim/vimtex.lua}
      ${builtins.readFile ./neovim/zotero.lua}
      ${builtins.readFile ./neovim/obsidian.lua}
    '';
    plugins = [ zotero-nvim ] ++ (with pkgs.vimPlugins; [
      # lsp and completion stuff
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp
      nvim-autopairs

      # tpope stuff
      vim-sensible
      vim-unimpaired
      vim-fugitive
      vim-surround
      vim-eunuch
      vim-repeat
      vim-commentary

      # seamless navigation between vim and tmux panes
      vim-tmux-navigator

      # latex editing (compilation, zathura preview, motions)
      vimtex

      # obsidian vault editing (wiki links, backlinks, note search)
      obsidian-nvim

      # snippets
      luasnip
      cmp_luasnip
      friendly-snippets

      # file browser and other navigation stuff
      nerdtree
      fzf-lua
      telescope-nvim
      telescope-ui-select-nvim
      telescope-symbols-nvim

      # let's see if this is worth
      multicursor-nvim
      diffview-nvim
    ]);
  };
}
